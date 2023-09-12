import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nutricount/constants/app_colors.dart';

class HomeCard extends StatelessWidget {
  const HomeCard({
    super.key,
    required this.img,
    required this.title,
    required this.onTap,
  });

  final String img;
  final String title;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    // double h = MediaQuery.of(context).size.height;
    // double w = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
          child: Row(
            // crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Container(
              //   height: 65,
              //   width: 75,

              //   // child: Image.network(
              //   //   "https://www.nifa.usda.gov/sites/default/files/styles/basic_page_top_image_desktop/public/2022-07/AdobeStock_442032402.jpg?itok=V-rweDsJ",
              //   //   fit: BoxFit.contain,
              //   // ),
              //   decoration: BoxDecoration(
              //       color: Colors.white,
              //       image: DecorationImage(
              //           fit: BoxFit.fill,
              //           image: NetworkImage(
              //             img,
              //           )),
              //       // color: Colors.amber,
              //       borderRadius: const BorderRadius.all(Radius.circular(10)),
              //       boxShadow: const [
              //         BoxShadow(
              //           blurRadius: 7,
              //           spreadRadius: 1,
              //           // color: Color.fromARGB(255, 102, 103, 103)
              //         )
              //       ]),
              // ),
              SvgPicture.asset(
                img,
                height: 50,
                width: 50,
                color: AppColor.primary,
              ),

              Expanded(
                  // height: 75,
                  // width: w - 130,
                  // alignment: Alignment.center,
                  // color: Colors.green,
                  child: Center(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    color: AppColor.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )),
              const SizedBox(
                width: 50,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
