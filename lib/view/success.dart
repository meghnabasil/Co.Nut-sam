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
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 4),
          () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) =>UserForm(),));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // body: Container(
      //   width: double.infinity,
      //   height: double.infinity,
      //   decoration: BoxDecoration(
      //     gradient: LinearGradient(colors: [Colors.white,Colors.green],
      //       begin: Alignment.topRight,
      //       end: Alignment.bottomRight,
      //     ),
      //
      //   ),

      body: Center(
        child:
        //Image.asset("asset/meg.jpeg"),
        Lottie.asset('asset/co..json'),
      ),
    );
  }
}
