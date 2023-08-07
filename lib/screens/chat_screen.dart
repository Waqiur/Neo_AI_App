import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:neo_ai_app/widgets/credit_alert_dialog.dart';

import '../const/constants.dart';
import 'package:flutter/material.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';

import '../api/api_key.dart';
import '../firestore/queries.dart';
import '../widgets/chat_message.dart';
import '../widgets/dot_animation.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController controller = TextEditingController();
  final List<ChatMessage> chatMessages = [];
  late bool isMe;
  OpenAI? openAI;
  StreamSubscription? subscription;
  bool isTyping = false;

  @override
  void initState() {
    super.initState();
    openAI = OpenAI.instance.build(
      token: openAIApiKey,
      baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 60)),
      enableLog: true,
    );
  }

  @override
  void dispose() {
    super.dispose();
    subscription?.cancel();
  }

  Future<void> sendMessage() async {
    int credits = Get.find<AddData>().getCreditValue.value;
    if (credits == 0) {
      CreditAlertDialog().checkCredits(context, "Not Enough Credits");
      return;
    }
    if (controller.text == "") {
      return;
    }
    ChatMessage chatMessage = ChatMessage(
      text: controller.text,
      isMe: true,
    );
    setState(() {
      chatMessages.insert(0, chatMessage);
      isTyping = true;
    });
    receiveMessage();
    controller.clear();
  }

  void receiveMessage() async {
    final request = ChatCompleteText(
      messages: [Messages(role: Role.user, content: controller.text)],
      maxToken: 200,
      model: GptTurbo0301ChatModel(),
    );

    final response = await openAI?.onChatCompletion(request: request);
    ChatMessage receivedMessage = ChatMessage(
      text: response!.choices[0].message!.content,
      isMe: false,
    );
    Get.find<AddData>()
        .updateUserData(FirebaseAuth.instance.currentUser!.email!, false);
    setState(() {
      isTyping = false;
      chatMessages.insert(0, receivedMessage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: Text(
            'Chat Screen',
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
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                reverse: true,
                itemCount: chatMessages.length,
                itemBuilder: (context, index) {
                  return chatMessages[index];
                },
              ),
            ),
            if (isTyping) TypingIndicator(),
            BottomMessageScreen(),
          ],
        ),
      ),
    );
  }

  Widget BottomMessageScreen() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0).copyWith(bottom: 5),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
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
                    sendMessage();
                  },
                  decoration: const InputDecoration(
                    hintText: "Send a message",
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            splashColor: DarkModeColors.textFieldColor,
            splashRadius: 24,
            icon: const Icon(Icons.send),
            onPressed: () {
              sendMessage();
            },
            color: Colors.white,
          )
        ],
      ),
    );
  }

  Widget TypingIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 10.0),
          child: CircleAvatar(
            radius: 15,
            child: Icon(Icons.abc),
          ),
        ),
        ChatBubble(
          clipper: ChatBubbleClipper5(type: BubbleType.receiverBubble),
          alignment: Alignment.topLeft,
          margin: const EdgeInsets.only(bottom: 10, left: 10),
          padding: const EdgeInsets.all(0).copyWith(bottom: 5),
          backGroundColor: Colors.grey.shade800,
          child: const SizedBox(
            height: 40,
            width: 60,
            child: DotAnimation(),
          ),
        )
      ],
    );
  }
}
