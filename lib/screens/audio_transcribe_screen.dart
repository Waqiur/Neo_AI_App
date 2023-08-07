import 'dart:async';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import '../api/api_key.dart';
import '../const/constants.dart';
import '../firestore/queries.dart';
import '../widgets/Button.dart';
import '../widgets/credit_alert_dialog.dart';

class AudioTranscribeScreen extends StatefulWidget {
  const AudioTranscribeScreen({super.key});

  @override
  State<AudioTranscribeScreen> createState() => _AudioTranscribeScreenState();
}

class _AudioTranscribeScreenState extends State<AudioTranscribeScreen>
    with TickerProviderStateMixin {
  TextEditingController answerController = TextEditingController();
  late final AnimationController animationController;

  OpenAI? openAI;
  StreamSubscription? subscription;
  bool showSpinnerContainer = false;
  bool responseContainer = false;
  bool showDefaultContainer = true;
  bool fileSelected = false;
  String fileName = "";
  String filePath = "";
  FilePickerResult? file;

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
    answerController.dispose();
    subscription?.cancel();
    animationController.dispose();
    super.dispose();
  }

  void audioTranscribe() async {
    int credits = Get.find<AddData>().getCreditValue.value;
    if (credits == 0) {
      showSpinnerContainer = false;
      responseContainer = false;
      showDefaultContainer = true;
      CreditAlertDialog().checkCredits(context, "Not Enough Credits");
      return;
    }
    var url = Uri.https("api.openai.com", "v1/audio/transcriptions");
    var request = http.MultipartRequest('POST', url);
    request.headers.addAll(({"Authorization": "Bearer $openAIApiKey"}));
    request.fields["model"] = 'whisper-1';
    request.fields["language"] = "en";
    request.files.add(await http.MultipartFile.fromPath('file', filePath));
    var response = await request.send();
    var newResponse = await http.Response.fromStream(response);
    final responseData = json.decode(newResponse.body);
    answerController.value = TextEditingValue(
      text: responseData['text'],
      selection: TextSelection.fromPosition(
        TextPosition(offset: responseData['text'].length),
      ),
    );
    Get.find<AddData>()
        .updateUserData(FirebaseAuth.instance.currentUser!.email!, false);
    if (fileSelected == true) {
      setState(() {
        showSpinnerContainer = false;
        responseContainer = true;
        showDefaultContainer = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: Text(
            'Transcript Generator',
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: 0.6),
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
            if (fileName == "") {
              return;
            }
            setState(() {
              showSpinnerContainer = true;
              responseContainer = false;
              showDefaultContainer = false;
            });
            audioTranscribe();
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
            'Generate',
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
                height: MediaQuery.of(context).size.height * 0.6,
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
                        'assets/images/transcription.png',
                        width: 50,
                        height: 50,
                        color: Colors.grey,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25.0),
                        child: Text(
                          "Your generated transcript will be shown here.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontSize: 25),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (showSpinnerContainer)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                height: MediaQuery.of(context).size.height * 0.6,
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
                height: MediaQuery.of(context).size.height * 0.6,
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
                  text: 'Copy Text',
                  icon: Icons.copy,
                  onPressed: () {
                    if (answerController.text == "" ||
                        fileSelected == false ||
                        showDefaultContainer == true) {
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
                Button(
                  text: 'Reset Data',
                  icon: Icons.restart_alt,
                  onPressed: () {
                    setState(() {
                      showDefaultContainer = true;
                      fileSelected = false;
                    });
                  },
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
      child: fileSelected
          ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: const Radius.circular(30),
                  bottomRight: const Radius.circular(30),
                ),
                color: DarkModeColors.textFieldColor,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                ),
                child: Center(
                  child: Text(
                    fileName,
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
            )
          : GestureDetector(
              onTap: () async {
                file = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: [
                      'mp3',
                      'mp4',
                      'mpeg',
                      'mpg',
                      'm4a',
                      'wav',
                      'webm'
                    ]);
                if (file == null) {
                  return;
                }
                fileName = file!.files.first.name;
                filePath = file!.files.first.path!;
                setState(() {
                  fileSelected = true;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20).copyWith(
                    bottomLeft: const Radius.circular(30),
                    bottomRight: const Radius.circular(30),
                  ),
                  color: DarkModeColors.textFieldColor,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/microphone.png',
                        width: 30,
                        height: 30,
                        color: Colors.grey,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25.0),
                        child: Text(
                          "Select Audio File",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontSize: 23,
                          ),
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
