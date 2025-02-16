import 'package:dup/view/Favourites.dart';
import 'package:dup/view/Tools.dart';
import 'package:dup/view/Tools.dart';
import 'package:dup/view/firstpage.dart';
import 'package:dup/view/login.dart';
import 'package:dup/view/onDoorstep.dart';
import 'package:dup/view/profile.dart';
import 'package:dup/view/subscription.dart';
import 'package:dup/view/onDoorstep.dart';
import 'package:dup/view/subscription.dart';
import 'package:dup/view/vendor_home.dart';
import 'package:dup/view/workerlist.dart';
import 'package:dup/view/workerlist.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:dup/controller/session.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _userName="User name";
  String _userEmail="user@gmail.com";

  @override
  void initState() {
    super.initState();
    _loadUserSession();
  }


  Future<void> _loadUserSession() async {
    Map<String, dynamic>? userDetails = await Session.getUserDetails();

    setState(() {
      _userName = userDetails?['name'] ;
      _userEmail = userDetails?['email'] ;
    });
  }



  final List<String> carouselImages = [
    'asset/nut.jpg',
    'asset/oi.jpg',
    'asset/tender.jpg',
  ];



  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF033015),
        // backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        toolbarHeight: 66,
        title:Image.asset('asset/img.png',height: 25,),
        // title: Image.asset('asset/image.png',height: 25,),
          centerTitle: true,
      ),

      drawer: Drawer(
        backgroundColor: Colors.white, // Change background color if needed
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(_userName!),
              accountEmail:Text(_userEmail!),
              currentAccountPicture: const CircleAvatar(
                backgroundImage: AssetImage("assets/profile.jpg"),
              ),
              decoration: const BoxDecoration(
                // image: DecorationImage(
                //   image: AssetImage('asset/le.jpg'),
                //   fit: BoxFit.cover,
                // ),
                color:  Color(0xFF272b19),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.black), // Change icon color
              title: const Text("Home"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.work, color: Colors.black), // Change icon color
              title: const Text("Workers"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.black),
              title: const Text("Log Out"),
              onTap: ()  async {
                try {
                  await FirebaseAuth.instance.signOut(); // Logs out from Firebase
                  await Session.clearSession(); // Clears SharedPreferences session

                  // Navigate to login screen and remove all previous screens
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => UserForm()),
                        (route) => false,
                  );
                } catch (e) {
                  print("Logout error: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Logout failed! Please try again.")),
                  );
                }
              }, // Call logout function
            ),

          ],
        ),
      ),
body: SingleChildScrollView(
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(0.0),
          child: Image.asset(
            'asset/banner.jpeg',
            width: double.infinity,  // Image will take full width
            height: 250,  // Adjust height as needed
            fit: BoxFit.cover,  // Adjust fit as needed
          ),
        ),

        // Card Grid


          const SizedBox(height: 35),
        const Text(
          "Go Natural. Go Co.Nut! 🥥",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,

            fontWeight: FontWeight.bold,
            color: Color(0xFF033015),
          ),
        ),


        const SizedBox(height: 35),
          CarouselSlider(
            options: CarouselOptions(
              height: 200,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 23), // Adjust time (e.g., 3 seconds)
              enlargeCenterPage: true,
              aspectRatio: 16 / 9,
              viewportFraction: 0.9,
            ),
            items: carouselImages.map((imagePath) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Image.asset(
                  imagePath,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              );
            }).toList(),
          ),
        // const SizedBox(height: 70),

        const SizedBox(height: 50), // Space bet// ween Carousel and Divider

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildButton('Worker', WorkersList()),
              _buildButton('Sell', Subscription()),
              _buildButton('Products', VendorDashboard()),
            ],
          ),
        ),

        // subscribe now


        const SizedBox(height: 30),




        const SizedBox(height: 10),

    Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15.0),
    child: Text(
          "Experience the Magic of Coconuts ",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF033015),
          ),
        ),
    ),
        const SizedBox(height: 20),


        CarouselSlider(
          options: CarouselOptions(
            height: 200,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 3), // Adjust time (e.g., 3 seconds)
            enlargeCenterPage: true,
            aspectRatio: 16 / 9,
            viewportFraction: 0.5,
          ),
          items: carouselImages.map((imagePath) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: Image.asset(
                imagePath,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 70),

        // Clickable Subscribe Card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Subscription()),
              );
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Color(0xFF033015),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_clock, color: Colors.white, size: 30),
                    SizedBox(width: 10),
                    Text(
                      'Subscribe Now',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),


      const SizedBox(height: 45),
        // Caption Text
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Text(
            'Explore Our Best Picks!',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color:Colors.black87,
            ),
          ),
        ),


        const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 50,
              mainAxisSpacing: 50,
              childAspectRatio: 1.0,
              children: [
                _buildCard(context, 'Coco Products', 'asset/all.webp',  Product()),
                _buildCard(context, 'Workers', 'asset/work.webp', WorkersList()),
                _buildCard(context, 'On Doorstep', 'asset/delivery.webp', Doorsteps()),
                _buildCard(context, 'Tools', 'asset/mach.webp', ListOfTools()),
              ],
            ),
          ),

        const SizedBox(height: 65),
        //subscrption history and favourits
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.0),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(45),
              gradient: LinearGradient(
                colors: [Color(0xFF033015), Colors.grey], // Background gradient
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 20,
                  offset: Offset(4, 4), // Bottom-right shadow
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.2),
                  blurRadius: 5,
                  offset: Offset(-4, -4), // Top-left highlight
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Subscription Button with Icon
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Subscription()),);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:Colors.white, // Button color
                    foregroundColor:Color(0xFF033015), // Text color
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(35),
                    ),
                    elevation: 5, // Button shadow
                  ),
                  icon: Icon(Icons.star, color: Color(0xFF033015)), // Subscription icon
                  label: const Text(
                    "Subscriptions",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                ),

                // Favorite Button with Icon
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Subscription()),);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // Button color
                    foregroundColor: Color(0xFF033015), // Text color
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(35),
                    ),
                    elevation: 5, // Button shadow
                  ),
                  icon: Icon(Icons.favorite, color: Color(0xFF033015)), // Favorite icon
                  label: const Text(
                    "Favourites",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                ),
              ],
            ),
          ),
),

        const SizedBox(height: 80),

      ],
    ),
),
    );
  }



  Widget _buildButton(String text, Widget page) {
    return GestureDetector(
      onTap: () => _navigateToPage(context, page),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xFF033015), width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 24),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),  );
  }



  Widget _buildCard(BuildContext context, String title, String imagePath, Widget page) {
    return GestureDetector(
      onTap: () => _navigateToPage(context, page),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 100,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );

  }
}
