import 'package:dup/view/Booking_history.dart';
import 'package:dup/view/Home.dart';
import 'package:dup/view/Booking_history.dart';
import 'package:dup/view/bottomnav.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();

}

class _HistoryState extends State<History> {
  String? userId;

  void initState() {
    super.initState();
    _getUserId(); // Fetch user ID when the widget initializes
  }

  void _getUserId() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid; // Assign the user ID
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF033015),
          iconTheme: IconThemeData(color: Colors.white),// AppBar color (greenAccent)
          toolbarHeight: 80, // Custom AppBar height
          title: const Text('' ,style: TextStyle(color: Colors.white),),

          leading: IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                // Navigate back to HomeScreen
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => BottomBarScreen()),
                      (route) => false,); // Removes all previous routes
              }
          ),


          bottom: PreferredSize(
            preferredSize: Size.fromHeight(50), // Height of the TabBar
            child: Container(
              color: Colors.white, // TabBar color (blueAccent)
              child: TabBar(
                indicatorColor: Colors.brown, // White indicator line color
                indicatorWeight: 5, // Thickness of the indicator line
                labelColor: Colors.black, // Color for selected tab icons
                unselectedLabelColor: Colors.black,
                labelPadding: EdgeInsets.symmetric(horizontal:10.0),// Color for unselected tab icons
                tabs: const [
                  // Tab(icon: Icon(Icons.add_shopping_cart_outlined), text: 'items' ),
                  Tab(icon: Icon(Icons.history),text: 'order history'),
                  Tab(icon: Icon(Icons.delivery_dining),text: 'booking history'),
                ],
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  const Center(child: Text("Order History")),

                  // Show BookingHistoryPage only if userId is available
                  userId != null
                      ?BookingHistoryScreen(userId: userId!)
                      : const Center(child: CircularProgressIndicator()),
                ],

              ),
            ),
          ],
        ),
      ),
    );
  }
}
