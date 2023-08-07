import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neo_ai_app/screens/chat_screen.dart';
import 'package:neo_ai_app/screens/image_generator_screen.dart';
import 'package:neo_ai_app/screens/login_screen.dart';
import 'const/constants.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Stripe.publishableKey = 'pk_test_51LUoXFSFZr9iiMusfy79W2DbTsDF57LsxygeqSArcCKZxZSp6JDUVH9RnrKlrxfEu9T2MnBQd0rp20f0V6hQc7fL0014oS9xLr';
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ChatBot',
      theme: ThemeData(
        textTheme:
            GoogleFonts.varelaRoundTextTheme(Theme.of(context).textTheme),
        scaffoldBackgroundColor: DarkModeColors.backgroundColor,
        appBarTheme: const AppBarTheme(
          color: DarkModeColors.backgroundColor,
          systemOverlayStyle:
              SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
        ),
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const HomeScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
      routes: {
        '/HomeScreen': (context) => const HomeScreen(),
        '/ChatScreen': (context) => const ChatScreen(),
        '/ImageGeneratorScreen': (context) => const ImageGeneratorScreen(),
        '/LoginScreen': (context) => const LoginScreen(),
      },
    );
  }
}
