import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:nutricount/models/nutrients_model.dart';
import 'package:nutricount/screens/nutrients_details_screen/nutrient_details.dart';

import '../../widgets/custom_appbar.dart';

class Nutrients extends StatefulWidget {
  const Nutrients({super.key});

  @override
  State<Nutrients> createState() => _NutrientsState();
}

class _NutrientsState extends State<Nutrients> {
  TextEditingController searchController = TextEditingController();
  List<dynamic> jsonData = [];
  List<NutrientsModel> filteredNutrientList = [];
  List<NutrientsModel> nutrientList = [];
  Map map = {};

  Future<void> loadJsonData() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/local_database/data.json');
      final map = json.decode(jsonString);
      final List data = map['Data'];

      final values = data.first.values;
      final keys = data.first.keys;
      for (var index = 0; index < data.first.length; index++) {
        if (double.tryParse(values.elementAt(index).toString()) != null &&
            keys.elementAt(index).toString() != 'No. of Regions') {
          final nutrient = {
            'key': keys.elementAt(index),
            'title': keys.elementAt(index).toString().split(';').first,
          };
          nutrientList.add(NutrientsModel.fromJson(nutrient));
        }
      }
      log(nutrientList.toString());

      setState(() {
        jsonData = data;
      });
      log(jsonData.length.toString());
      filterData();
    } catch (e) {
      print('Error loading JSON file: $e');
    }
  }

  filterData() {
    List<NutrientsModel> filterData = [];
    filterData.addAll(nutrientList);
    List toRemove = [];
    final searchText = searchController.text.trim();

    log(toRemove.length.toString());

    if (searchText != '') {
      filterData.forEach((element) {
        if (!element.title
            .toString()
            .toLowerCase()
            .contains(searchText.toLowerCase())) {
          toRemove.add(element);
        }
      });
    }
    log(toRemove.length.toString());
    filterData.removeWhere((e) => toRemove.contains(e));
    setState(() {
      filteredNutrientList = filterData;
    });
  }

  String? dropdownvalue;

  @override
  void initState() {
    super.initState();
    loadJsonData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //---appbar---
      appBar: CustomAppBar(title: "Nutrients"),

      body: Column(
        children: [
          SizedBox(
            height: 34,
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                filterData();
              },
              textAlignVertical: TextAlignVertical.center,
              cursorColor: const Color.fromARGB(255, 139, 139, 139),
              decoration: InputDecoration(
                  border: const OutlineInputBorder(borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.only(top: 0),
                  prefixIcon: const Icon(
                    Icons.search,
                    size: 24,
                    color: Color.fromARGB(255, 139, 139, 139),
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
                            filterData();
                          },
                        )
                      : null,
                  hintStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(255, 217, 215, 215)),
                  hintText: "Search for Nutrients"),
            ),
          ),
          const Divider(
            height: 1,
            color: Color.fromARGB(255, 218, 216, 216),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: filteredNutrientList.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                color: Color.fromARGB(255, 218, 216, 216),
              ),
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => NutrientDetails(
                          jsonData: jsonData,
                          selectedNutrient: filteredNutrientList[index]),
                    ));
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Container(
                      alignment: Alignment.centerLeft,
                      height: 36,
                      child: Text(
                        filteredNutrientList[index].title ?? '',
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
