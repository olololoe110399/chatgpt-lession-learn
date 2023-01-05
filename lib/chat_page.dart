import 'package:avatar_glow/avatar_glow.dart';
import 'package:chatgpt_lession_learn/api/chatgpt_api.dart';
import 'package:chatgpt_lession_learn/app_colors.dart';
import 'package:chatgpt_lession_learn/app_constants.dart';
import 'package:chatgpt_lession_learn/chat_message_widget.dart';
import 'package:chatgpt_lession_learn/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  late bool isLoading;
  late bool isListening;
  late bool isVoiceAssistant;
  final ChatGPTApi openAI = ChatGPTApi(apiKey: AppConstants.apiSecretKey);
  final speechToText = stt.SpeechToText();
  final flutterTts = FlutterTts();
  double volume = 1.0;
  double pitch = 1.0;
  double speechRate = 0.5;
  List<String>? languages;
  String langCode = "en-US";

  @override
  void initState() {
    super.initState();
    isLoading = false;
    isListening = false;
    init();
  }

  void init() async {
    languages = List<String>.from(await flutterTts.getLanguages);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "OpenAI's ChatGPT Flutter",
            maxLines: 2,
            textAlign: TextAlign.center,
          ),
        ),
        backgroundColor: AppColors.botBackgroundColor,
        actions: [
          if (languages != null)
            PopupMenuButton(
              itemBuilder: (context) => (languages ?? [])
                  .map(
                    (value) => PopupMenuItem(
                      value: value,
                      child: Text(
                        value,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: langCode == value
                                  ? AppColors.botBackgroundColor
                                  : Colors.black,
                            ),
                      ),
                      onTap: () {
                        setState(() async {
                          langCode = value;
                        });
                      },
                    ),
                  )
                  .toList(),
            )
        ],
      ),
      backgroundColor: AppColors.backgroundColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Visibility(
        visible: isListening,
        child: AvatarGlow(
          animate: isListening,
          glowColor: Theme.of(context).primaryColor,
          endRadius: 75.0,
          duration: const Duration(milliseconds: 2000),
          repeatPauseDuration: const Duration(milliseconds: 100),
          repeat: true,
          child: GestureDetector(
            onTap: _listen,
            child: const CircleAvatar(
              backgroundColor: AppColors.botBackgroundColor,
              radius: 40,
              child: Icon(
                Icons.close,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Utils.hideKeyboard(context);
      },
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _buildList(),
            ),
            Visibility(
              visible: isLoading,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(
                  color: AppColors.botBackgroundColor,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Visibility(
                visible: !isListening,
                child: Row(
                  children: [
                    _buildInput(),
                    const SizedBox(width: 5),
                    _buildSubmit(),
                    const SizedBox(width: 5),
                    _buildVoice(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoice() {
    return Visibility(
      visible: !isLoading,
      child: GestureDetector(
        onTap: _listen,
        child: const CircleAvatar(
          backgroundColor: AppColors.botBackgroundColor,
          radius: 25,
          child: Icon(
            Icons.mic_none,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmit() {
    return Visibility(
      visible: !isLoading,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.botBackgroundColor,
          borderRadius: BorderRadius.circular(
            6,
          ),
        ),
        child: IconButton(
          icon: const Icon(
            Icons.send_rounded,
            color: Colors.white,
          ),
          onPressed: () async {
            _stop();
            Utils.hideKeyboard(context);
            setState(
              () {
                _messages.add(
                  ChatMessage(
                    text: _textController.text,
                    chatMessageType: ChatMessageType.user,
                  ),
                );
                isLoading = true;
              },
            );
            var input = _textController.text;
            _textController.clear();
            Future.delayed(const Duration(milliseconds: 50))
                .then((_) => _scrollDown());
            openAI.complete(input).then((value) {
              setState(() {
                isLoading = false;
                _messages.add(
                  ChatMessage(
                    text: value,
                    chatMessageType: ChatMessageType.bot,
                  ),
                );
                _speak(value);
              });
            }).catchError((error) {
              setState(
                () {
                  final snackBar = SnackBar(
                    content: Text(error.toString()),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  isLoading = false;
                },
              );
            });
            _textController.clear();
            Future.delayed(const Duration(milliseconds: 50))
                .then((_) => _scrollDown());
          },
        ),
      ),
    );
  }

  Expanded _buildInput() {
    return Expanded(
      child: TextField(
        minLines: 1,
        maxLines: 9,
        textCapitalization: TextCapitalization.sentences,
        controller: _textController,
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.inputBackgroundColor,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildList() {
    if (isListening) {
      return Center(
        child: Text(
          _textController.text,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.black,
              ),
        ),
      );
    }

    if (_messages.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: AppColors.botBackgroundColor,
            radius: 50,
            child: Image.asset(
              'assets/bot.png',
              color: AppColors.backgroundColor,
              scale: 0.6,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
            child: Text(
              'Hi, I\'m Duy\nTell me your dreams and i\'ll make them happen',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.black,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      controller: _scrollController,
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        var message = _messages[index];
        return ChatMessageWidget(
          text: message.text,
          chatMessageType: message.chatMessageType,
        );
      },
    );
  }

  void _scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _listen() async {
    _stop();
    Utils.hideKeyboard(context);
    if (!isListening) {
      final avilable = await speechToText.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (avilable) {
        setState(() {
          isListening = true;
          speechToText.listen(onResult: (result) {
            setState(() {
              _textController.text = result.recognizedWords;
            });
          });
        });
      }
    } else {
      setState(() => isListening = false);
      speechToText.stop();
    }
  }

  void initSetting() async {
    await flutterTts.setVolume(volume);
    await flutterTts.setPitch(pitch);
    await flutterTts.setSpeechRate(speechRate);
    await flutterTts.setLanguage(langCode);
  }

  void _speak(text) async {
    initSetting();
    await flutterTts.speak(text);
  }

  void _stop() async {
    await flutterTts.stop();
  }
}
