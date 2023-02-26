import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:student_olx/Constant/constants.dart';
import 'package:student_olx/Model/books_model.dart';
import 'package:student_olx/Pages/login.dart';
import 'package:student_olx/Provider/books_provider.dart';
import 'package:student_olx/Provider/user_provider.dart';
import 'package:student_olx/Widgets/custom_text_field.dart';
import 'package:uuid/uuid.dart';

class AddBooks extends StatefulWidget {
  final BookModel? bookModel;
  final bool isEdit;
  const AddBooks({super.key, this.bookModel, this.isEdit = false});

  @override
  State<AddBooks> createState() => _AddBooksState();
}

class _AddBooksState extends State<AddBooks> {
  final TextEditingController _bookNameController = TextEditingController();
  final TextEditingController _bookAuthorController = TextEditingController();
  final TextEditingController _bookPriceController = TextEditingController();
  final TextEditingController _bookDescriptionController =
      TextEditingController();
  final TextEditingController _bookPrices = TextEditingController();
  final TextEditingController _bookPubYear = TextEditingController();
  final TextEditingController _bookPages = TextEditingController();

  String? lang;

  List langList = [
    "ENG",
    "HIN",
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      _bookNameController.text = widget.bookModel!.title!;
      _bookAuthorController.text = widget.bookModel!.author!;
      _bookDescriptionController.text = widget.bookModel!.description!;
      _bookPrices.text = widget.bookModel!.price!;
      _bookPubYear.text = widget.bookModel!.pubyear!;
      _bookPages.text = widget.bookModel!.pages!;
      lang = widget.bookModel!.lang;
    }
  }

  langDropDown() {
    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 30),
      child: SizedBox(
        height: 50,
        width: MediaQuery.of(context).size.width,
        child: DropdownButton(
          icon: const Icon(Icons.arrow_drop_down),
          hint: const Text("Select Language"),
          value: lang,
          isExpanded: true,
          onChanged: (value) {
            setState(() {
              lang = value.toString();
            });
          },
          items: langList.map((value) {
            return DropdownMenuItem(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }

  String path = "";

  final ImagePicker _picker = ImagePicker();

  Future getImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      path = image!.path;
    });
  }

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

      setState(() {
        geoPoint = GeoPoint(position.latitude, position.longitude);
        address = "${place.locality}, ${place.country}";
      });
    } catch (e) {
      Fluttertoast.showToast(msg: 'Could not get address for location $e');
    }
  }

  GeoPoint? geoPoint;
  String address = "";

  onSaved(
      {String? bookName,
      String? bookAuthor,
      String? bookPrice,
      String? bookDescription,
      String? bookPrices}) async {
    if (_formKey.currentState!.validate()) {
      if (path == "") {
        Fluttertoast.showToast(msg: "Please select image");
      } else {
        await uploadImage();
        await determinePosition();
        var id = const Uuid().v4();

        final userInfo = Provider.of<UserProvider>(context, listen: false);

        BookModel bookModel = BookModel(
          id: id,
          sellerImage: userInfo.image,
          sellerName: userInfo.name,
          sellerEmail: userInfo.email,
          title: _bookNameController.text,
          author: _bookAuthorController.text,
          price: _bookPriceController.text,
          description: _bookDescriptionController.text,
          location: geoPoint,
          lang: lang,
          pages: _bookPages.text,
          pubyear: _bookPubYear.text,
          image: url,
          sellerId: userInfo.id,
        );
        await Provider.of<BooksProvider>(context, listen: false)
            .addBooks(bookModel, context);

        _bookNameController.clear();
        _bookAuthorController.clear();
        _bookPriceController.clear();
        _bookDescriptionController.clear();
        _bookPrices.clear();
        _bookPubYear.clear();
        _bookPages.clear();
        setState(() {
          path = "";
        });
      }
    } else {
      log("Error");
    }
  }

  String? url;
  uploadImage() async {
    try {
      var id = const Uuid().v4();

      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child("books/$id");
      UploadTask uploadTask = ref.putFile(File(path));
      await uploadTask.then((res) async {
        await res.ref.getDownloadURL().then((value) {
          setState(() {
            url = value;
          });
        });
      });
    } catch (e) {
      Navigator.pop(context);
      print(e);
    }
  }

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        actions: [
          widget.isEdit
              ? IconButton(
                  onPressed: () {
                    onSaved();
                  },
                  icon: const Icon(Icons.edit),
                )
              : Container()
        ],
        title: const Text("Seller",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(
                height: 30,
              ),
              GestureDetector(
                onTap: () {
                  getImage();
                },
                child: Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                  ),
                  child: widget.isEdit
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(widget.bookModel!.image!,
                              fit: BoxFit.cover))
                      : path == ""
                          ? const Icon(
                              Icons.add_a_photo,
                              size: 50,
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.file(File(path), fit: BoxFit.cover)),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              CustomTextField(
                hint: "Book Name",
                icon: Icons.book,
                onClick: (value) {},
                type: TextInputType.text,
                controller: _bookNameController,
              ),
              CustomTextField(
                hint: "Book Author",
                icon: Icons.person,
                onClick: (value) {},
                type: TextInputType.text,
                controller: _bookAuthorController,
              ),
              CustomTextField(
                hint: "Book Price",
                icon: Icons.currency_rupee,
                onClick: (value) {},
                type: TextInputType.number,
                controller: _bookPriceController,
              ),
              CustomTextField(
                hint: "Book Publication Year",
                icon: Icons.date_range,
                onClick: (value) {},
                type: TextInputType.number,
                controller: _bookPubYear,
              ),
              CustomTextField(
                hint: "Book Pages",
                icon: Icons.pageview_sharp,
                onClick: (value) {},
                type: TextInputType.number,
                controller: _bookPages,
              ),
              langDropDown(),
              CustomTextField(
                hint: "Book Description",
                icon: Icons.description,
                onClick: (value) {},
                type: TextInputType.text,
                controller: _bookDescriptionController,
              ),
              customButton(
                  text: 'Add Books',
                  onPressed: Provider.of<BooksProvider>(context).isLoading
                      ? null
                      : () {
                          widget.isEdit ? onEdit() : onSaved();
                        },
                  color: buttonColor,
                  textColor: Colors.white),
              const SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }

  onEdit() async {
    if (_formKey.currentState!.validate()) {
      if (path == "") {
        Fluttertoast.showToast(msg: "Please select image");
      } else {
        determinePosition();
        var id = const Uuid().v4();

        final userInfo = Provider.of<UserProvider>(context, listen: false);

        await uploadImage();
        BookModel bookModel = BookModel(
          id: id,
          sellerImage: userInfo.image,
          sellerName: userInfo.name,
          sellerEmail: userInfo.email,
          title: _bookNameController.text,
          author: _bookAuthorController.text,
          price: _bookPriceController.text,
          description: _bookDescriptionController.text,
          location: geoPoint,
          lang: lang,
          pages: _bookPages.text,
          pubyear: _bookPubYear.text,
          image: url,
          sellerId: userInfo.id,
        );
        await Provider.of<BooksProvider>(context, listen: false)
            .updateBooks(bookModel, context);
      }
    }
  }

// custom textfield for books form

}
