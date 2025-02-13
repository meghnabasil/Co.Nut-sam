import 'package:dup/controller/session.dart';
import 'package:dup/view/bottomnav.dart';
import 'package:dup/view/login.dart';
import 'package:dup/view/open.dart';
import 'package:flutter/material.dart';
import 'package:dup/view/home.dart';
import 'package:lottie/lottie.dart';


class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();

    _checkSession();
  }


  // Check session and navigate accordingly
  Future<void> _checkSession() async {
    final sessionData = await Session.getSession();
    final bool isLoggedIn = sessionData['uid'] != null;

    // Delay for splash animation
    await Future.delayed(const Duration(seconds: 3));

    // Navigate to Home if logged in, else Login
    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BottomBarScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UserForm()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Color(0xFF033015),

      body: Container(
        // width: double.infinity,
        // height: double.infinity,
        // decoration: BoxDecoration(
        //   gradient: LinearGradient(colors: [Colors.white, Color(0xFF033015)],
        //     begin: Alignment.topRight,
        //     end: Alignment.bottomRight,
        //   ),
        //
        // ),

        child:
          Center(
          child:
          //Image.asset("asset/meg.jpeg"),
          Lottie.asset('asset/co..json'),
        ),
      ),  );
    }
  }
