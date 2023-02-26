import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_olx/Constant/constants.dart';
import 'package:student_olx/Model/books_model.dart';
import 'package:student_olx/Pages/add_book.dart';

class SellerScreen extends StatefulWidget {
  const SellerScreen({super.key});

  @override
  State<SellerScreen> createState() => _SellerScreenState();
}

class _SellerScreenState extends State<SellerScreen> {
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddBooks()));
        },
        backgroundColor: buttonColor,
        isExtended: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        label: const Text('Add Books'),
      ),
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        title: const Text("Seller",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(bookCollection)
                  .where("sellerId",
                      isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text("Something went wrong"),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("No Books"),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var data = snapshot.data!.docs[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network(
                            snapshot.data!.docs[index]["image"],
                            height: 100,
                            width: 100,
                          ),
                          Flexible(
                            child: ListTile(
                              title: Text(data["title"]),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(data["author"]),
                                  Text('Rs ${data["price"]}'),
                                ],
                              ),
                              leading: const Icon(Icons.book),
                              trailing: const Icon(Icons.delete),
                              onTap: () {
                                BookModel bookModel = BookModel(
                                  title: data["title"],
                                  author: data["author"],
                                  price: data["price"],
                                  image: data["image"],
                                  description: data["description"],
                                  sellerId: data["sellerId"],
                                  id: data["id"],
                                  lang: data["lang"],
                                  pages: data["pages"],
                                  pubyear: data["pubyear"],
                                  location: data["location"],
                                  sellerEmail: data["sellerEmail"],
                                  sellerName: data["sellerName"],
                                  sellerImage: data["sellerImage"],
                                );

                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text("Delete Book"),
                                      content: const Text("Are you sure?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text("No"),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            try {
                                              log("${bookModel.id} ");
                                              await FirebaseFirestore.instance
                                                  .collection(bookCollection)
                                                  .doc(data.id)
                                                  .delete()
                                                  .then((value) {
                                                log("deleted");
                                                Navigator.pop(context);
                                              });
                                            } catch (e) {
                                              print(e);
                                            }
                                          },
                                          child: const Text("Yes"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            )
          ],
        ),
      ),
    );
  }

// custom textfield for books form

}
