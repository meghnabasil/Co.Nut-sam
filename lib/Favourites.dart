import 'package:flutter/material.dart';

class Favourites extends StatefulWidget {
  const Favourites({super.key});

  @override
  State<Favourites> createState() => _FavouritesState();
}

class _FavouritesState extends State<Favourites> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
    backgroundColor: Color(0xFF033015),
    title: const Text(
    "Fav",
    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
    ),
    centerTitle: true,
    ),
    );
  }
}
