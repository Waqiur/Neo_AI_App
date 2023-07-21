import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:neo_ai_app/api/payment_api.dart';
import '../const/constants.dart';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

import '../widgets/Button.dart';
import '../widgets/cards.dart';
import '../widgets/main_screen_circle_widget.dart';
import 'audio_transcribe_screen.dart';
import 'chat_screen.dart';
import 'code_generator_screen.dart';
import 'translate_screen.dart';
import 'image_generator_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: Text(
            'Neo',
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: 0.6),
          ),
        ),
        elevation: 2,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: GestureDetector(
            child: const Icon(Icons.logout),
            onTap: () async {
              Navigator.pushNamed(context, '/LoginScreen');
              await FirebaseAuth.instance.signOut();
            },
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 10.0, right: 20),
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: DarkModeColors.backgroundColor,
                    title: Text(
                      'Buy Premium',
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
                            'Remaining Credits : 50',
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
                            text: "Buy more Credits",
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
              child: Icon(
                Icons.diamond,
                size: 26.0,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),
            ZoomIn(
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Center(
                  child: ContainerAnimation(
                    nextScreen: const ChatScreen(),
                    prevScreen: MainScreenCircleWidget(),
                  ),
                ),
              ),
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.only(left: 20, top: 20, bottom: 20),
              child: Text(
                'Explore',
                style: TextStyle(
                  color: DarkModeColors.primaryTextColor,
                  fontSize: 35,
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: FadeInRight(
                child: IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ContainerAnimation(
                        nextScreen: const CodeGeneratorScreen(),
                        prevScreen: Cards(
                          text: 'Code Generator',
                          image: 'assets/images/coding.png',
                          description:
                              'Generate efficient and complex code of various languages in a single click',
                        ),
                      ),
                      ContainerAnimation(
                        nextScreen: const ImageGeneratorScreen(),
                        prevScreen: Cards(
                          text: 'Image Creator',
                          image: 'assets/images/picture.png',
                          description:
                              'Empower your creativity and effortlessly turn ideas into captivating images',
                        ),
                      ),
                      ContainerAnimation(
                        nextScreen: const AudioTranscribeScreen(),
                        prevScreen: Cards(
                          text: 'Audio Transcript',
                          image: 'assets/images/audio-book.png',
                          description:
                              'Convert audio recordings into Rich written Text in an efficient way.',
                        ),
                      ),
                      ContainerAnimation(
                        nextScreen: const TranslateScreen(),
                        prevScreen: Cards(
                          text: 'Translator',
                          image: 'assets/images/translation.png',
                          description:
                              'Translate text from English to other languages',
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      )
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );
  }
}

class ContainerAnimation extends StatelessWidget {
  const ContainerAnimation(
      {super.key, required this.nextScreen, required this.prevScreen});

  final Widget nextScreen;
  final Widget prevScreen;
  final transitionType = ContainerTransitionType.fade;

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      closedColor: DarkModeColors.backgroundColor,
      openColor: DarkModeColors.backgroundColor,
      transitionType: transitionType,
      transitionDuration: const Duration(milliseconds: 500),
      openBuilder: (context, _) => nextScreen,
      closedBuilder: (context, VoidCallback openContainer) => prevScreen,
    );
  }
}
