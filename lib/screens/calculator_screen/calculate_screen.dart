import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nutricount/constants/app_colors.dart';
import 'package:nutricount/models/calcukate_list_model.dart';
import 'package:nutricount/screens/calculate_analysis_screen/calculate_analysis_screen.dart';
import 'package:nutricount/utils/editalert.dart';
import 'package:nutricount/widgets/custom_appbar.dart';
import 'package:permission_handler/permission_handler.dart';

class CalculateScreen extends StatefulWidget {
  const CalculateScreen({super.key});

  @override
  State<CalculateScreen> createState() => _CalculateScreenState();
}

class _CalculateScreenState extends State<CalculateScreen> {
  TextEditingController searchController = TextEditingController();
  List<CalculateListModel> userSelected = [];
  bool loader = false;
  bool showSearchBar = false;
  List fetchedData = [];
  List<dynamic> filteredJsonData = [];
  List<dynamic> jsonData = [];
  List<String> categoryList = [];

  Future<void> loadJsonData() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/local_database/data.json');
      final map = json.decode(jsonString);
      final List<dynamic> data = map['Data'];
      for (var element in data) {
        if (!categoryList.contains(element['Food Group'])) {
          categoryList.add(element['Food Group']);
        }
      }
      setState(() {
        filteredJsonData = data;
        jsonData = data;
      });
      log(jsonData.length.toString());
      // filterData();
    } catch (e) {
      print('Error loading JSON file: $e');
    }
  }

  addToList(Map data, String quantity) {
    userSelected.add(
      CalculateListModel.fromJson(
        {
          'data': data,
          'quantity': quantity,
        },
      ),
    );
  }

  Future<void> readExcel() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (result == null) return;
    setState(() {
      loader = true;
    });
    var file = result.paths.first;
    var bytes = File(file!).readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);
    fetchedData = [];
    log(excel.tables.keys.length.toString());

    for (var table in excel.tables.keys) {
      print(table); //sheet Name
      print(excel.tables[table]!.maxCols);
      print(excel.tables[table]!.maxRows);
      for (var row in excel.tables[table]!.rows) {
        Map dataRow = {};
        for (var cell in row) {
          if (cell?.cellType == CellType.String) {
            if (dataRow['name'] == null) {
              dataRow['name'] = cell?.value.toString();
            }
          } else if (cell?.cellType == CellType.int ||
              cell?.cellType == CellType.double) {
            if (dataRow['quantity'] == null) {
              dataRow['quantity'] =
                  double.tryParse(cell?.value.toString() ?? '') ?? 0.0;
            }
          }
        }
        if (dataRow['name'] != null && dataRow['quantity'] != null) {
          fetchedData.add(dataRow);
        }
      }
    }
    print(fetchedData);

    fetchedData.forEach((element) {
      filteredJsonData.forEach((ingredientData) {
        print(ingredientData['Food Name'] + ' ' + element['name']);

        if (ingredientData['Food Name'] == element['name']) {
          print('fetch...');

          addToList(ingredientData, formatDouble(element['quantity']));
        }
      });
    });
    setState(() {
      loader = false;
    });
  }

  String formatDouble(double value) {
    String formattedValue = value.toStringAsFixed(2);
    return formattedValue.replaceAll(RegExp(r'\.0*$'), '');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadJsonData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: SpeedDial(
          icon: Icons.add,
          activeIcon: Icons.close,
          visible: true,
          curve: Curves.elasticInOut,
          children: [
            // FAB 1
            SpeedDialChild(
              shape: const StadiumBorder(),
              backgroundColor: AppColor.primaryMaterial.shade100,
              child: const Icon(
                Icons.file_download_rounded,
              ),
              onTap: () {
                downloadFormatExcel();
              },
              labelBackgroundColor: AppColor.primaryMaterial.shade100,
              label: 'Sample Excel Format',
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16.0,
              ),
            ),
            SpeedDialChild(
              shape: const StadiumBorder(),
              backgroundColor: AppColor.primaryMaterial.shade100,
              child: const Icon(
                Icons.file_open,
              ),
              onTap: () {
                readExcel();
              },
              labelBackgroundColor: AppColor.primaryMaterial.shade100,
              label: 'Upload Excel',
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16.0,
              ),
            ),
            // FAB 2
            SpeedDialChild(
              shape: const StadiumBorder(),
              backgroundColor: AppColor.primaryMaterial.shade100,
              child: const Icon(Icons.search),
              onTap: () {
                setState(() {
                  showSearchBar = true;
                });
              },
              labelBackgroundColor: AppColor.primaryMaterial.shade100,
              label: 'Search Item',
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16.0,
              ),
            ),
          ],
        ),
        appBar: CustomAppBar(
          showLeading: !showSearchBar,
          title: showSearchBar ? null : 'Calculate',
          titleWidget: showSearchBar
              ? SizedBox(
                  height: 35,
                  child: TypeAheadField(
                    noItemsFoundBuilder: (context) => const SizedBox(),
                    hideOnLoading: false,
                    intercepting: false,
                    minCharsForSuggestions: 1,
                    debounceDuration: const Duration(milliseconds: 0),
                    animationStart: 0,
                    animationDuration: const Duration(milliseconds: 0),
                    hideSuggestionsOnKeyboardHide: false,
                    suggestionsBoxDecoration: const SuggestionsBoxDecoration(
                      color: Colors.white,
                      elevation: 4.0,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: searchController,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(
                              8.0,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              8.0,
                            ),
                          ),
                          enabledBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              borderSide: BorderSide.none),
                          hintText: "Enter food item",
                          contentPadding: EdgeInsets.zero,
                          hintStyle: const TextStyle(
                            color: Color.fromARGB(255, 220, 217, 217),
                            fontSize: 14,
                          ),
                          prefixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                showSearchBar = false;
                              });
                            },
                            icon: const Icon(
                              size: 20,
                              Icons.arrow_back_outlined,
                              color: AppColor.primary,
                            ),
                          ),
                          suffixIcon: IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.search,
                                  color: Color.fromARGB(255, 200, 196, 196))),
                          fillColor: Colors.white,
                          filled: true),
                    ),
                    loadingBuilder: (BuildContext context) {
                      return const SizedBox();
                    },
                    suggestionsCallback: (value) {
                      print('object');
                      return getSuggestions(value);
                    },
                    itemBuilder: (context, suggestion) {
                      return Row(
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Text(
                                suggestion['Food Name'],
                                maxLines: 1,
                                // style: TextStyle(color: Colors.red),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                        ],
                      );
                    },
                    onSuggestionSelected: (suggestion) async {
                      setState(() {
                        searchController.clear();
                        // userSelected.add(suggestion);
                      });
                      await UpdateAlert.showUpdateDialog(
                        context,
                        suggestion,
                        onAdd: addToList,
                        isEdit: false,
                      );
                      setState(() {});
                    },
                  ))
              : null,
        ),
        body: loader
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  if (userSelected.isNotEmpty)
                    Container(
                        height: 35,
                        color: const Color.fromARGB(255, 233, 228, 228),
                        child: const Padding(
                          padding: EdgeInsets.only(left: 10.0, right: 40),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Selected food items",
                                style: TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.w700),
                              ),
                              Text(
                                "Quantity",
                                style: TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.w700),
                              )
                            ],
                          ),
                        )),
                  Expanded(
                    child: userSelected.isEmpty
                        ? Center(
                            child: Text(
                            'Add items to calculate',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600),
                          ))
                        : ListView.builder(
                            itemCount: userSelected.length + 1,
                            itemBuilder: (BuildContext context, int index) {
                              if (index == userSelected.length) {
                                return Center(
                                  child: SizedBox(
                                    width: 150,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 15.0, bottom: 50),
                                      child: GestureDetector(
                                          onTap: () {
                                            Navigator.of(context)
                                                .push(MaterialPageRoute(
                                              builder: (context) =>
                                                  CalculateAnalysisScreen(
                                                      userSelected),
                                            ));
                                          },
                                          child: Card(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Container(
                                                    // color: Colors.teal,

                                                    child:
                                                        const Text('Calculate'),
                                                  ),
                                                  const Icon(
                                                      Icons.chevron_right)
                                                ],
                                              ),
                                            ),
                                          )),
                                    ),
                                  ),
                                );
                              }
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 10,
                                    ),
                                    child: Container(
                                      // height: 32,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: SizedBox(
                                              child: Text(
                                                userSelected[index]
                                                    .data!['Food Name'],
                                                style: const TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 107, 107, 107),
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w500),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Container(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  (double.tryParse(userSelected[
                                                                      index]
                                                                  .quantity!) ??
                                                              '')
                                                          .toString() +
                                                      " gm",
                                                  style: const TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 107, 107, 107),
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Container(
                                                width: 40,
                                                alignment: Alignment.center,
                                                child: IconButton(
                                                  onPressed: () async {
                                                    await UpdateAlert
                                                        .showUpdateDialog(
                                                      context,
                                                      userSelected[index].data!,
                                                      quantity:
                                                          userSelected[index]
                                                              .quantity!,
                                                      isEdit: true,
                                                      onDelete: () {
                                                        userSelected
                                                            .removeAt(index);
                                                      },
                                                      onUpdate:
                                                          (String quantity) {
                                                        setState(() {
                                                          userSelected[index]
                                                                  .quantity =
                                                              quantity;
                                                        });
                                                      },
                                                    );
                                                    setState(() {});
                                                  },
                                                  icon: const Icon(
                                                    Icons.edit,
                                                    size: 13,
                                                    color: AppColor.primary,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Divider(
                                    height: 1,
                                    color: Color.fromARGB(255, 231, 229, 229),
                                  )
                                ],
                              );
                            }),
                  )
                ],
              ));
  }

  List getSuggestions(String searchItem) {
    print('object $jsonData');
    if (searchItem.trim() == '') return [];
    List matches = [];
    matches.addAll(jsonData);
    matches.retainWhere((s) =>
        s['Food Name'].toLowerCase().contains(searchItem.trim().toLowerCase()));
    return matches;
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

  void downloadFormatExcel() async {
    final hasPermission = await getPermission();
    print('hasPermission' + hasPermission.toString());
    if (!hasPermission) return;
    var excel = Excel.createExcel();
    var sheet = excel['Sheet1'];

    sheet.appendRow(['Amaranth seed, black', 100]);
    sheet.appendRow(['Jowar', 120.50]);
    sheet.appendRow(['Papaya, raw', 50.00]);

    final directory2 = Directory('/storage/emulated/0/Download');
    final filePath = '${directory2.path}/Nutricount_sample_excel_format.xlsx';
    final bytes = excel.encode();
    await File(filePath).writeAsBytes(bytes!, mode: FileMode.write);
    Fluttertoast.showToast(
      msg: "Downloaded",
      toastLength: Toast.LENGTH_SHORT,
    );
    print(directory2);
  }
}

String formatDouble(double value) {
  String formattedValue = value.toStringAsFixed(2);
  return formattedValue.replaceAll(RegExp(r'\.0*$'), '');
}
