import 'dart:io';
import '../authentication/auth_page.dart';
import '../authentication/user.dart';
import '../chatdata/handle.dart';
import '../screen/sign_in_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SignUpState();
  }
}

class _SignUpState extends State<SignUp> {
  final storage = const FlutterSecureStorage();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();
  UserCustom? userCustom;
  late File file;

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth().createUserWithEmailAndPassword(
        email: emailController.text,
        password: passController.text,
      );

      User? user = Auth().firebaseAuth.currentUser;
      userCustom?.name = fullNameController.text;
      await storage.write(key: 'key_save_email', value: '');
      await storage.write(key: 'key_save_password', value: '');
      await Handle()
          .addInfoUser(fullNameController.text, emailController.text, user!.uid, '', '', '', '', imageFile: null);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const <Widget>[
                  Icon(Icons.check_box, color: Colors.white),
                  SizedBox(width: 8.0),
                  Text(
                    'Đã tạo tài khoản thành công.',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              backgroundColor: Colors.cyan,
              duration: Duration(seconds: 3),
            ),
          );
          Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
        } on FirebaseAuthException catch (e) {
          if (e.code == 'invalid-email') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const <Widget>[
                    Icon(Icons.error_outline, color: Colors.white),
                    SizedBox(width: 8.0),
                    Text(
                      'Địa chỉ email không hợp lệ.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8.0),
                Text(
                  'Địa chỉ email này đã tồn tại.',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      } else if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8.0),
                Text(
                  'Mật khẩu không đủ mạnh.',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void checkLogin() {
    if (fullNameController.text == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8.0),
              Text(
                'Vui lòng nhập họ và tên.',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    } else if (emailController.text == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8.0),
              Text(
                'Vui lòng nhập email.',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    } else if (passController.text == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8.0),
              Text(
                'Vui lòng nhập mật khẩu.',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    } else if (confirmPassController.text == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8.0),
              Text(
                'Vui lòng nhập lại mật khẩu.',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fullName = TextFormField(
      controller: fullNameController,
      autofocus: false,
      decoration: InputDecoration(
          hintText: "Họ và tên",
          contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32))),
    );

    final email = TextFormField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      decoration: InputDecoration(
          hintText: 'Email',
          contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32))),
    );

    final password = TextFormField(
      controller: passController,
      autofocus: false,
      obscureText: true,
      decoration: InputDecoration(
          hintText: 'Mật khẩu',
          contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32))),
    );

    final confirmPassword = TextFormField(
      controller: confirmPassController,
      autofocus: false,
      obscureText: true,
      decoration: InputDecoration(
          hintText: 'Nhập lại mật khẩu',
          contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32))),
    );

    var SignUpButton = ElevatedButton(
      style: ElevatedButton.styleFrom(
          minimumSize: const Size(200, 40),
          backgroundColor: Colors.lightBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          )),
      onPressed: () {
        checkLogin();
        if (confirmPassController.text == passController.text) {
          createUserWithEmailAndPassword();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const <Widget>[
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 8.0),
                  Text(
                    'Các mật khẩu đã nhập không khớp. Hãy thử lại.',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      },
      child: const Padding(
        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Text('Đăng ký',
            style: TextStyle(fontSize: 25, color: Colors.white)),
      ),
    );

    final signIn = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Đã có tài khoản? ',
        ),
        TextButton(
          child: const Text(
            'Đăng nhập',
            style: TextStyle(
              color: Colors.cyan,
            ),
          ),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Login()));
          },
        )
      ],
    );

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(right: 24, left: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text(
                  'Tạo tài khoản của bạn',
                  style: TextStyle(
                    fontSize: 35,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 45,
                ),
                fullName,
                const SizedBox(
                  height: 10,
                ),
                email,
                const SizedBox(
                  height: 10,
                ),
                password,
                const SizedBox(
                  height: 10,
                ),
                confirmPassword,
                const SizedBox(
                  height: 25,
                ),
                SignUpButton,
                const SizedBox(
                  height: 50,
                ),
                const SizedBox(
                  height: 25,
                ),
                signIn
              ],
            ),
          ),
        ),
      ),
    );
  }
}
