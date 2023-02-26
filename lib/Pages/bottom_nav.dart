import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:student_olx/Constant/constants.dart';
import 'package:student_olx/Pages/Chats/chat_page.dart';
import 'package:student_olx/Pages/home.dart';
import 'package:student_olx/Pages/profile.dart';
import 'package:student_olx/Pages/seller.dart';

class MyBottomApp extends StatefulWidget {
  const MyBottomApp({Key? key}) : super(key: key);

  @override
  MyBottomAppState createState() => MyBottomAppState();
}

class MyBottomAppState extends State<MyBottomApp> {
  int? page = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
          onTap: (value) {
            setState(() {
              page = value;
            });
          },
          unselectedItemColor: Colors.grey,
          selectedFontSize: 14,
          unselectedFontSize: 12,
          elevation: 0,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.lightBlueAccent[300],
          currentIndex: page ?? 0,
          items: [
            BottomNavigationBarItem(
              icon: page == 0
                  ? const Icon(
                      Iconsax.home5,
                      color: buttonColor,
                      size: 20,
                    )
                  : const Icon(Iconsax.home, color: Colors.grey, size: 20),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: page == 1
                  ? const Icon(
                      Iconsax.message5,
                      color: buttonColor,
                      size: 20,
                    )
                  : const Icon(
                      Iconsax.message,
                      color: Colors.grey,
                      size: 20,
                    ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: page == 2
                  ? const Icon(
                      Iconsax.bucket,
                      color: buttonColor,
                      size: 20,
                    )
                  : const Icon(
                      Iconsax.bucket,
                      color: Colors.grey,
                      size: 20,
                    ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: page == 3
                  ? const Icon(
                      Iconsax.profile_2user5,
                      color: buttonColor,
                      size: 20,
                    )
                  : const Icon(
                      Iconsax.profile_2user,
                      color: Colors.grey,
                      size: 20,
                    ),
              label: '',
            ),
          ]),
      body: pages[page ?? 0],
    );
  }
}

const pages = [
  HomeScreen(),
  ChatPage(),
  SellerScreen(),
  ProfileScreen(),
];
