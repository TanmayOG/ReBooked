import 'package:cloud_firestore/cloud_firestore.dart';

class BookModel {
  // 2nd hand books

  String? id;
  String? title;
  String? pubyear;
  String? lang;
  String? pages;
  String? author;
  String? description;
  String? image;
  String? price;
  String? sellerId;
  String? sellerName;
  String? sellerEmail;
  String? sellerImage;
  GeoPoint? location;

  BookModel({
    this.id,
    this.title,
    this.author,
    this.pubyear,
    this.lang,
    this.pages,
    this.description,
    this.image,
    this.price,
    this.location,
    this.sellerId,
    this.sellerName,
    this.sellerEmail,
    this.sellerImage,
  });

  BookModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    lang = json['lang'];
    pubyear = json['pubyear'];
    pages = json['pages'];
    author = json['author'];
    description = json['description'];
    image = json['image'];
    location = json['location'];
    price = json['price'];
    sellerId = json['sellerId'];
    sellerName = json['sellerName'];
    sellerEmail = json['sellerEmail'];
    sellerImage = json['sellerImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['lang'] = lang;
    data['pubyear'] = pubyear;
    data['pages'] = pages;
    data['author'] = author;
    data['location'] = location;
    data['description'] = description;
    data['image'] = image;
    data['price'] = price;
    data['sellerId'] = sellerId;
    data['sellerName'] = sellerName;
    data['sellerEmail'] = sellerEmail;
    data['sellerImage'] = sellerImage;
    return data;
  }
}
