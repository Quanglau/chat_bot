import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
class Auth {
  final storage = const FlutterSecureStorage();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  User? get currentUser => firebaseAuth.currentUser;
  Stream<User?> get authStateChange => firebaseAuth.authStateChanges();

  Future<void> signInWithEmailAndPassword({required String email, required String password}) async {
    await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }
  Future<void> createUserWithEmailAndPassword({required String email, required String password}) async {
    await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut({required BuildContext context}) async {
      await FirebaseAuth.instance.signOut();
  }
}