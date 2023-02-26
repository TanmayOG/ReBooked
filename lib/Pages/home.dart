// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:student_olx/Constant/constants.dart';
import 'package:student_olx/Model/books_model.dart';
import 'package:student_olx/Pages/books_details.dart';

import '../Provider/user_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scare = GlobalKey<ScaffoldState>();

  getDistance(GeoPoint? storeGeoPoint) {
    final geoPoint = Provider.of<UserProvider>(context, listen: false).geoPoint;
    double distanceInMeters = Geolocator.distanceBetween(
        storeGeoPoint!.latitude,
        storeGeoPoint.longitude,
        geoPoint!.latitude,
        geoPoint.longitude);
    // distance in Km to 2 decimal places
    double distanceInKm =
        double.parse((distanceInMeters / 1000).toStringAsFixed(2));
    return distanceInKm;
  }

  Future<List<BookModel>> getBooks() async {
    final userInfo = Provider.of<UserProvider>(context, listen: false);
    var userLoc = userInfo.geoPoint;

    List<BookModel> books = [];
    var bookData = await FirebaseFirestore.instance
        .collection(bookCollection)
        .where('sellerId', isNotEqualTo: userInfo.id)
        .get();

    for (var element in bookData.docs) {
      var book = BookModel.fromJson(element.data());
      books.add(book);
    }

    books.sort((a, b) {
      var aLoc = a.location;
      var bLoc = b.location;

      double aDistance = Geolocator.distanceBetween(
          aLoc!.latitude, aLoc.longitude, userLoc!.latitude, userLoc.longitude);
      double bDistance = Geolocator.distanceBetween(
          bLoc!.latitude, bLoc.longitude, userLoc.latitude, userLoc.longitude);

      return aDistance.compareTo(bDistance);
    });

    return books;
  }

  searchBook() async {
    final userInfo = Provider.of<UserProvider>(context, listen: false);
    var userLoc = userInfo.geoPoint;

    List<BookModel> books = [];
    var bookData = await FirebaseFirestore.instance
        .collection(bookCollection)
        // .where('sellerId', isNotEqualTo: userInfo.id)M
        .where('title', isGreaterThanOrEqualTo: keyword)
        .get();

    for (var element in bookData.docs) {
      var book = BookModel.fromJson(element.data());
      books.add(book);
    }

    books.sort((a, b) {
      var aLoc = a.location;
      var bLoc = b.location;

      double aDistance = Geolocator.distanceBetween(
          aLoc!.latitude, aLoc.longitude, userLoc!.latitude, userLoc.longitude);
      double bDistance = Geolocator.distanceBetween(
          bLoc!.latitude, bLoc.longitude, userLoc.latitude, userLoc.longitude);

      return aDistance.compareTo(bDistance);
    });

    return books;
  }

  String keyword = "";
  TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final userInfo = Provider.of<UserProvider>(context);
    return SafeArea(
      child: Scaffold(
        key: _scare,
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15),
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        showAboutDialog(
                            context: context,
                            anchorPoint: const Offset(0.5, 0.5),
                            applicationIcon: const CircleAvatar(
                                radius: 25,
                                backgroundColor: buttonColor,
                                child: Text("Re",
                                    style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white))),
                            applicationName: "ReBooked",
                            applicationVersion: "1.0.0",
                            children: [
                              Text(
                                "ReBooked is a platform where you can sell your old books and buy new books at a very low price. You can also donate your old books to the needy people. You can also find the nearest book store from your location.",
                                style: GoogleFonts.poppins(fontSize: 16),
                              ),
                            ]);
                      },
                      child: CircleAvatar(
                          radius: 25,
                          backgroundColor: buttonColor,
                          child: Text("Re",
                              style: GoogleFonts.racingSansOne(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white))),
                    ),
                    Flexible(
                      child: ListTile(
                        title: Text(
                          "ReBooked",
                          style: GoogleFonts.racingSansOne(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${userInfo.address ?? '..loading'} 🏡 ',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    GestureDetector(
                      child: CircleAvatar(
                        radius: 23,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: NetworkImage(
                          userInfo.image!,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  height: 60,
                  alignment: Alignment.center,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 1, vertical: 5),
                  child: TextFormField(
                    controller: searchController,
                    onChanged: (value) {
                      setState(() {
                        keyword = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search title, author',
                      hintStyle:
                          const TextStyle(color: Colors.grey, fontSize: 15),
                      fillColor: Colors.grey[100],
                      filled: true,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                keyword != ""
                    ? Container()
                    : const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Discover Books",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                const SizedBox(
                  height: 15,
                ),
                FutureBuilder(
                  future: keyword != "" ? searchBook() : getBooks(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasError) {
                      return const Text('Something went wrong');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    // List<> snapDat = snapshot.data!.docs;
                    List<BookModel> books = snapshot.data as List<BookModel>;

                    return GridView.builder(
                      itemCount: books.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          // mainAxisExtent: MediaQuery.of(context).size.height / 1.35,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.5),
                      itemBuilder: (context, index) {
                        var book = books[index];
// sort snapshot data by distance

                        return GestureDetector(
                          onTap: () {
                            BookModel bookModel = BookModel(
                              lang: book.lang,
                              pages: book.pages,
                              pubyear: book.pubyear,
                              id: snapshot.data!.docs[index].id,
                              title: book.title,
                              author: book.author,
                              image: book.image,
                              price: book.price,
                              description: book.description,
                              sellerEmail: book.sellerEmail,
                              sellerName: book.sellerName,
                              sellerImage: book.sellerImage,
                              location: book.location,
                              sellerId: book.sellerId,
                            );
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => BooksDetails(
                                          bookModel: bookModel,
                                          km: getDistance(book.location),
                                        )));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              // color: Colors.black,
                              elevation: 0,
                              child: Column(
                                children: [
                                  cachedNetworkImage(book.image!),
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          book.author!,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black45),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(book.title!,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black)),
                                      ],
                                    ),
                                    // trailing: Padding(
                                    //   padding:
                                    //       const EdgeInsets.only(right: 10.0),
                                    //   child: Text(
                                    //       'Rs.${snapshot.data!.docs[index]['price']}',
                                    //       style: const TextStyle(
                                    //           fontSize: 14,
                                    //           color: Colors.black)),
                                    // ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Rs.${book.price}',
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black)),
                                          Text(
                                              '${getDistance(book.location) ?? '..loading'} Km',
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black)),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  cachedNetworkImage(String image) {
    return CachedNetworkImage(
        imageUrl: image,
        placeholder: (context, url) => Center(
                child: Container(
              alignment: Alignment.center,
              height: 200,
              width: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                    height: 50,
                    width: 50,
                    child: CupertinoActivityIndicator(
                      radius: 15,
                      animating: true,
                      key: UniqueKey(),
                    )),
              ),
            )),
        imageBuilder: (context, imageProvider) => ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                height: MediaQuery.of(context).size.height / 4,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ));
  }
}
