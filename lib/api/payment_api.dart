import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:neo_ai_app/api/api_key.dart';

import '../const/constants.dart';
import '../firestore/queries.dart';

class Payment {
  String url = 'https://api.stripe.com/v1/payment_intents';
  Map<String, dynamic>? paymentIntentData;

  Future<bool> makePayment(BuildContext context) async {
    try {
      paymentIntentData = await createPaymentIntent("20", "INR");
      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: paymentIntentData!['client_secret'],
        style: ThemeMode.dark,
        merchantDisplayName: 'Neo',
      ));
      displayPaymentSheet(context);
      paymentIntentData = null;
      return true;
    } catch (e) {
      return false;
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': (int.parse(amount) * 100).toString(),
        'currency': currency,
        'payment_method_types[]': 'card'
      };
      var response = await http.post(Uri.parse(url), body: body, headers: {
        'Authorization': 'Bearer $stripeAPIKey',
        'Content-Type': 'application/x-www-form-urlencoded'
      });
      return json.decode(response.body);
    } catch (e) {
      print(e.toString());
    }
  }

  displayPaymentSheet(BuildContext context) async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        Stripe.instance.confirmPaymentSheetPayment();
        Get.find<AddData>()
            .updateUserData(FirebaseAuth.instance.currentUser!.email!, true);
        showDialog(
            context: context,
            builder: (dialogContext) {
              Future.delayed(const Duration(seconds: 3), () {
                Navigator.of(dialogContext).pop(true);
              });
              return const AlertDialog(
                backgroundColor: DarkModeColors.cardColor,
                content: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 35,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Payment Successful",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    )
                  ],
                ),
              );
            });
      });
    } catch (e) {
      print(e.toString());
    }
  }
}
