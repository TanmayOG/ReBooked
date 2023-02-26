import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_olx/Constant/constants.dart';
import 'package:student_olx/Pages/home.dart';
import 'package:student_olx/Pages/login.dart';
import 'package:student_olx/Pages/splash.dart';
import 'package:student_olx/Provider/user_provider.dart';

class LocationEnable extends StatefulWidget {
  const LocationEnable({super.key});

  @override
  State<LocationEnable> createState() => _LocationEnableState();
}

class _LocationEnableState extends State<LocationEnable> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text("Enable Location", style: TextStyle(fontSize: 25)),
              const SizedBox(height: 20),
              const SizedBox(
                  height: 200,
                  width: 200,
                  child: Icon(Icons.location_city, size: 200)),
              const SizedBox(height: 20),
              const Text("Please enable location to continue",
                  style: TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              const Text(
                  "We need your location to show you nearby books and sellers",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16)),
              const SizedBox(height: 50),
              customButton(
                  text: 'Enable Location',
                  color: buttonColor,
                  onPressed: () async {
                    await Provider.of<UserProvider>(context, listen: false)
                        .determinePosition();
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SplashScreen()));
                  },
                  textColor: Colors.white)
            ],
          ),
        ),
      ),
    );
  }
}
