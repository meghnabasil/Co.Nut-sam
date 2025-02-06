import 'package:flutter/material.dart';

class Subscription extends StatefulWidget {
  const Subscription({super.key});

  @override
  State<Subscription> createState() => _SubscriptionState();
}

class _SubscriptionState extends State<Subscription> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
    backgroundColor: Color(0xFF033015),
    title: const Text(
    "Sub",
    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
    ),
    centerTitle: true,
    ),
    );
  }
}
