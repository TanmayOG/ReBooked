// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_olx/Constant/constants.dart';
import 'package:student_olx/Model/user_model.dart';
import 'package:student_olx/Pages/login.dart';
import 'package:student_olx/Pages/splash.dart';
import 'package:student_olx/Provider/user_provider.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  // UserDb db = UserDb();

  Future<UserCredential?> signInWithGoogle(
    BuildContext context,
  ) async {
    try {
      log("signInWithGoogle $isLoading");
      _isLoading = true;
      showLoadingDialog(context);
      notifyListeners();
      log("signInWithGoogle $isLoading");
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      UserCredential receipt =
          await FirebaseAuth.instance.signInWithCredential(credential);
      SharedPreferences prefs = await SharedPreferences.getInstance();

      if (receipt.additionalUserInfo!.isNewUser) {
        String? token;
        await FirebaseMessaging.instance.getToken().then((value) {
          token = value;
        });
        UserModel user = UserModel(
          id: receipt.user!.uid,
          name: receipt.user!.displayName,
          email: receipt.user!.email,
          token: token.toString(),
          image: receipt.user!.photoURL,
        );

        log("Hellow");
        Provider.of<UserProvider>(context, listen: false).allDetails = user;

        Provider.of<UserProvider>(context, listen: false)
            .insertDataIntoLocalStore();

        addUserDataToDb(user);

        _isLoading = false;
        Navigator.pop(context);
        notifyListeners();

        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const SplashScreen()));
      } else {
      

       



        _isLoading = false;
        Navigator.pop(context);
        notifyListeners();
      }
      return receipt;
    } on FirebaseAuthException catch (e) {
      log("signInWithGoogle $isLoading");
      log("error $e");
      _isLoading = false;
      Navigator.pop(context);
      notifyListeners();
    }
    return null;
  }

  addUserDataToDb(UserModel user) async {
    await FirebaseFirestore.instance
        .collection(userCollection)
        .doc(user.id)
        .set(user.toJson());
  }
}

logout(context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.clear();

  await FirebaseAuth.instance.signOut();
  await GoogleSignIn().signOut();
  Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => const LoginScreen()));
}

showLoadingDialog(context) {
  return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Row(
            children: const [
              CircularProgressIndicator(),
              SizedBox(
                width: 10,
              ),
              Text("Loading..."),
            ],
          ),
        );
      });
}
