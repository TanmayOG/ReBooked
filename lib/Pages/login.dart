import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:student_olx/Constant/constants.dart';
import 'package:student_olx/Pages/splash.dart';
import 'package:student_olx/Provider/auth_provider.dart';

import '../Model/user_model.dart';
import '../Provider/user_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            const SizedBox(height: 80),
            Image.asset("assets/images/login.png",
                fit: BoxFit.cover, height: 300),
            const SizedBox(height: 60),
            Text("ReBooked",
                style: GoogleFonts.racingSansOne(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            const Padding(
              padding: EdgeInsets.all(25.0),
              child: Text(
                  "Discover the joy of reading while saving money with our second-hand book app. Every book has a story to tell, and now you can be part of that story without breaking the bank.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15)),
            ),
            const SizedBox(height: 80),
            customButton(
              text: "Continue with Google",
              onPressed: () {
                Provider.of<AuthProvider>(context, listen: false)
                    .signInWithGoogle(context)
                    .then((value) {
                  if (!value!.additionalUserInfo!.isNewUser) {
                    UserModel user = UserModel(
                      id: value.user!.uid,
                      name: value.user!.displayName,
                      email: value.user!.email,
                      image: value.user!.photoURL,
                    );
                    log(user.toJson().toString());
                    Provider.of<UserProvider>(context, listen: false)
                        .allDetails = user;

                    Provider.of<UserProvider>(context, listen: false)
                        .insertDataIntoLocalStore();
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SplashScreen()));
                  }
                });
              },
              color: buttonColor,
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

Widget customButton({
  required String text,
  onPressed,
  required Color color,
  required Color textColor,
}) {
  return Padding(
    padding: const EdgeInsets.only(left: 20.0, right: 20),
    child: SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: textColor,
          backgroundColor: buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        child: Text(text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    ),
  );
}
