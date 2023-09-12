import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nutricount/models/calcukate_list_model.dart';
import 'package:nutricount/widgets/custom_appbar.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../models/nutri_data_model.dart';

class CalculateAnalysisScreen extends StatefulWidget {
  const CalculateAnalysisScreen(this.userSelected, {super.key});
  final List<CalculateListModel> userSelected;
  @override
  State<CalculateAnalysisScreen> createState() =>
      _CalculateAnalysisScreenState();
}

class _CalculateAnalysisScreenState extends State<CalculateAnalysisScreen> {
  List<NutriDataModel> filterdNutrientsList = [];
  List<NutriDataModel> nutrientsList = [];

  TextEditingController filterController = TextEditingController(text: '100');
  TextEditingController searchController = TextEditingController(text: '100');

  processData() {
    Map calculateValueMap = {};
    for (var item in widget.userSelected) {
      final data = item.data;
      final values = data!.values;
      final keys = data.keys;
      for (var index = 0; index < data.length; index++) {
        if (double.tryParse(values.elementAt(index).toString()) != null &&
            keys.elementAt(index).toString() != 'No. of Regions') {
          if (calculateValueMap[keys.elementAt(index)] != null) {
            calculateValueMap[keys.elementAt(index)] =
                calculateValueMap[keys.elementAt(index)] +
                    (double.parse(values.elementAt(index).toString()) /
                        100 *
                        (double.tryParse(item.quantity!) ?? 0));
          } else {
            calculateValueMap[keys.elementAt(index)] =
                (double.parse(values.elementAt(index).toString()) /
                    100 *
                    (double.tryParse(item.quantity!) ?? 0));
          }
          // Map<String, dynamic> nutriData = getNutriData(
          //   key: keys.elementAt(index).toString(),
          //   value: double.parse(
          //     values.elementAt(index).toString(),
          //   ),
          // );
          // print(nutriData);
          // filterdNutrientsList.add(NutriDataModel.fromJson(nutriData));
        }
      }
    }
    for (var index = 0; index < calculateValueMap.length; index++) {
      Map<String, dynamic> nutriData = getNutriData(
        key: calculateValueMap.keys.elementAt(index).toString(),
        value: double.parse(
          calculateValueMap.values.elementAt(index).toString(),
        ),
      );
      print(nutriData);
      filterdNutrientsList.add(NutriDataModel.fromJson(nutriData));
    }
    // filterList();
  }

  Map<String, dynamic> getNutriData(
      {required String key, required double value}) {
    double newValue = value;
    String unit = 'gm';
    if (key == 'Energy') {
      return {'title': key, 'value': value, 'unit': 'kJ'};
    }
    if (value == 0) {
      return {'title': key, 'value': newValue, 'unit': unit};
    }
    if (value < 0.01) {
      newValue = value * 1000;
      unit = 'mg';
      if (newValue < 0.01) {
        newValue = value * 1000000;
        unit = 'mcg';
      }
    }
    return {'title': key, 'value': newValue, 'unit': unit};
  }

  Future<bool> getPermission() async {
    DeviceInfoPlugin plugin = DeviceInfoPlugin();
    AndroidDeviceInfo android = await plugin.androidInfo;
    print(android.version.sdkInt);
    if (android.version.sdkInt < 33) {
      var status = await Permission.storage.request();
      if (status.isGranted) {
        return true;
      } else if (status.isPermanentlyDenied) {
        openAppSettings();
        return await getPermission();
      }
      return false;
    } else {
      var status = await Permission.manageExternalStorage.request();
      if (status.isGranted) {
        return true;
      } else if (status.isPermanentlyDenied) {
        openAppSettings();
        return await getPermission();
      }
      return false;
    }
  }

  void _writeExcelFile() async {
    final hasPermission = await getPermission();
    print('hasPermission' + hasPermission.toString());
    if (!hasPermission) return;
    var excel = Excel.createExcel();
    var sheet = excel['Sheet1'];

    // Add data to the sheet.
    final titleList = filterdNutrientsList.map((e) => e.title!).toList();
    sheet.appendRow(['Name', ...titleList]);
    for (var element in widget.userSelected) {
      final data = element.data;
      final rowData = [data!['Food Name']];
      for (var title in titleList) {
        rowData.add(data[title]);
      }
      sheet.appendRow(rowData);
    }
    List totals = [''];
    for (var totalValue in filterdNutrientsList) {
      if (totalValue.unit == 'mg') {
        totals.add(totalValue.value! / 1000);
      } else if (totalValue.unit == 'mcg') {
        totals.add(totalValue.value! / 1000000);
      } else {
        totals.add(totalValue.value!);
      }
    }
    sheet.appendRow(totals);

    // Save the Excel file to the device's download directory.
    // final directory = await getExternalStorageDirectory();
    final directory2 = Directory('/storage/emulated/0/Download');
    final filePath =
        '${directory2.path}/Nutricount_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final bytes = excel.encode();
    await File(filePath).writeAsBytes(bytes!, mode: FileMode.write);
    Fluttertoast.showToast(
      msg: "Saved",
      toastLength: Toast.LENGTH_SHORT,
    );
    print(directory2);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    processData();
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: CustomAppBar(
          title: 'Analysis',
          action: IconButton(
              onPressed: () {
                _writeExcelFile();
              },
              icon: const Icon(
                Icons.save,
                color: Colors.white,
              )),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: filterdNutrientsList.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: w * .03, vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                                (filterdNutrientsList[index].title ?? '')
                                    .split(';')
                                    .first),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${formatDouble((filterdNutrientsList[index].value ?? 0.0) * (double.tryParse(filterController.text) ?? 0) / 100)} ${filterdNutrientsList[index].unit ?? ''}',
                          )
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider(
                    height: 1,
                    color: Color.fromARGB(142, 219, 216, 216),
                  );
                },
              ),
            )
          ],
        ));
  }

  String formatDouble(double value) {
    String formattedValue = value.toStringAsFixed(2);
    return formattedValue.replaceAll(RegExp(r'\.0*$'), '');
  }
}
