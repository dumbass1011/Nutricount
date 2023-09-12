import 'package:flutter/material.dart';

bool isPress = false;

class UpdateAlert {
  static Future showUpdateDialog(
    BuildContext context,
    Map item, {
    required bool isEdit,
    Function(Map data, String quantity)? onAdd,
    Function()? onDelete,
    Function(String quantity)? onUpdate,
    String? quantity,
  }) async {
    TextEditingController filterController =
        TextEditingController(text: isEdit ? quantity : '100');
    return await showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            titlePadding: EdgeInsets.zero,
            contentPadding: EdgeInsets.zero,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Text(
                        item['Food Name'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Enter Quantity",
                            style: TextStyle(
                                color: Color.fromARGB(255, 41, 41, 41),
                                fontSize: 13,
                                fontWeight: FontWeight.w700),
                          ),
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4)),
                                height: 25,
                                width: 80,
                                child: TextField(
                                  controller: filterController,
                                  keyboardType: TextInputType.number,
                                  cursorColor:
                                      const Color.fromARGB(255, 139, 139, 139),
                                  decoration: const InputDecoration(
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 3),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color.fromARGB(
                                                255, 66, 67, 67))),
                                    border: OutlineInputBorder(),
                                  ),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11),
                                  textAlignVertical: TextAlignVertical.center,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const Text(
                                " gm",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 38, 37, 37),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500),
                              )
                            ],
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      )
                    ],
                  ),
                ),
              ],
            ),
            actionsPadding: EdgeInsets.zero,
            actions: [
              Container(
                // height: 40,
                // padding: const EdgeInsets.all(10),

                // color: Colors.amber,
                decoration: const BoxDecoration(
                    // color: Colors.white,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8))),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (isEdit)
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            if (onDelete != null) {
                              onDelete();
                            }
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 35,
                            // width: 100,
                            alignment: Alignment.center,
                            // color: Color.fromARGB(255, 30, 31, 35),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "Remove Item",
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          if (isEdit && onUpdate != null) {
                            onUpdate(filterController.text);
                          } else if (onAdd != null) {
                            onAdd(item, filterController.text);
                          }
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          height: 35,
                          // width: 100,
                          alignment: Alignment.center,
                          // color: Color.fromARGB(255, 13, 146, 141),
                          decoration: BoxDecoration(
                            color: isEdit ? Colors.green : Colors.black,
                            borderRadius: BorderRadius.only(
                                bottomRight: const Radius.circular(10),
                                bottomLeft: Radius.circular(isEdit ? 0 : 10)),
                          ),
                          child: Text(
                            isEdit ? "Update Item" : "Add to List",
                            style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }
}
