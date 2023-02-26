import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_olx/Model/user_model.dart';

class UserProvider extends ChangeNotifier {
  String? _name;
  String? _email;
  String? _id;
  String? _image;
  String? _token;

  String? get name => _name;
  String? get email => _email;
  String? get id => _id;
  String? get image => _image;
  String? get token => _token;

  set allDetails(UserModel userModel) {
    _name = userModel.name;
    _email = userModel.email;
    _id = userModel.id;
    _image = userModel.image;
    _token = userModel.token;
    notifyListeners();
  }

  GeoPoint? _geoPoint = const GeoPoint(0, 0);
  String? _address;

  GeoPoint? get geoPoint => _geoPoint;
  String? get address => _address;

  Future<void> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: 'Please enable Your Location Service');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: 'Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
          msg:
              'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition();

    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      Placemark place = placemarks[0];

      _geoPoint = GeoPoint(position.latitude, position.longitude);
      _address = "${place.locality}, ${place.country}";

      log('$_geoPoint');
      log('$_address');
      notifyListeners();
    } catch (e) {
      Fluttertoast.showToast(msg: 'Could not get address for location $e');
    }
  }

  getDataFromLocalStore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _name = prefs.getString('name');
    _email = prefs.getString('email');
    _id = prefs.getString('id');
    _image = prefs.getString('image');
    _token = prefs.getString('token');
    notifyListeners();

    log('$_name');
  }

  insertDataIntoLocalStore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString('name', _name!);
    prefs.setString('email', _email!);
    prefs.setString('id', _id!);
    prefs.setString('image', _image!);

    getDataFromLocalStore();
    notifyListeners();
  }

  String? _otherUserName;
  String? _otherUserImage;

  String? get otherUserName => _otherUserName;
  String? get otherUserImage => _otherUserImage;

  //getName by id from firestore
  Future<String> getNameById(String id) async {
    String name = '';
    await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .get()
        .then((value) {
      _otherUserImage = value['image'];
      _otherUserName = value['name'];
      notifyListeners();
    });
    return name;
  }
}
