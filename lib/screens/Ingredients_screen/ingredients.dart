import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:nutricount/constants/app_colors.dart';
import 'package:nutricount/screens/ingredient_details_screen/ingredient_details.dart';

import '../../widgets/custom_appbar.dart';

class Ingredients extends StatefulWidget {
  const Ingredients({super.key});

  @override
  State<Ingredients> createState() => _IngredientsState();
}

class _IngredientsState extends State<Ingredients> {
  TextEditingController searchController = TextEditingController();
  List<dynamic> filteredJsonData = [];
  List<dynamic> jsonData = [];
  List<String> categoryList = [];
  List<String> tabbarCategoryList = ["All"];
  int current = 0;
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
        tabbarCategoryList.addAll(categoryList);
      });
      log(jsonData.length.toString());
      // filterData();
    } catch (e) {
      print('Error loading JSON file: $e');
    }
  }

  filterData() {
    List filterData = [];
    filterData.addAll(jsonData);
    List toRemove = [];
    // filterData.addAll(jsonData);
    final searchText = searchController.text.trim();
    if (dropdownvalue != null) {
      filterData.forEach((element) {
        if (element['Food Group'] != dropdownvalue) {
          toRemove.add(element);
        }
      });
    }
    log(toRemove.length.toString());

    if (searchText != '') {
      // filterData = jsonData;

      filterData.forEach((element) {
        if (!element['Food Name']
            .toString()
            .toLowerCase()
            .contains(searchText.toLowerCase())) {
          if (!toRemove.contains(element)) {
            toRemove.add(element);
          }
        }
      });
    }
    log(toRemove.length.toString());
    filterData.removeWhere((e) => toRemove.contains(e));
    setState(() {
      filteredJsonData = filterData;
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
      appBar: CustomAppBar(title: "Ingredients"),
      body: Column(
        children: [
          Container(
            color: AppColor.primaryMaterial,
            width: double.infinity,
            height: 35,
            child: ListView.separated(
                itemCount: tabbarCategoryList.length,
                separatorBuilder: (context, index) => Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        margin: const EdgeInsets.only(top: 10),
                        height: 16,
                        width: .5,
                        color: Colors.grey,
                      ),
                    ),
                scrollDirection: Axis.horizontal,
                itemBuilder: (ctx, index) {
                  return Padding(
                    padding:
                        const EdgeInsets.only(left: 10.0, right: 10, top: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              current = index;
                              if (index != 0) {
                                dropdownvalue = tabbarCategoryList[index];
                                // print(dropdownvalue);
                                filterData();
                              } else {
                                dropdownvalue = null;
                                filteredJsonData = jsonData;
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 25,
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                              borderRadius: current == index
                                  ? BorderRadius.circular(12)
                                  : BorderRadius.circular(8),
                            ),
                            child: Text(
                              tabbarCategoryList[index],
                              style: TextStyle(
                                  fontSize: current == index ? 16 : 15,
                                  fontWeight: current == index
                                      ? FontWeight.w900
                                      : FontWeight.w500,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                        Visibility(
                            visible: current == index,
                            child: Container(
                              constraints: const BoxConstraints(
                                  minWidth: 15, maxWidth: 40),
                              width: (dropdownvalue?.length ?? 0) * 5,
                              height: 3,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                ),
                              ),
                            ))
                      ],
                    ),
                  );
                }),
          ),

          //---search field---
          Container(
            height: 34,
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                filterData();
              },
              textAlignVertical: TextAlignVertical.center,
              cursorColor: const Color.fromARGB(255, 139, 139, 139),
              // cursorHeight: 22,
              decoration: InputDecoration(
                  isDense: true,
                  border: const OutlineInputBorder(borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.only(top: 0),
                  prefixIcon: const Icon(
                    Icons.search,
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
                  hintText: "Search for Ingredients"),
            ),
          ),
          const Divider(
            height: 1,
            color: Color.fromARGB(255, 218, 216, 216),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: filteredJsonData.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                color: Color.fromARGB(255, 218, 216, 216),
              ),
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          IngredientDetails(data: filteredJsonData[index]),
                    ));
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Container(
                      alignment: Alignment.centerLeft,
                      height: 36,
                      child: Text(
                        filteredJsonData[index]['Food Name'],
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
