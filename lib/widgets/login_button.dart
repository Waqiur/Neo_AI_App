import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginButton extends StatelessWidget {
  LoginButton({super.key, required this.logo, required this.text});

  String logo;
  String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: () async {
          GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
          GoogleSignInAuthentication? googleAuth =
              await googleUser?.authentication;
          AuthCredential credential = GoogleAuthProvider.credential(
              accessToken: googleAuth?.accessToken,
              idToken: googleAuth?.idToken);
          UserCredential userCredential =
              await FirebaseAuth.instance.signInWithCredential(credential);
          if (userCredential.user != null) {
            Navigator.pushNamed(context, '/HomeScreen');
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ).copyWith(
          overlayColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed)) return Colors.grey;
              return null;
            },
          ),
        ),
        child: SizedBox(
          height: 60,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              children: [
                Image.asset(
                  logo,
                  width: 40,
                  height: 40,
                ),
                const SizedBox(
                  width: 20,
                ),
                Text(
                  text,
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 25,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
