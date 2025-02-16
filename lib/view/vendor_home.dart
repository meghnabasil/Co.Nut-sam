import 'package:carousel_slider/carousel_slider.dart';
import 'package:dup/view/Home.dart';
import 'package:dup/view/bottomnav.dart';
import 'package:flutter/material.dart';

class VendorDashboard extends StatefulWidget {
  const VendorDashboard({super.key});

  @override
  _VendorDashboardState createState() => _VendorDashboardState();
}

class _VendorDashboardState extends State<VendorDashboard> {
  bool isVendorMode = true; // Toggle state

  void _switchToUserMode() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => BottomBarScreen()), // Replace with actual user dashboard screen
    );
  }


  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
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
        title: const Text("Vendor Dashboard", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Vendor Profile Card
            _buildProfileCard(context),
            const SizedBox(height: 20),

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

            const SizedBox(height: 20),

            // Rounded Bar with "Switch as Customer" Button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30), // Rounded corners
                gradient: const LinearGradient(
                  colors: [Color(0xFF033015), Colors.grey], // Dark Green & Grey Gradient
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5), // Bottom right shadow for 3D effect
                    blurRadius: 8,
                    offset: const Offset(4, 4),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.2), // Top left highlight for depth
                    blurRadius: 5,
                    offset: const Offset(-4, -4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // const Text(
                  //   "Vendor Mode",
                  //   style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  // ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _switchToUserMode,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), // Rounded Button
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF033015),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      elevation: 3,
                    ),
                    child: const Text(
                      "Switch as Customer",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),


            const SizedBox(height: 20),

            // Cards Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _buildCard(context, "Add Subscription", Icons.lock_clock, AddSubscriptionPage()),
                _buildCard(context, "Manage Subscription", Icons.list_alt, ManageSubscriptionPage()),
                _buildCard(context, "Doorstep Delivery", Icons.delivery_dining, AddDoorstepDeliveryPage()),
                _buildCard(context, "Manage Bookings", Icons.calendar_today, ManageBookingsPage()),
                _buildCard(context, "Add Coconut Products", Icons.eco, AddCoconutProductsPage()),
                _buildCard(context, "Add Tools", Icons.build, AddToolsPage()),
                _buildCard(context, "Manage Orders", Icons.shopping_basket, ManageOrdersPage()),
                _buildCard(context, "Add Advertisement", Icons.ondemand_video, AddAdvertisementPage()),
              ],
            ),
          ],
        ),   ),
    );
  }

  // Vendor Profile Card
  Widget _buildProfileCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _navigateToPage(context, VendorProfilePage());
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
                  children: const [
                    Text(
                      "Vendor Name",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      "vendor@example.com",
                      style: TextStyle(fontSize: 14, color: Colors.white70),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
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
    );
  }
}

// Dummy pages for navigation (Replace with actual pages)
class AddSubscriptionPage extends StatelessWidget { @override Widget build(BuildContext context) { return Scaffold(body: Center(child: Text("Add Subscription"))); }}
class AddDoorstepDeliveryPage extends StatelessWidget { @override Widget build(BuildContext context) { return Scaffold(body: Center(child: Text("Add Doorstep Delivery"))); }}
class ManageOrdersPage extends StatelessWidget { @override Widget build(BuildContext context) { return Scaffold(body: Center(child: Text("Manage Orders"))); }}
class ManageBookingsPage extends StatelessWidget { @override Widget build(BuildContext context) { return Scaffold(body: Center(child: Text("Manage Bookings"))); }}
class ManageSubscriptionPage extends StatelessWidget { @override Widget build(BuildContext context) { return Scaffold(body: Center(child: Text("Manage Subscription"))); }}
class AddCoconutProductsPage extends StatelessWidget { @override Widget build(BuildContext context) { return Scaffold(body: Center(child: Text("Add Coconut Products"))); }}
class AddToolsPage extends StatelessWidget { @override Widget build(BuildContext context) { return Scaffold(body: Center(child: Text("Add Tools"))); }}
class AddAdvertisementPage extends StatelessWidget { @override Widget build(BuildContext context) { return Scaffold(body: Center(child: Text("Add Advertisement"))); }}
class VendorProfilePage extends StatelessWidget { @override Widget build(BuildContext context) { return Scaffold(body: Center(child: Text("Vendor Profile"))); }}

