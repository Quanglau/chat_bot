import 'dart:async';
import '../api_services.dart';
import '../authentication/user.dart';
import '../chatdata/handle.dart';
import '../chatdata/my_data.dart';
import '../screen/setting_screen.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:video_player/video_player.dart';

var widthScreen;
var heightScreen;

class Chat extends StatefulWidget {
  final String title;
  final UserCustom userCustom;
  final String section;

  const Chat({Key? key, required this.title, required this.userCustom, required this.section}) : super(key: key);

  @override
  _ChatState createState() {
    return _ChatState();
  }
}

class _ChatState extends State<Chat> {
  final storage = const FlutterSecureStorage();
  final TextEditingController _textEditingController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool checkSetState = true;
  final Handle _handle = Handle();
  String? chooseVoice;
  bool checkPop = true; //kiem tra man hinh pop cua aleart dialog
  bool switchType = true;
  final _focusNode = FocusNode();
  List<String> listKeywords = [];
  late VideoPlayerController _controller;
  bool checkGenerateReply = false, checkGenerateQuestion = false;
  bool checkSuggestQuestions = false;
  late String translatedTextImage;
  String question = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> waitData() async {
    List<ChatMessage> messages2 = await _handle.readData(widget.userCustom.id, '${widget.section}?${widget.title}');
    MyData.botName = await storage.read(key: 'bot_name');
    MyData.botAvatarPath = await storage.read(key: 'bot_avatar');

    if (checkSetState) {
      setState(() {
        _messages.addAll(messages2);
        checkSetState = false;
      });
    }
  }

  Widget _buildTextComposer() {
    return IconTheme(
        data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: const Color.fromRGBO(218, 238, 246, 1.0),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Flexible(
                  child: TextField(
                focusNode: _focusNode,
                style: const TextStyle(fontSize: 18),
                controller: _textEditingController,
                onSubmitted: _handleSubmitted,
                decoration: const InputDecoration.collapsed(hintText: "Send a message"),
                maxLines: 3,
                minLines: 1,
                autofocus: false,
                cursorColor: Color.fromRGBO(255, 153, 141, 1.0),
              )),

              IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    _focusNode.unfocus();
                    if (_textEditingController.text != "") {
                      _handleSubmitted(_textEditingController.text);
                    }
                    setState(() {
                      listKeywords.clear();
                      checkGenerateReply = false;
                    });
                  })
            ],
          ),
        ));
  }

  Future<void> _handleSubmitted(String text) async {
    _textEditingController.clear();
    listKeywords.clear();

    ChatMessage chatMessage = ChatMessage(
      text: text,
      isUser: true,
      isNewMessage: false,
    );

    if (_messages.isNotEmpty && !_messages[0].isUser) {
      _messages.first.isNewMessage = false;
    }

    setState(() {
      _messages.insert(0, chatMessage);
      question = text;
    });

    final msg = await ApiChatBotServices.sendMessage(_messages.map((message) => message.text).toList());
    var replyText = msg.trim().replaceAll('\n', '').isEmpty ? _handle.handleUserInput(text) : msg.trim();

    ChatMessage reply = ChatMessage(
      text: replyText,
      isUser: false,
      isNewMessage: true,
    );

    await _handle.addData(
        widget.userCustom.id, '${widget.section}?${widget.title}', widget.title, chatMessage.text, reply.text);

    setState(() {
      _messages.insert(0, reply);
    });

    //Get translate from API
    translatedTextImage = await ApiChatBotServices.translate(reply.text);
    print('translatedTextImage: $translatedTextImage');

    setState(() {});
  }
  //xây dựng giao diện
  @override
  Widget build(BuildContext context) {
    waitData();

    widthScreen = MediaQuery.of(context).size.width;
    heightScreen = MediaQuery.of(context).size.height;

    return WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop();
          return true;
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            iconTheme: const IconThemeData(color: Colors.black54),
            backgroundColor: const Color.fromRGBO(242, 248, 248, 1),
            title: Row(children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _messages[0].isNewMessage = false;
                    switchType = !switchType;
                  });
                },
                child: switchType
                    ? CircleAvatar(
                        backgroundImage: AssetImage('assets/${MyData.botAvatarPath ?? 'chatbot.png'}'),
                        backgroundColor: Colors.transparent,
                      )
                    : Container(padding: const EdgeInsets.all(8), child: const Icon(Icons.chat_outlined)),
              ),
              Expanded(
                  child: Text(
                widget.title,
                style: const TextStyle(color: Colors.black54, fontSize: 18),
                textAlign: TextAlign.center,
              ))
            ]),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.settings,
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Setting(user: widget.userCustom)));
                },
              )
            ],
          ),
          body: Stack(
            children: [
              !switchType
                  ? Stack(children: [
                      Expanded(
                        child: Center(
                          child: _controller.value.isInitialized
                              ? Container(
                                  width: widthScreen * _controller.value.aspectRatio,
                                  height: heightScreen,
                                  child: FittedBox(
                                    fit: BoxFit.cover,
                                    child: SizedBox(
                                      width: _controller.value.size.width,
                                      height: _controller.value.size.height,
                                      child: VideoPlayer(_controller),
                                    ),
                                  ),
                                )
                              : const CircularProgressIndicator(),
                        ),
                      ),
                      Column(
                        children: [
                          Expanded(child: Center()),
                          _buildTextComposer(),
                        ],
                      )
                    ])
                  : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          reverse: true,
                          itemBuilder: (context, index) => _messages[index],
                          itemCount: _messages.length,
                        ),
                      ),
                      _buildTextComposer()
                    ]),
              //tạo animation loading
              checkSetState ? const Center(child: CircularProgressIndicator()) : const Center(child: null),
            ],
          ),
        ));
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;
  bool isNewMessage;

  ChatMessage({required this.text, required this.isUser, required this.isNewMessage});

  @override
  Widget build(BuildContext context) {
    if (isUser) {
      print('MyData.userCustom: ${MyData.userCustom?.name}');
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  MyData.userCustom?.name != null ? MyData.userCustom?.name.split(' ').last : 'You',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Container(
                  margin: const EdgeInsets.only(left: 16),
                  child: CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(
                      MyData.userCustom?.photoURL ??
                          'https://phongreviews.com/wp-content/uploads/2022/11/avatar-facebook-mac-dinh-15.jpg',
                    ),
                  ),
                ),
              ],
            ),
            GestureDetector(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)), color: Color.fromRGBO(255, 153, 141, 1.0)),
                constraints: BoxConstraints(maxWidth: widthScreen * 0.7),
                margin: const EdgeInsets.only(top: 5),
                child: Text(
                  text,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontSize: 17,
                  ),
                ),
              ),
            )
          ],
        ),
      );
    } else {
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double maxWidth = widthScreen * 0.7;
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 16),
                      child: CircleAvatar(
                        backgroundImage: AssetImage('assets/${MyData.botAvatarPath ?? 'chatbot.png'}'),
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                    Text(
                      MyData.botName ?? 'Chat bot',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                GestureDetector(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      color: Color.fromRGBO(255, 211, 202, 1.0),
                    ),
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    margin: const EdgeInsets.only(top: 5),
                    child: isNewMessage
                        ? AnimatedTextKit(
                            animatedTexts: [
                              TypewriterAnimatedText(
                                text,
                                textStyle: const TextStyle(
                                  fontSize: 17.0,
                                ),
                                speed: const Duration(milliseconds: 60),
                              ),
                            ],
                            totalRepeatCount: 1,
                            displayFullTextOnTap: true,
                          )
                        : Text(text,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontSize: 17,
                            )),
                  ),
                )
              ],
            ),
          );
        },
      );
    }
  }
}
