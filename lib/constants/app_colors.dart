import 'package:flutter/material.dart';

class AppColor {
  AppColor._();

  static const Color primary = Color(0xff1B317D);
  static const MaterialColor primaryMaterial = MaterialColor(
    0xff1B317D, // 0% comes in here, this will be color picked if no shade is selected when defining a Color property which doesn’t require a swatch.
    <int, Color>{
      50: Color(0xffe8eaf2), //10%
      100: Color(0xffd1d6e5), //20%
      200: Color(0xff8d98be), //30%
      300: Color(0xff5f6fa4), //40%
      400: Color(0xff495a97), //50%
      500: Color(0xff32468a), //60%
      600: Color(0xff182c71), //70%
      700: Color(0xff162764), //80%
      800: Color(0xff132258), //90%
      900: Color(0xff0e193f), //100%
    },
  );
  static final Color primary20 = const Color(0xff1B317D).withOpacity(0.2);
}
