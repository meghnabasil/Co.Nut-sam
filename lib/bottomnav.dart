import 'package:dup/cart.dart';
import 'package:dup/chat.dart';
import 'package:dup/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'Home.dart';



class BottomBarScreen extends StatefulWidget {

  const BottomBarScreen({super.key});



  @override

  State<BottomBarScreen> createState() => _BottomBarScreenState();

}



class _BottomBarScreenState extends State<BottomBarScreen> {

  int _selectedIndex = 0;



  final List<Widget> _pages = const [
    Home(),
    Cart(),
    Chat(),
    Profile(),

  ];



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

        unselectedItemColor:Colors.white,

        backgroundColor: Color(0xFF033015),
        // backgroundColor: Colors.white,



        type: BottomNavigationBarType.fixed,

        onTap: _onItemTapped,

        items: const [

          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),

          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),

          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),

          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),

        ],

      ),

    );

  }

}