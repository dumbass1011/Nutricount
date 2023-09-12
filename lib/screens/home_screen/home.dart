import 'package:flutter/material.dart';
import 'package:nutricount/screens/Ingredients_screen/ingredients.dart';
import 'package:nutricount/screens/calculator_screen/calculate_screen.dart';
import 'package:nutricount/screens/nutrients_screen/nutrients.dart';

import '../../widgets/custom_appbar.dart';
import '../../widgets/home_card.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Nutricount",
        showLeading: false,
      ),
      body: Padding(
          padding: const EdgeInsets.only(left: 6, top: 20, right: 3),
          child: Column(
            children: [
              HomeCard(
                  img: 'assets/icons/ingredients.svg',
                  title: 'Ingredients',
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const Ingredients(),
                    ));
                  }),
              HomeCard(
                  img: 'assets/icons/nutrients.svg',
                  title: 'Nutrients',
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const Nutrients(),
                    ));
                  }),
              HomeCard(
                  img: 'assets/icons/calculator.svg',
                  title: 'Calculator',
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const CalculateScreen(),
                    ));
                  })
            ],
          )),
    );
  }
}
