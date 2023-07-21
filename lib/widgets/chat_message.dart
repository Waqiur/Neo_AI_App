import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatMessage extends StatelessWidget {
  const ChatMessage({super.key, required this.text, required this.isMe});

  final String text;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: isMe ? false : true,
          child: const Padding(
            padding: EdgeInsets.only(left: 10.0),
            child: CircleAvatar(
              radius: 15,
              child: Icon(Icons.abc),
            ),
          ),
        ),
        ChatBubble(
          clipper: ChatBubbleClipper5(
              type: isMe ? BubbleType.sendBubble : BubbleType.receiverBubble),
          alignment: isMe ? Alignment.topRight : Alignment.topLeft,
          margin: isMe
              ? const EdgeInsets.only(bottom: 10, right: 10)
              : const EdgeInsets.only(bottom: 10, left: 10),
          backGroundColor:
              isMe ? Colors.deepPurpleAccent : Colors.grey.shade800,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.65,
            ),
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        )
      ],
    );
  }

  Widget AnimatedText(String text) {
    return DefaultTextStyle(
      style: GoogleFonts.varelaRound(
        fontSize: 15,
        color: Colors.white,
      ),
      child: AnimatedTextKit(
        totalRepeatCount: 1,
        animatedTexts: [TypewriterAnimatedText(text)],
      ),
    );
  }
}
