import '../authentication/auth_page.dart';
import '../authentication/user.dart';
import '../chatdata/my_data.dart';
import '../screen/info_user_screen.dart';
import '../screen/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Setting extends StatefulWidget {
  UserCustom user;

  Setting({super.key, required this.user});

  @override
  State<StatefulWidget> createState() {
    return SettingState();
  }
}

class SettingState extends State<Setting> {
  final storage = const FlutterSecureStorage();
  late UserCustom userCustom;
  bool _isExpandedBot = false;
  bool _isExpandedModel = false;
  String? _selectedModel;
  TextEditingController botNameController = TextEditingController();
  TextEditingController keyAPIController = TextEditingController();
  bool isLoading = true;
  static String myApikey = MyData.myApiKey ?? '';

  @override
  void initState() {
    super.initState();
    readData().then((value) {
      print('123');
      setState(() {
        // Update the state with the loaded data
        userCustom = widget.user;
        isLoading = false;
      });
    });
  }

  //Đọc các dữ liệu từ Local Storage
  Future<void> readData() async {
    try {
      final List<Future<String?>> futures = [
        storage.read(key: 'choose_voice'),
        storage.read(key: 'bot_name'),
        storage.read(key: 'bot_avatar'),
        storage.read(key: 'model_chat'),
        storage.read(key: 'generate_voice'),
        storage.read(key: 'generate_image'),
      ];
      final List<String?> results = await Future.wait(futures);

      botNameController.text = results[1] ?? 'GLEAN';
      _selectedModel = results[2] ?? 'both';

      keyAPIController.text = myApikey;
    } catch (e) {
      print('Error reading data: $e');
    }
  }

  //build các setting
  Widget containerSetting() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            shrinkWrap: true,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => UserInformation(user: userCustom)));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(children: const [
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
                      child: Icon(Icons.people_outline),
                    ),
                    Expanded(child: Text('Thông tin tài khoản')),
                    Icon(Icons.arrow_right, color: Color.fromRGBO(1, 1, 1, 0.3), size: 30),
                  ]),
                ),
              ),

              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpandedBot = !_isExpandedBot;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
                        child: Icon(Icons.android_outlined),
                      ),
                      const Expanded(child: Text('Bot')),
                      Icon(_isExpandedBot ? Icons.arrow_drop_down : Icons.arrow_right,
                          color: const Color.fromRGBO(1, 1, 1, 0.3), size: 30),
                    ],
                  ),
                ),
              ),
              _isExpandedBot ? containerBot() : const SizedBox.shrink(),
              //build option Model
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpandedModel = !_isExpandedModel;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
                        child: Icon(Icons.list_alt_rounded),
                      ),
                      const Expanded(child: Text('Model Chat')),
                      Icon(_isExpandedModel ? Icons.arrow_drop_down : Icons.arrow_right,
                          color: const Color.fromRGBO(1, 1, 1, 0.3), size: 30),
                    ],
                  ),
                ),
              ),
              _isExpandedModel ? containerModel() : const SizedBox.shrink(),

            ],
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            FocusScope.of(context).unfocus();
            await storage.deleteAll();
            await storage.write(key: 'check', value: 'false');
            Auth().signOut(context: context).then((value) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const Login()));
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
                child: Icon(Icons.logout_outlined),
              ),
              Text('Đăng xuất', style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ],
    );
  }

  //build các tuỳ chọn cho bot
  Widget containerBot() {
    return SingleChildScrollView(
      child: Column(
        children: [
          TextFormField(
            controller: keyAPIController,
            decoration: InputDecoration(
                prefixIcon: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const AlertDialog(
                          title: Text('Hướng dẫn lấy key OpenAI', textAlign: TextAlign.center),
                          content: Text(
                            '* Truy cập và đăng nhập trang:\nhttps://platform.openai.com/account/api-keys\n\n* Chọn \'Create new secret key\'\n\n* Copy key mới tạo và dán vào đây',
                            style: TextStyle(fontSize: 17),
                            textAlign: TextAlign.justify,
                          ),
                        );
                      },
                    );
                  },
                  child: const Icon(Icons.info_outline_rounded),
                ),
                suffixIcon: GestureDetector(
                    onTap: () async {
                      if (FocusScope.of(context).hasFocus) {
                        print('object check');
                        // Nếu có, hủy focus và ẩn bàn phím
                        FocusScope.of(context).unfocus();
                        myApikey = keyAPIController.text;
                        MyData.myApiKey = keyAPIController.text;
                        await storage.write(key: 'key_API', value: keyAPIController.text);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const <Widget>[
                                Icon(Icons.check_box, color: Colors.white),
                                SizedBox(width: 8.0),
                                Text(
                                  'Đã cập nhật thành công',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            backgroundColor: Colors.cyan,
                            duration: Duration(milliseconds: 1500),
                          ),
                        );
                      }
                    },
                    child: const Icon(Icons.check)),
                hintText: 'Nhập Key OpenAI',
                contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
            textAlign: TextAlign.center,
          ),

        ],
      ),
    );
  }

  //build các tuỳ chọn Model
  Widget containerModel() {
    return SingleChildScrollView(
      child: Column(
        children: [
          ListTile(
            title: const Text('Model 3.5'),
            leading: Radio(
              value: 'gpt-3.5-turbo',
              groupValue: _selectedModel,
              onChanged: (String? value) async {
                await storage.write(key: 'model_chat', value: value);
                setState(() {
                  _selectedModel = value;
                });
              },
            ),
          ),
          ListTile(
            title: const Text('Model 3'),
            leading: Radio(
              value: 'text-davinci-003',
              groupValue: _selectedModel,
              onChanged: (String? value) async {
                await storage.write(key: 'model_chat', value: value);
                setState(() {
                  _selectedModel = value;
                });
              },
            ),
          ),

        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('012');
    Widget expandedScreen() {
      return containerSetting();

    }

    return Stack(children: [
      WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop();
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.black54),
            backgroundColor: const Color.fromRGBO(242, 248, 248, 1),
            title: const Text(
              'Cài đặt',
              style: TextStyle(color: Colors.black54, fontSize: 18),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.more_horiz,
                ),
                onPressed: () {},
              )
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(30, 30, 30, 30),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Stack(alignment: Alignment.bottomRight, children: [
                    ClipOval(
                      child: SizedBox.fromSize(
                        size: const Size(50, 50),
                        child: Image.network(
                            userCustom.photoURL ??
                                'https://phongreviews.com/wp-content/uploads/2022/11/avatar-facebook-mac-dinh-15.jpg',
                            fit: BoxFit.fitWidth),
                      ),
                    ),
                  ]),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(userCustom.name ?? 'Chatbot', style: const TextStyle(fontSize: 20)),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(userCustom.email ?? 'chatbot@gmail.com', style: const TextStyle(fontSize: 15)),
                  const SizedBox(
                    height: 20,
                  ),
                  const Divider(
                    color: Colors.grey,
                  ),
                  Expanded(
                    child: expandedScreen(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      if (isLoading)
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
    ]);
  }
}
