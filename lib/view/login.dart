import 'package:dup/controller/regi_controller.dart';
import 'package:dup/view/Home.dart';
import 'package:dup/view/bottomnav.dart';
import 'package:flutter/material.dart';
import 'package:dup/view/Forgotpass.dart';
import 'package:dup/view/registration.dart';

class UserForm extends StatefulWidget {
  const UserForm({super.key});

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool  _passwordVisible = false;
  final AuthController _authController=AuthController();

  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      String email=_emailController.text.trim();
      String password=_passwordController.text.trim();
      String? result= await _authController.loginUser(email, password);

      if(result==null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("LogIn successfull"))
        );
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => BottomBarScreen(),));
      }
      else{
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)),);
    }
  }}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          // gradient: LinearGradient(
          //   colors: [ Color(0xFF033015),Colors.white], // Top to bottom gradient
          //   begin: Alignment.topCenter,
          //   end: Alignment.bottomCenter,
          // ),
          color: Color(0xFF033015),
        ),
        child: Column(
          children: [
            // Top section with logo or app name
            Container(
              padding: const EdgeInsets.symmetric(vertical: 60),
              child: Center(
                child:
                Text(
                  '𝐂𝐨.𝐍𝐮𝐭', // You can replace this with your app logo or name
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
            // Middle section with white background and rounded corners
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white, // White background for the form
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          // Email Field
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(color: Colors.white70),
                              prefixIcon: const Icon(Icons.email, color: Colors.white70),
                              filled: true,
                              fillColor: Colors.black54,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                              if (!emailRegex.hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: TextStyle(color: Colors.white70,fontSize: 16),
                              prefixIcon: const Icon(Icons.lock, color: Colors.white70,),
                              suffix: IconButton(onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              }, icon:Icon(_passwordVisible? Icons.visibility : Icons.visibility_off)),
                              filled: true,
                              fillColor: Colors.black54,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40.0),
                                borderSide: BorderSide.none,
                              ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12)
                            ),
                            obscureText: !_passwordVisible,
                            keyboardType: TextInputType.visiblePassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a password';
                              }
                              // final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{6,}$');
                              // if (!passwordRegex.hasMatch(value)) {
                              //   return 'Password must have at least 6 characters, including an uppercase letter, lowercase letter, a number, and a special character';
                              // }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          // Submit Button
                          ElevatedButton(
                            onPressed: _submitForm,
                            child: const Text('Login'),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Color(0xFF033015)),
                              foregroundColor: MaterialStateProperty.all(Colors.white),
                              padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 15, horizontal: 40)),
                              shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                            ),
                          ),
                          const SizedBox(height: 15),
                          // Forgot Password Link
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
                              );
                            },
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          const SizedBox(height: 30),
                          // Sign Up Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Not a member yet? ',
                                style: TextStyle(color: Colors.black),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => Regi()),
                                  );
                                },
                                child: const Text(
                                  "Sign Up Now",
                                  style: TextStyle(color: Color(0xFF033015),fontSize: 17),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
