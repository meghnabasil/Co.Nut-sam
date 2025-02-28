import 'package:dup/view/viewCoco.dart';
import 'package:dup/view/viewTools.dart';
import 'package:flutter/material.dart';

class Viewcocoandtools extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("View Products", style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF033015),
          bottom: TabBar(
            labelColor: Colors.white, // Selected tab text color
            unselectedLabelColor: Colors.white70, // Unselected tab text color
            indicatorColor: Colors.white, // Indicator color
            tabs: [
              Tab(text: "Coconut Products"),
              Tab(text: "Tools"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ProductDisplayPage(),
            ToolDisplayPage(),
          ],
        ),
      ),
    );
  }
}
