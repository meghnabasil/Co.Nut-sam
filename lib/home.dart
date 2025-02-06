import 'package:dup/Favourites.dart';
import 'package:dup/Tools.dart';
import 'package:dup/firstpage.dart';
import 'package:dup/onDoorstep.dart';
import 'package:dup/profile.dart';
import 'package:dup/subscription.dart';
import 'package:dup/workerlist.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {


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
              accountName: const Text('Meghna Basil PT'),
              accountEmail: const Text('meghnabasil2001@gmail.com'),
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
              leading: const Icon(Icons.logout, color: Colors.black), // Change icon color
              title: const Text("Log Out"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
body: ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(7.0),
          child: Image.asset(
            'asset/banner.jpeg',
            width: double.infinity,  // Image will take full width
            height: 250,  // Adjust height as needed
            fit: BoxFit.cover,  // Adjust fit as needed
          ),
        ),
        const SizedBox(height: 10), // Space between Carousel and Divider
        const Divider(thickness: 2, color: Colors.grey),
        const SizedBox(height: 10),
        // Card Grid
          const SizedBox(height: 10),
          CarouselSlider(
            options: CarouselOptions(
              height: 200,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3), // Adjust time (e.g., 3 seconds)
              enlargeCenterPage: true,
              aspectRatio: 16 / 9,
              viewportFraction: 0.8,
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

        // Subscription and Favorite Buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.0),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [Colors.grey, Colors.grey], // Background gradient
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
                    backgroundColor: Color(0xFF260e04), // Button color
                    foregroundColor: Colors.white, // Text color
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(35),
                    ),
                    elevation: 5, // Button shadow
                  ),
                  icon: Icon(Icons.star, color: Colors.white), // Subscription icon
                  label: const Text(
                    "Subscriptions",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                ),

                // Favorite Button with Icon
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Favourites()),);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF260e04), // Button color
                    foregroundColor: Colors.white, // Text color
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(35),
                    ),
                    elevation: 5, // Button shadow
                  ),
                  icon: Icon(Icons.favorite, color: Colors.white), // Favorite icon
                  label: const Text(
                    "Favourites",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 60),


        // Caption Text
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Center(
            child: Text(
            'Explore Our Best Picks!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color:Colors.black87,
            ),
          ),
        ),
        ),

        const SizedBox(height: 10),
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
        ],
      ),

   );
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
