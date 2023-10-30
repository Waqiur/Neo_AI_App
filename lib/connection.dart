
import 'package:flutter/material.dart';

import '../const/constants.dart';

class Cards extends StatelessWidget {
  String text;
  String image;
  String description;

  Cards(
      {super.key,
      required this.text,
      required this.image,
      required this.description});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      margin: const EdgeInsets.only(left: 10),
      width: screenWidth * 0.44,
      decoration: BoxDecoration(
        color: DarkModeColors.cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15)
            .copyWith(top: 15, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              image,
              height: 55,
              width: 55,
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              text,
              style: const TextStyle(
                  color: DarkModeColors.primaryTextColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(
              height: 6,
            ),
            Text(
              description,
              style: const TextStyle(
                color: DarkModeColors.secondaryTextColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
