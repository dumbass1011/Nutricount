import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:nutricount/models/nutri_data_model.dart';
import 'package:nutricount/models/nutrients_model.dart';

import '../../widgets/custom_appbar.dart';

class NutrientDetails extends StatefulWidget {
  const NutrientDetails({
    super.key,
    required this.jsonData,
    required this.selectedNutrient,
  });
  final List jsonData;
  final NutrientsModel selectedNutrient;

  @override
  State<NutrientDetails> createState() => _NutrientDetailsState();
}

class _NutrientDetailsState extends State<NutrientDetails> {
  TextEditingController searchController = TextEditingController();
  TextEditingController filterController = TextEditingController(text: '100');

  @override
  void initState() {
    super.initState();
    processData();
  }

  List<NutriDataModel> filterdNutrientsList = [];
  List<NutriDataModel> nutrientsList = [];

  filterList() {
    List<NutriDataModel> toRemove = [];
    filterdNutrientsList = [];
    filterdNutrientsList.addAll(nutrientsList);
    if (searchController.text.trim() != '') {
      nutrientsList.forEach((element) {
        if (!element.title!
            .toLowerCase()
            .contains(searchController.text.trim())) {
          toRemove.add(element);
        }
      });
    }
    filterdNutrientsList.removeWhere((e) => toRemove.contains(e));
    setState(() {});
  }

  processData() {
    widget.jsonData.forEach((element) {
      if ((element as Map).containsKey(widget.selectedNutrient.key)) {
        log(element[widget.selectedNutrient.key!].toString());
        final nutriData = getNutriData(
            key: widget.selectedNutrient.title ?? '',
            value: double.tryParse(
                    element[widget.selectedNutrient.key!].toString()) ??
                0.0,
            title: element['Food Name']);
        nutrientsList.add(NutriDataModel.fromJson(nutriData));
      }
      nutrientsList.sort((a, b) {
        var aValue = a.value;
        var bValue = b.value;
        if (a.unit == 'mg') {
          aValue = aValue! / 1000;
        } else if (a.unit == 'mcg') {
          aValue = aValue! / 1000000;
        }
        if (b.unit == 'mg') {
          bValue = bValue! / 1000;
        } else if (b.unit == 'mcg') {
          bValue = bValue! / 1000000;
        }
        return bValue!.compareTo(aValue!);
      });
    });

    filterList();
  }

  Map<String, dynamic> getNutriData({
    required String key,
    required double value,
    required String title,
  }) {
    double newValue = value;
    String unit = 'gm';
    if (widget.selectedNutrient.title == 'Energy') {
      return {'title': title, 'value': value, 'unit': 'kJ'};
    }
    if (value == 0) {
      return {'title': title, 'value': newValue, 'unit': unit};
    }
    if (value < 0.01) {
      newValue = value * 1000;
      unit = 'mg';
      if (newValue < 0.01) {
        newValue = value * 1000000;
        unit = 'mcg';
      }
    }
    return {'title': title, 'value': newValue, 'unit': unit};
  }

  String formatDouble(double value) {
    String formattedValue = value.toStringAsFixed(2);
    return formattedValue.replaceAll(RegExp(r'\.0*$'), '');
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return Scaffold(

        //---appbar---

        appBar: CustomAppBar(title: widget.selectedNutrient.title!),
        body: Column(
          children: [
            Container(
              color: const Color.fromARGB(134, 187, 181, 181),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: SizedBox(
                        child: Text(
                          "Nutrients",
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    SizedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text("per  "),

                          //----filter---

                          Container(
                            width: 60,
                            height: 25,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4)),
                            child: TextField(
                              controller: filterController,
                              onChanged: (value) {
                                setState(() {});
                              },
                              keyboardType: TextInputType.number,
                              cursorColor:
                                  const Color.fromARGB(255, 139, 139, 139),
                              decoration: const InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 3),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color:
                                            Color.fromARGB(255, 66, 67, 67))),
                                border: OutlineInputBorder(),
                              ),
                              style: const TextStyle(fontSize: 12),
                              textAlignVertical: TextAlignVertical.center,
                              textAlign: TextAlign.center,
                            ),
                          ),

                          const Text("  gm")
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            //---searchfield---
            SizedBox(
                height: h * .05,
                child: TextField(
                    controller: searchController,
                    onChanged: (value) {
                      filterList();
                    },
                    textAlignVertical: TextAlignVertical.center,
                    cursorColor: const Color.fromARGB(255, 139, 139, 139),
                    decoration: InputDecoration(
                        border: const OutlineInputBorder(
                            borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.only(top: 0),
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 24,
                          color: Color.fromARGB(255, 206, 206, 206),
                        ),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  size: 22,
                                  color: Color.fromARGB(255, 138, 137, 137),
                                ),
                                onPressed: () {
                                  searchController.clear();
                                  filterList();
                                },
                              )
                            : null,
                        hintStyle: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                            color: Color.fromARGB(255, 182, 180, 180)),
                        hintText: "Search here"))),
            const Divider(
              height: 1,
              color: Color.fromARGB(255, 218, 216, 216),
            ),
            //---item list
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
}
