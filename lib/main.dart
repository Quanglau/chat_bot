import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../screen/sign_in_screen.dart';
//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
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(HomePageFirst());
}

class HomePageFirst extends StatefulWidget {
  @override
  _HomePageStateFirst createState() => _HomePageStateFirst();
}

class _HomePageStateFirst extends State<HomePageFirst> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Chat bot",
      home: Login(),
      debugShowCheckedModeBanner: false,
    );
  }
}




