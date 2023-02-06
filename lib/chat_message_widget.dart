import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:chatgpt_lession_learn/api/chatgpt_api.dart';
import 'package:chatgpt_lession_learn/app_colors.dart';
import 'package:flutter/material.dart';

class ChatMessageWidget extends StatelessWidget {
  const ChatMessageWidget(
      {super.key, required this.text, required this.chatMessageType});

  final String text;
  final ChatMessageType chatMessageType;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      padding: const EdgeInsets.all(16),
      color: chatMessageType == ChatMessageType.bot
          ? AppColors.botBackgroundColor
          : AppColors.backgroundColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          chatMessageType == ChatMessageType.bot
              ? Container(
                  margin: const EdgeInsets.only(right: 16.0),
                  child: CircleAvatar(
                    backgroundColor: AppColors.botBackgroundColor,
                    child: Image.asset(
                      'assets/bot.png',
                      color: AppColors.backgroundColor,
                      scale: 1.5,
                    ),
                  ),
                )
              : Container(
                  margin: const EdgeInsets.only(right: 16.0),
                  child: const CircleAvatar(
                    child: Icon(
                      Icons.person,
                    ),
                  ),
                ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    child: chatMessageType == ChatMessageType.user
                        ? Text(
                            text,
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.black,
                                    ),
                          )
                        : DefaultTextStyle(
                            style: TextStyle(
                              color: AppColors.backgroundColor,
                              fontWeight: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.fontWeight ??
                                  FontWeight.w700,
                              fontSize: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.fontSize ??
                                  16,
                            ),
                            child: AnimatedTextKit(
                              isRepeatingAnimation: false,
                              repeatForever: false,
                              displayFullTextOnTap: true,
                              totalRepeatCount: 1,
                              animatedTexts: [
                                TyperAnimatedText(text),
                              ],
                            ),
                          )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
