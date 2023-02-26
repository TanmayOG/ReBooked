import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:student_olx/Provider/user_provider.dart';

import '../Constant/constants.dart';
import '../Provider/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final userInfo = Provider.of<UserProvider>(context);
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: FloatingActionButton.extended(
            onPressed: () {
              logout(context);
            },
            backgroundColor: buttonColor,
            isExtended: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            label: const Text('Logout'),
          ),
        ),
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          title: const Text("Profile", style: TextStyle(color: Colors.black)),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 40,
              ),
              Center(
                child: Semantics(
                  label: "Profile Image",
                  button: true,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.network(
                      userInfo.image!,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              ListTile(
                title: const Text("Name"),
                leading: const Icon(Iconsax.personalcard),
                subtitle: Text(userInfo.name ?? "Loading..."),
              ),
              ListTile(
                title: const Text("Email"),
                leading: const Icon(Iconsax.direct_inbox),
                subtitle: Text(userInfo.email ?? "Loading..."),
              ),
              ListTile(
                title: const Text("Address"),
                leading: const Icon(Iconsax.map5),
                subtitle: Text(userInfo.address ?? "Loading..."),
              ),
            ],
          ),
        ));
  }
}
