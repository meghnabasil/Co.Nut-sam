import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dup/view/AddAdvertisementPage.dart';
import 'package:dup/view/Home.dart';
import 'package:dup/view/Vendor_manage_booking.dart';
import 'package:dup/view/bottomnav.dart';
import 'package:dup/view/subscription.dart';
import 'package:dup/view/vendor_AddCoconutProductsPage.dart';
import 'package:dup/view/vendor_addtools.dart';
import 'package:dup/view/vendor_doorstep.dart';
import 'package:dup/view/vendor_manage_order.dart';
import 'package:dup/view/vendor_mange_subscription.dart';
import 'package:dup/view/vendor_profile.dart';
import 'package:dup/view/vendor_viewproduct.dart';
import 'package:dup/view/viewCoco.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VendorDashboard extends StatefulWidget {
  const VendorDashboard({Key? key}) : super(key: key);

  @override
  State<VendorDashboard> createState() => _VendorDashboardState();
}

class _VendorDashboardState extends State<VendorDashboard> {
  String? vendorId;
  String vendorName = "Vendor Name";
  String vendorEmail = "vendor@example.com";

  @override
  void initState() {
    super.initState();
    fetchVendorDetails();
  }

  Future<void> fetchVendorDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        vendorId = user.uid;
      });

      try {
        DocumentSnapshot vendorDoc = await FirebaseFirestore.instance
            .collection('vendors')
            .doc(user.uid)
            .get();

        if (vendorDoc.exists) {
          print("Vendor Document Data: ${vendorDoc.data()}"); // Debugging line

          setState(() {
            vendorName = vendorDoc['businessName'] ?? "Vendor Name";
            vendorEmail = vendorDoc['email'] ?? "vendor@example.com";
          });
        } else {
          print("Vendor document does not exist for UID: ${user.uid}");
        }
      } catch (e) {
        print("Error fetching vendor details: $e");
      }
    }
  }



  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  final List<String> carouselImages = [
    'assets/banner1.jpg',
    'assets/banner2.jpg',
    'assets/banner3.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF033015),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Vendor Dashboard",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      // Added Drawer without changing existing code.
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Vendor Profile Card
            _buildProfileCard(context),
            const SizedBox(height: 30),

            // Carousel Slider
            CarouselSlider(
              options: CarouselOptions(
                height: 180,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 3),
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
            const SizedBox(height: 30),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 5,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF033015), Colors.grey],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
                child: ListTile(
                  leading: Icon(Icons.visibility, color: Colors.green[900]),
                  title: const Text(
                    "View Your Products",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Viewcocoandtools()),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 50),

            // Cards Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _buildCard(context, "Add Subscription", Icons.lock_clock, Subscription()),
                _buildCard(context, "Manage Subscription", Icons.list_alt,VendorMangeSubscription ()),
                _buildCard(context, "Doorstep Delivery", Icons.delivery_dining, AddDoorstepDelivery()),
                _buildCard(context, "Manage Bookings", Icons.calendar_today, ManageBookingPage()),
                _buildCard(context, "Add Coconut Products", Icons.eco, AddProductPage()),
                _buildCard(context, "Add Tools", Icons.build,AddToolPage()),
                _buildCard(context, "Manage Orders", Icons.shopping_basket, ManageOrdersPage()),
                _buildCard(context, "Add Advertisement", Icons.ondemand_video, AddAdvertisementPage()),
              ],
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // Vendor Profile Card
  Widget _buildProfileCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (vendorId != null) {
          _navigateToPage(
              context, VendorProfilePage(vendorId: vendorId!));
        } else {
          print("Error: Vendor ID is null");
        }
      },
      child: Card(
        shadowColor: Colors.green,
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: const Color(0xFF033015),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage("assets/profile.jpg"),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vendorName,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      vendorEmail,
                      style: const TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.edit, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  // Function to build a feature card
  Widget _buildCard(BuildContext context, String title, IconData icon, Widget page) {
    return GestureDetector(
      onTap: () => _navigateToPage(context, page),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(color: Color(0xFF033015), width: 2),
        ),
        elevation: 5,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: const Color(0xFF033015)),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Drawer Widget added without modifying the existing code
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF033015),
            ),
            accountName: Text(vendorName),
            accountEmail: Text(vendorEmail),
            currentAccountPicture: const CircleAvatar(
              backgroundImage: AssetImage("assets/profile.jpg"),
            ),
          ),
          // Drawer Items
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              _navigateToPage(context, const Home());
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              if (vendorId != null) {
                _navigateToPage(context, VendorProfilePage(vendorId: vendorId!));
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_basket),
            title: const Text('Manage Orders'),
            onTap: () {
              Navigator.pop(context);
              _navigateToPage(context, ManageOrdersPage());
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              // Add Settings navigation if needed.
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              // Add logout functionality here.
            },
          ),
        ],
      ),
    );
  }
}

