import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../const/constants.dart';

class MainScreenCircleWidget extends StatelessWidget {
  MainScreenCircleWidget({super.key});

  String? username = FirebaseAuth.instance.currentUser!.displayName;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.44,
      width: MediaQuery.of(context).size.height * 0.44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(350),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0x100e0e10),
            Color(0xFF323134),
          ],
          stops: [0.05, 1],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(
            height: 110,
          ),
          Text(
            'Hi, ${username?.substring(0, username?.indexOf(' '))}',
            style: const TextStyle(
                color: DarkModeColors.secondaryTextColor,
                fontSize: 20,
                fontWeight: FontWeight.w400),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            'Tap to Chat',
            style: TextStyle(
              color: DarkModeColors.primaryTextColor,
              fontSize: 35,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
