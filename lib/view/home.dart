import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dup/model/products_model.dart';
import 'package:dup/view/Favourites.dart';
import 'package:dup/view/Tools.dart';
import 'package:dup/view/cart.dart';
import 'package:dup/view/firstpage.dart';
import 'package:dup/view/login.dart';
import 'package:dup/view/onDoorstep.dart';
import 'package:dup/view/productlist.dart';
import 'package:dup/view/profile.dart';
import 'package:dup/view/subscription.dart';
import 'package:dup/view/vendor_home.dart';
import 'package:dup/view/videoplayer.dart';
import 'package:dup/view/workerlist.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:dup/controller/session.dart';

import '../controller/videoWidget.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _userName = "User name";
  String _userEmail = "user@gmail.com";
  bool _isVendor = false;
  int _currentBannerIndex = 0;
  final PageController _pageController = PageController();
  List<String> carouselImages = [];
  late List<Map<String, String>> advertisements = [];
  List<Map<String, String>> imageAdvertisements = [];
  List<Map<String, String>> videoAdvertisements = [];

  @override
  void initState() {
    super.initState();
    _loadUserSession();
    _fetchAdvertisements();
  }

  Future<void> _loadUserSession() async {
    Map<String, dynamic>? userDetails = await Session.getUserDetails();

    /*setState(() {
      _userName = userDetails?['name'] ?? _userName;
      _userEmail = userDetails?['email'] ?? _userEmail;
    });*/

    if (userDetails != null) {
      setState(() {
        _userName = userDetails['name'] ?? _userName;
        _userEmail = userDetails['email'] ?? _userEmail;
      });

      // Fetch user's isVendor status from Firestore
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (userId.isNotEmpty) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
        if (userDoc.exists) {
          setState(() {
            _isVendor = userDoc['isVendor'] ?? false;
          });
        }
      }
    }


  }

  final List<String> companyLogos = [
    'asset/nut.jpg',
    'asset/nut.jpg',
    'asset/nut.jpg',
    'asset/nut.jpg',
  ];

  // List of banner images for PageView at top
  final List<String> bannerImages = [
    'asset/banner.jpeg',
    'asset/banner.jpeg',
    'asset/banner.jpeg',
  ];

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  Future<void> _fetchAdvertisements() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('advertisements').get();

      List<Map<String, String>> imageAds = [];
      List<Map<String, String>> videoAds = [];

      for (var doc in snapshot.docs) {
        String imageUrl = doc['imageUrl'] ?? '';
        String videoUrl = doc['videoUrl'] ?? '';
        String productId = doc['productId'] as String;

        if (imageUrl.isNotEmpty) {
          imageAds.add({'imageUrl': imageUrl, 'productId': productId});
        }
        if (videoUrl.isNotEmpty) {
          videoAds.add({'videoUrl': videoUrl, 'productId': productId});
        }
      }

      setState(() {
        imageAdvertisements = imageAds;
        videoAdvertisements = videoAds;
      });
    } catch (e) {
      print("Error fetching advertisements: $e");
    }
  }

  Widget _buildBannerIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(bannerImages.length, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentBannerIndex == index
                ? Colors.white
                : Colors.white.withOpacity(0.5),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF033015),
        iconTheme: const IconThemeData(color: Colors.white),
        toolbarHeight: 66,
        title: Image.asset(
          'asset/img.png',
          height: 25,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined),
            onPressed: () {
              // Handle notification click
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(_userName),
              accountEmail: Text(_userEmail),
              currentAccountPicture: const CircleAvatar(
                backgroundImage: AssetImage("assets/profile.jpg"),
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF272b19),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.black),
              title: const Text("Home"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.work, color: Colors.black),
              title: const Text("Workers"),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                    builder: (context) => WorkersList(),),);
              },
            ),

            ListTile(
              leading: const Icon(Icons.shopping_cart, color: Colors.black),
              title: const Text("Your Cart"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Cart(),),);
              },
            ),

            if (_isVendor) // Show only if user is a vendor
              ListTile(
                leading: const Icon(Icons.house, color: Colors.black),
                title: const Text("Vendor dashboard"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VendorDashboard(),
                    ),
                  );
                },
              ),
            Divider(color: Colors.black, // Line color
              thickness: 2,        // Line thickness
              height: 20,
            ),



            ListTile(
              leading: const Icon(Icons.logout, color: Colors.black),
              title: const Text("Log Out"),
              onTap: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                  await Session.clearSession();

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => UserForm()),
                    (route) => false,
                  );
                } catch (e) {
                  print("Logout error: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Logout failed! Please try again."),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Banner PageView with indicators
            SizedBox(
              height: 250,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentBannerIndex = index;
                      });
                    },
                    children: bannerImages.map((path) {
                      return Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: Image.asset(
                          path,
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                        ),
                      );
                    }).toList(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: _buildBannerIndicators(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 35),


            // Company logos CarouselSlider
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 50,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 2),
                  viewportFraction: 0.3,
                  enlargeCenterPage: false,
                  scrollDirection: Axis.horizontal,
                ),
                items: companyLogos.map((logo) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(logo, height: 50, fit: BoxFit.cover),
                    ),
                  );
                }).toList(),
              ),
            ),
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





            if (videoAdvertisements.isNotEmpty) ...[
              SizedBox(height: 10),
              CarouselSlider(
                options: CarouselOptions(
                  height: 200,
                  autoPlay: false,  // Disable autoplay to give users control
                  enlargeCenterPage: true,
                  aspectRatio: 16 / 9,
                  viewportFraction: 0.9,
                ),
                items: videoAdvertisements.map((ad) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: ChewieVideoWidget(videoUrl: ad['videoUrl']!),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 60),

            // Row of buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildButton('Register as Worker', ProfilePage()),
                  _buildButton('Register as Seller', ProfilePage()),
                  //  _buildButton('Products', VendorDashboard()),
                ],
              ),
            ),
            const SizedBox(height: 60),
            // Subscribe now text
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0),
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
            // Secondary CarouselSlider

            if (imageAdvertisements.isNotEmpty) ...[
              SizedBox(height: 10),
              CarouselSlider(
                options: CarouselOptions(
                  height: 300,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 3),
                  enlargeCenterPage: true,
                  aspectRatio: 16 / 9,
                  viewportFraction: 0.9,
                ),
                items: imageAdvertisements.map((ad) {
                  String? productId= ad['productId'];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductDetail(productId: productId!),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: Image.network(
                        ad['imageUrl']!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
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
                      color: const Color(0xFF033015),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF033015), Colors.grey],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              child: Text(
                'Explore Our Best Picks!',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Grid of cards
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 50,
                mainAxisSpacing: 50,
                childAspectRatio: 1.0,
                children: [
                  _buildCard(context, 'Coco Products', 'asset/all.webp',
                      ProductScreen()),
                  _buildCard(
                      context, 'Workers', 'asset/work.webp', WorkersList()),
                  _buildCard(context, 'On Doorstep', 'asset/delivery.webp',
                      Doorsteps()),
                  _buildCard(
                      context, 'Tools', 'asset/mach.webp', ListOfTools()),
                ],
              ),
            ),
            const SizedBox(height: 65),
            // Subscription history and Favourites area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.0),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(45),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF033015), Colors.grey],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                      offset: Offset(4, 4),
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.2),
                      blurRadius: 5,
                      offset: Offset(-4, -4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Subscription()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF033015),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(35),
                        ),
                        elevation: 5,
                      ),
                      icon: const Icon(Icons.star, color: Color(0xFF033015)),
                      label: const Text(
                        "Subscriptions",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FavoriteListPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF033015),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(35),
                        ),
                        elevation: 5,
                      ),
                      icon:
                          const Icon(Icons.favorite, color: Color(0xFF033015)),
                      label: const Text(
                        "WishList",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17),
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
          border: Border.all(color: const Color(0xFF033015), width: 2),
          borderRadius: BorderRadius.circular(40),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
      BuildContext context, String title, String imagePath, Widget page) {
    return GestureDetector(
      onTap: () => _navigateToPage(context, page),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF033015).withOpacity(0.5), // Green shadow
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0, 5), // Shadow at the bottom
            ),
          ],
        ),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0, // Remove default shadow since we are using a custom one
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(15)),
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
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
