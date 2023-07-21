import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import '../const/constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

import '../api/api_key.dart';
import '../widgets/Button.dart';

class ImageGeneratorScreen extends StatefulWidget {
  const ImageGeneratorScreen({super.key});

  @override
  State<ImageGeneratorScreen> createState() => _ImageGeneratorScreenState();
}

class _ImageGeneratorScreenState extends State<ImageGeneratorScreen>
    with TickerProviderStateMixin {
  final TextEditingController controller = TextEditingController(
      text:
          "A Cosmic Exploration of the Universe, With a Cannabis Plants Everywhere, View of Planets, Nebula, Moons, and Cosmic Phenomena, Rendered in 8K Resolution, V Ray");
  late final AnimationController animationController;

  OpenAI? openAI;
  StreamSubscription? subscription;
  bool isSent = false;
  String receivedImageUrl = "";
  bool showSpinner = false;

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
    subscription?.cancel();
    animationController.dispose();
    super.dispose();
  }

  void generateImage() async {
    final request = GenerateImage(controller.text, 1,
        size: ImageSize.size1024, responseFormat: Format.url);
    final response = await openAI?.generateImage(request);
    receivedImageUrl = "${response?.data?.last?.url}";
    setState(() {
      showSpinner = false;
      isSent = true;
    });
  }

  void download() async {
    var status = await Permission.storage.request();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.transparent,
        content: Center(
          child: Text('Downloading'),
        ),
      ),
    );
    var response;
    if (status.isGranted && receivedImageUrl != "") {
      response = await Dio().get(receivedImageUrl,
          options: Options(responseType: ResponseType.bytes));
    } else if (status.isGranted && receivedImageUrl == "") {
      response = await Dio().get(
        "https://cdn.leonardo.ai/users/96409cf4-cccb-4dc3-b007-47c547a72b25/generations/5edaaf78-137e-4434-8bdf-fb1aa6ec3659/variations/Default_A_cosmic_exploration_of_the_universe_with_a_cannabis_p_0_5edaaf78-137e-4434-8bdf-fb1aa6ec3659_1.jpg",
        options: Options(responseType: ResponseType.bytes),
      );
    }
    await ImageGallerySaver.saveImage(Uint8List.fromList(response.data),
        quality: 60, name: "Generated Image");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.transparent,
        content: Center(
          child: Text('Downloaded'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: Text(
            'Image Generator',
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
            if (controller.text == "") {
              return;
            }
            setState(() {
              showSpinner = true;
            });
            isSent = true;
            generateImage();
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
      body: LayoutBuilder(
        builder: (context, constraint) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraint.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Visibility(
                      visible: showSpinner,
                      child: Container(
                        margin:
                            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                      ),
                    ),
                    Visibility(
                      visible: showSpinner == false,
                      child: Container(
                        margin:
                            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        height: MediaQuery.of(context).size.height * 0.42,
                        width: 396.8,
                        decoration: BoxDecoration(
                          color: DarkModeColors.textFieldColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: isSent
                              ? CachedNetworkImage(
                                  imageUrl: receivedImageUrl,
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.fitWidth),
                                    ),
                                  ),
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          SpinKitCircle(
                                    color: Colors.white,
                                    size: 50.0,
                                    controller: AnimationController(
                                      vsync: this,
                                      duration:
                                          const Duration(milliseconds: 1200),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                )
                              : Image.asset(
                                  'assets/images/default_image.jpg',
                                  fit: BoxFit.fitWidth,
                                ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        Button(
                          text: 'Copy Prompt',
                          icon: Icons.copy,
                          onPressed: () {
                            if (controller.text == "") {
                              return;
                            }
                            Clipboard.setData(
                                    ClipboardData(text: controller.text))
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
                          text: 'Download HD',
                          icon: Icons.download,
                          onPressed: () async {
                            download();
                          },
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                    Expanded(child: BottomMessageScreen()),
                    const SizedBox(
                      height: 3,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
              color: Colors.white,
            ),
            controller: controller,
            onSubmitted: (value) {
              if (value == "") {
                return;
              }
              isSent = true;
              generateImage();
            },
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
}
