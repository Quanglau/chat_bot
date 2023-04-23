import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../authentication/user.dart';

class UserInformation extends StatefulWidget {
  final UserCustom user;
  const UserInformation({Key? key, required this.user}) : super(key : key);
  @override
  State<StatefulWidget> createState() {
    return _userInformationState();
  }
}

class _userInformationState extends State<UserInformation> {
  late UserCustom userCustom;
  final fullNameController = TextEditingController();
  final sexController = TextEditingController();
  final birthController = TextEditingController();
  final phoneController = TextEditingController();
  final picker = ImagePicker();
  File? _imageFile;
  bool changeImage = false;
  @override
  void initState() {
    super.initState();
    userCustom = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black54),
        backgroundColor: const Color.fromRGBO(242, 248, 248, 1),
        title: const Text('Thông tin tài khoản', style: TextStyle(color: Colors.black54, fontSize: 18),),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.more_horiz,
            ),
            onPressed: () {
            },
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
                    size: const Size(100, 100),
                    child: changeImage
                        ? Image.file(_imageFile!, fit: BoxFit.fitWidth)
                        : Image.network(
                        userCustom.photoURL ??
                            'https://phongreviews.com/wp-content/uploads/2022/11/avatar-facebook-mac-dinh-15.jpg',
                        fit: BoxFit.fitWidth),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(0),
                  child: GestureDetector(
                    child: const Icon(
                      IconData(0xe0fa, fontFamily: 'MaterialIcons'),
                      color: Colors.blueAccent,
                    ),
                  ),
                )
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
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: fullNameController,
                          keyboardType: TextInputType.name,
                          autofocus: false,
                          decoration: const InputDecoration(
                            hintText: 'Họ và tên',
                            contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                            filled: true,
                            fillColor: Color.fromRGBO(1, 1, 1, 0.05),
                            enabledBorder: InputBorder.none,
                          ),
                        ),
                        const SizedBox(height: 10,),
                        TextFormField(
                          controller: sexController,
                          keyboardType: TextInputType.text,
                          autofocus: false,
                          decoration: const InputDecoration(
                            hintText: 'Giới tính',
                            contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                            filled: true,
                            fillColor: Color.fromRGBO(1, 1, 1, 0.05),
                            enabledBorder: InputBorder.none,
                          ),
                        ),
                        const SizedBox(height: 10,),
                        TextFormField(
                          controller: birthController,
                          keyboardType: TextInputType.datetime,
                          autofocus: false,
                          decoration: const InputDecoration(
                            hintText: 'Ngày sinh',
                            contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                            filled: true,
                            fillColor: Color.fromRGBO(1, 1, 1, 0.05),
                            enabledBorder: InputBorder.none,
                          ),
                        ),
                        const SizedBox(height: 10,),
                        TextFormField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          autofocus: false,
                          decoration: const InputDecoration(
                            hintText: 'Số điện thoại',
                            contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                            filled: true,
                            fillColor: Color.fromRGBO(1, 1, 1, 0.05),
                            enabledBorder: InputBorder.none,
                          ),
                        )
                      ],
                    ),
                  )
              ),
              ElevatedButton(
                onPressed: () async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const <Widget>[
                          Icon(Icons.check_box, color: Colors.white),
                          SizedBox(width: 8.0),
                          Text(
                            'Đã cập nhật thành công.',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.cyan,
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
                      child: Icon(Icons.update),
                    ),
                    Text('Cập nhật', style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
