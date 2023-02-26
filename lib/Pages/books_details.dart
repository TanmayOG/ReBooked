import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_olx/Constant/constants.dart';
import 'package:student_olx/Model/books_model.dart';
import 'package:student_olx/Model/chat_model.dart';
import 'package:student_olx/Pages/Chats/chat_room.dart';

class BooksDetails extends StatefulWidget {
  BookModel bookModel;
  final km;
  BooksDetails({super.key, required this.bookModel, this.km});

  @override
  State<BooksDetails> createState() => _BooksDetailsState();
}

class _BooksDetailsState extends State<BooksDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: FloatingActionButton.extended(
            onPressed: FirebaseAuth.instance.currentUser!.uid ==
                    widget.bookModel.sellerId
                ? null
                : () async {
                    var chatRoom =
                        await getChatRoomMOdel(widget.bookModel.sellerId!)
                            .then((chatRoom) {
                      if (chatRoom != null) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChatRoomScreen(
                                      chatModel: chatRoom,
                                      // chatId: data[
                                      //     'tokenId'],
                                      // tokenId:
                                      //     widget.token,
                                      otherId: widget.bookModel.sellerId,
                                    )));
                      }
                    });
                  },
            backgroundColor: buttonColor,
            isExtended: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            label: const Text('Interest'),
          ),
        ),
        backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          title: const Text("Detail Book",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
        body: Padding(
          padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * 0.02,
              right: MediaQuery.of(context).size.width * 0.02),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(widget.bookModel.image!,
                          height: 300, width: 180, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 150,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.bookModel.title!,
                            style: const TextStyle(
                              // overflow: TextOverflow.ellipsis,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(widget.bookModel.author!),
                            subtitle: const Text("Author"),
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Rs ${widget.bookModel.price!}'),
                                const SizedBox(width: 10),
                                Text('${widget.km!}Km',
                                    style: const TextStyle(
                                      color: Colors.black54,
                                    )),
                              ],
                            ),
                            subtitle: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text("Price"),
                                Text("Distance",
                                    style: TextStyle(
                                      color: Colors.black54,
                                    )),
                              ],
                            ),
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(widget.bookModel.sellerName!),
                            trailing: CircleAvatar(
                              radius: 20,
                              backgroundImage:
                                  NetworkImage(widget.bookModel.sellerImage!),
                            ),
                            subtitle: Row(
                              children: const [
                                Text("Seller"),
                                SizedBox(width: 10),
                                Icon(Icons.verified,
                                    color: Colors.green, size: 15),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(widget.bookModel.lang!,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        const Text("Language",
                            style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      children: [
                        Text(widget.bookModel.pubyear!,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        const Text("Published",
                            style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      children: [
                        Text(widget.bookModel.pages!,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        const Text("Pages",
                            style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  "Description",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.bookModel.description!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black45,
                  ),
                ),
                const SizedBox(height: 150),
              ],
            ),
          ),
        ));
  }
}
