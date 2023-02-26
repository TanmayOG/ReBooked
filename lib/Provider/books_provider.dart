// ignore_for_file: avoid_print

import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:student_olx/Constant/constants.dart';
import 'package:student_olx/Model/books_model.dart';
import 'package:student_olx/Provider/auth_provider.dart';
import 'package:uuid/uuid.dart';

class BooksProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  getBooks() {
    FirebaseFirestore.instance.collection("books").snapshots();
  }

  searchBooks(String search) {
    FirebaseFirestore.instance
        .collection(bookCollection)
        .where("title", isGreaterThanOrEqualTo: search)
        .snapshots();
  }

  addBooks(BookModel booksModel, context) async {
    _isLoading = true;
    showLoadingDialog(context);
    notifyListeners();
    await FirebaseFirestore.instance
        .collection(bookCollection)
        .add(booksModel.toJson())
        .then((value) {
      _isLoading = false;
      Navigator.pop(context);
      log("Book Added");
      Fluttertoast.showToast(msg: "Book Listed Successfully");
    }).catchError((error) {
      print("Failed to add book: $error");
      Fluttertoast.showToast(msg: "Failed to add book");
      _isLoading = false;
      Navigator.pop(context);
      notifyListeners();
    });
  }

  deleteBooks(String id, context) async {
    _isLoading = true;
    showLoadingDialog(context);
    notifyListeners();
    await FirebaseFirestore.instance
        .collection(bookCollection)
        .doc(id)
        .delete()
        .then((value) {
      _isLoading = false;
      Navigator.pop(context);
      log("Book Deleted");
    }).catchError((error) {
      print("Failed to delete book: $error");
      _isLoading = false;
      Navigator.pop(context);
      notifyListeners();
    });
  }

  updateBooks(BookModel booksModel, context) async {
    _isLoading = true;
    showLoadingDialog(context);
    notifyListeners();
    await FirebaseFirestore.instance
        .collection(bookCollection)
        .doc(booksModel.id)
        .update(booksModel.toJson())
        .then((value) => print("Book Updated"))
        .catchError((error) {
      print("Failed to update book: $error");
      _isLoading = false;
      Navigator.pop(context);
      notifyListeners();
    });
  }

  Future<String> uploadImage(String path, File image) async {
    try {
      String imageId = const Uuid().v4();
      final ref = FirebaseStorage.instance.ref('$path/$imageId');
      final task = ref.putFile(image);
      final snapshot = await task.whenComplete(() => null);
      final url = await snapshot.ref.getDownloadURL();
      return url;
    } on FirebaseException catch (e) {
      print(e);
      return "";
    }
  }

  deleteImage(String path) async {
    try {
      final ref = FirebaseStorage.instance.ref(path);
      await ref.delete();
    } on FirebaseException catch (e) {
      print(e);
    }
  }
}
