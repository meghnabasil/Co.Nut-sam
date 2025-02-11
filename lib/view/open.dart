import 'package:dup/view/bottomnav.dart';
import 'package:dup/view/firstpage.dart';
import 'package:dup/view/home.dart';
import 'package:dup/view/login.dart';
import 'package:dup/view/registration.dart';
import 'package:flutter/material.dart';

class Open extends StatefulWidget {
  const Open({super.key});

  @override
  State<Open> createState() => _OpenState();
}

class _OpenState extends State<Open> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('asset/leafcocos.jpg'), // Path to your background image
            fit: BoxFit.cover,
            opacity: 0.7, // Adjust the opacity for the background image
          ),
          // gradient: LinearGradient(
          //   colors: [Colors.white, Colors.green],
          //   begin: Alignment.topRight,
          //   end: Alignment.bottomRight,
          // ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
        //     const Text(
        //
        // " Pure Coconut Bliss.",
        //
        //       style: TextStyle(fontSize:35, fontWeight: FontWeight.bold,color: Colors.black),
        //     ),
            const SizedBox(height: 20), // Adds spacing between text and button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserForm(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Button background color
                foregroundColor: Colors.white, // Text color
                padding: const EdgeInsets.symmetric(horizontal: 75, vertical: 10),
              ),
              child: const Text("LogIn"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Regi(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Button background color
                foregroundColor: Colors.white, // Text color
                padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 10),
              ),
              child: const Text("Sign Up"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BottomBarScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // Button background color
                foregroundColor: Colors.black, // Text color
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              ),
              child: const Text("Home"),
            ),
          ],
        ),
      ),
    );
  }
}
