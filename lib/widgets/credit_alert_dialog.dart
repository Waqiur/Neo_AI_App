import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../api/payment_api.dart';
import '../const/constants.dart';
import '../firestore/queries.dart';
import 'Button.dart';

class CreditAlertDialog {
  checkCredits(BuildContext context, String text) async {
    showDialog(
      context: context,
      builder: (context) => Obx(
        () => AlertDialog(
          backgroundColor: DarkModeColors.backgroundColor,
          title: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          content: Container(
            height: 130,
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Remaining Credits: ' +
                      Get.find<AddData>().getCreditValue.value.toString(),
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(
                  height: 30,
                ),
                Button(
                  icon: Icons.credit_score,
                  onPressed: () {
                    Payment().makePayment(context);
                  },
                  text: "Buy 50 Credits",
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
