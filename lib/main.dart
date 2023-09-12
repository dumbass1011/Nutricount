import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutricount/constants/app_colors.dart';
import 'package:nutricount/screens/home_screen/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nutricount',
      theme: ThemeData(
        textTheme: GoogleFonts.latoTextTheme(
          Theme.of(context).textTheme,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColor.primaryMaterial,
        ),
        useMaterial3: true,
        primarySwatch: AppColor.primaryMaterial,
      ),
      home: Home(),
    );
  }
}
