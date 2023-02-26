import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:student_olx/Constant/constants.dart';
import 'package:student_olx/Pages/bottom_nav.dart';
import 'package:student_olx/Provider/user_provider.dart';

import 'login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.delayed(const Duration(seconds: 4), () {
      if (FirebaseAuth.instance.currentUser != null) {
        Provider.of<UserProvider>(context, listen: false)
            .getDataFromLocalStore();
        Provider.of<UserProvider>(context, listen: false).determinePosition();
        if (mounted) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const MyBottomApp()));
        }
      } else {
        if (mounted) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const LoginScreen()));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: buttonColor,
        body: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Text("Re",
                        style: GoogleFonts.racingSansOne(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: buttonColor))),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text("ReBooked",
                    style: GoogleFonts.racingSansOne(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
              const SizedBox(height: 20),
              const SizedBox(
                height: 4,
                width: 80,
                child: LinearProgressIndicator(
                  backgroundColor: buttonColor,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
