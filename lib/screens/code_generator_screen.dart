import 'dart:async';
import '../const/constants.dart';
import 'package:flutter/material.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../api/api_key.dart';
import '../widgets/Button.dart';

class CodeGeneratorScreen extends StatefulWidget {
  const CodeGeneratorScreen({super.key});

  @override
  State<CodeGeneratorScreen> createState() => _CodeGeneratorScreenState();
}

class _CodeGeneratorScreenState extends State<CodeGeneratorScreen>
    with TickerProviderStateMixin {
  final TextEditingController controller = TextEditingController();
  TextEditingController answerController = TextEditingController();
  late final AnimationController animationController;

  OpenAI? openAI;
  StreamSubscription? subscription;
  bool showSpinnerContainer = false;
  bool responseContainer = false;
  bool showDefaultContainer = true;
  List<String> languages = ["Java", "C++", "C", "Python", "Dart", "JavaScript"];
  String selectedLanguage = "Java";

  @override
  void initState() {
    super.initState();
    openAI = OpenAI.instance.build(
      token: openAIApiKey,
      baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 60)),
      enableLog: true,
    );
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    answerController.dispose();
    subscription?.cancel();
    animationController.dispose();
    super.dispose();
  }

  void sendPrompt() async {
    final request = ChatCompleteText(
      messages: [
        Messages(
            role: Role.user,
            content: "write $selectedLanguage code for: ${controller.text}")
      ],
      maxToken: 200,
      model: GptTurbo0301ChatModel(),
    );
    final response = await openAI?.onChatCompletion(request: request);
    String responseText = response!.choices[0].message!.content;
    String extractedText =
        responseText.substring(responseText.indexOf('`') + 3);
    extractedText = extractedText.substring(0, extractedText.indexOf('`') - 1);
    answerController.value = TextEditingValue(
      text: extractedText,
      selection: TextSelection.fromPosition(
        TextPosition(offset: extractedText.length),
      ),
    );
    setState(() {
      showSpinnerContainer = false;
      responseContainer = true;
      showDefaultContainer = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: Text(
            'Code Generator',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ),
        elevation: 2,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: GestureDetector(
            child: const Icon(Icons.arrow_back),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      bottomNavigationBar: Container(
        width: double.infinity,
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 10).copyWith(bottom: 10),
        child: ElevatedButton(
          onPressed: () {
            FocusManager.instance.primaryFocus?.unfocus();
            if (controller.text == "") {
              return;
            }
            setState(() {
              showSpinnerContainer = true;
              showDefaultContainer = false;
              showSpinnerContainer = true;
            });
            sendPrompt();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            elevation: 2,
            shadowColor: Colors.grey,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ).copyWith(
            overlayColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.pressed)) {
                  return Colors.grey.shade300;
                }
                return null;
              },
            ),
          ),
          child: const Text(
            'Generate Code',
            style: TextStyle(
                fontSize: 23, fontWeight: FontWeight.w900, color: Colors.black),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (showDefaultContainer)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                height: MediaQuery.of(context).size.height * 0.42,
                width: 396.8,
                decoration: BoxDecoration(
                  color: DarkModeColors.textFieldColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/code_generator.png',
                        width: 50,
                        height: 50,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        "Your Generated code will be shown here.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontSize: 25),
                      ),
                    ],
                  ),
                ),
              )
            else if (showSpinnerContainer)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                height: MediaQuery.of(context).size.height * 0.42,
                width: 396.8,
                decoration: BoxDecoration(
                  color: DarkModeColors.textFieldColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SpinKitCircle(
                  color: Colors.white,
                  size: 50.0,
                  controller: animationController,
                ),
              )
            else if (responseContainer)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                height: MediaQuery.of(context).size.height * 0.42,
                width: 396.8,
                decoration: BoxDecoration(
                  color: DarkModeColors.textFieldColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  controller: answerController,
                  decoration: const InputDecoration(
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
              ),
            Row(
              children: [
                const SizedBox(
                  width: 10,
                ),
                Button(
                  text: 'Copy Code',
                  icon: Icons.copy,
                  onPressed: () {
                    if (answerController.text == "") {
                      return;
                    }
                    Clipboard.setData(
                            ClipboardData(text: answerController.text))
                        .then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.transparent,
                          content: Center(
                            child: Text('Copied to Clipboard!'),
                          ),
                        ),
                      );
                    });
                  },
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: DropDownWidget(selectedLanguage, (newValue) {
                    setState(() {
                      selectedLanguage = newValue!;
                    });
                  }, languages[1]),
                ),
                const SizedBox(
                  width: 10,
                ),
              ],
            ),
            Expanded(child: BottomMessageScreen()),
          ],
        ),
      ),
    );
  }

  Widget BottomMessageScreen() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0).copyWith(bottom: 5),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomLeft: const Radius.circular(30),
            bottomRight: const Radius.circular(30),
          ),
          color: DarkModeColors.textFieldColor,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: TextField(
            keyboardType: TextInputType.multiline,
            maxLines: null,
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
            ),
            controller: controller,
            decoration: const InputDecoration(
              hintText: "Type a prompt ...",
              hintStyle: TextStyle(color: Colors.grey),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget DropDownWidget(String language, Function(String? value) onChanged,
      String defaultLanguage) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      height: 50,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          color: Colors.grey.shade900, borderRadius: BorderRadius.circular(30)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          isExpanded: true,
          dropdownColor: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(20),
          value: language.isNotEmpty ? language : defaultLanguage,
          items: languages.map((String items) {
            return DropdownMenuItem(
              value: items,
              child: Text(
                items,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
