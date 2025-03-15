import 'package:dup/view/History.dart';
import 'package:dup/view/Home.dart';
import 'package:dup/view/cart.dart';
import 'package:dup/view/chat.dart';
import 'package:dup/view/profile.dart';
import 'package:flutter/material.dart';

class BottomBarScreen extends StatefulWidget {
  final int initialIndex;
  const BottomBarScreen({super.key, this.initialIndex = 0});

  @override
  State<BottomBarScreen> createState() => _BottomBarScreenState();
}

class _BottomBarScreenState extends State<BottomBarScreen> {
  late int _selectedIndex;

  final List<Widget> _pages = [
    Home(),
    Cart(),
    ChatListScreen(),
    History(),
    ProfilePage(),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _selectedIndex= widget.initialIndex;
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Show the selected page

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,

        selectedItemColor: Colors.white70,

        unselectedItemColor: Colors.white,

        backgroundColor: Color(0xFF033015),
        // backgroundColor: Colors.white,

        type: BottomNavigationBarType.fixed,

        onTap: _onItemTapped,

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'history'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
