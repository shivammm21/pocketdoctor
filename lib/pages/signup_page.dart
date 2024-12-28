import 'dart:convert';

import 'package:flutter/material.dart';
import 'signin_page.dart';
import 'dashboard_page.dart';
import 'package:http/http.dart' as http;

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

Future<void> sendOtp(String name,String email,String mobileno,String city) async {

  final url = Uri.parse('http://localhost:8585/api/register');

  final body = json.encode(
      {
        "name":name,
        "email":email,
        "city":city,
        "mobileno": mobileno
      });

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print('OTP sent successfully: $responseData');
      // Handle response data as needed
    } else {
      print('Failed to send OTP: ${response.statusCode}');
      print('Error: ${response.body}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

Future<void> verifyOtp(BuildContext context,String mobileNo, String otp) async {

  final url = Uri.parse('http://localhost:8585/api/login/otp-verify');

  final body = json.encode({"mobileno": mobileNo, "otp": otp});

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print('OTP verification successful: $responseData');
      // Handle response data as needed
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DashboardPage(mobilenopref: mobileNo,)),
      );
    } else {
      print('Failed to verify OTP: ${response.statusCode}');
      print('Error: ${response.body}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
class _SignUpPageState extends State<SignUpPage> {
  // Initial position for animation
  double _bottomPosition = -500;
  bool _showOTPFields = false; // To control visibility of OTP fields
  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController mobileno = TextEditingController();
  final TextEditingController otp = TextEditingController();
  final TextEditingController city = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Trigger the animation after the widget is loaded
    Future.delayed(const Duration(milliseconds: 10), () {
      setState(() {
        _bottomPosition = 0; // Move the white block to its final position
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3254ED), // Set background color to blue
      body: Stack(
        children: [
          // Image placed above the white block, in the blue background
          Positioned(
            top: 50, // Adjust the position of the image above the white block
            left: MediaQuery.of(context).size.width * 0.25, // Center the image horizontally
            child: Image.asset(
              'lib/images/signup_img.png', // Replace with your image path
              width: 200, // Width of 200
              height: 200, // Height of 200
            ),
          ),
          // Animated white block
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            bottom: _bottomPosition, // Move from bottom to top
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.7, // Cover 70% of the screen
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: SingleChildScrollView( // Add scroll functionality
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    const Text(
                      'Sign up to continue',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Name field
                    TextField(
                      controller: name,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: const Color(0xFF3254ED), // Border color same as background
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Email field
                    TextField(
                      controller: email,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: const Color(0xFF3254ED), // Border color same as background
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Name field
                    TextField(
                      controller: city,
                      decoration: InputDecoration(
                        labelText: 'City',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: const Color(0xFF3254ED), // Border color same as background
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Mobile Number field
                    TextField(
                      controller: mobileno,
                      decoration: InputDecoration(
                        labelText: 'Mobile Number',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: const Color(0xFF3254ED), // Border color same as background
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // SEND OTP button
                    Visibility(
                      visible: !_showOTPFields, // Show only if OTP fields are hidden
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () {

                            sendOtp(name.text,email.text,mobileno.text,city.text);
                            setState(() {
                              _showOTPFields = true; // Show OTP fields when clicked
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 100), // Increased width
                            backgroundColor: const Color(0xFF3254ED), // Background color same as page
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: const Text(
                            'SEND OTP',
                            style: TextStyle(fontSize: 18, color: Colors.white), // White text color
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // OTP field and SIGN UP button (appears after SEND OTP button click)
                    Visibility(
                      visible: _showOTPFields, // Show only when OTP fields are triggered
                      child: Column(
                        children: [
                          // OTP field
                          TextField(
                            obscureText: true,
                            controller: otp,
                            decoration: InputDecoration(
                              labelText: 'OTP',
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: const Color(0xFF3254ED), // Border color same as background
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                            ),
                          ),
                          const SizedBox(height: 30),
                          // Sign Up button
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                // Handle Sign Up action
                                verifyOtp(context,mobileno.text,otp.text);

                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 100), // Increased width
                                backgroundColor: const Color(0xFF3254ED), // Background color same as page
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              child: const Text(
                                'SIGN UP',
                                style: TextStyle(fontSize: 18, color: Colors.white), // White text color
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // "Already have an account?" text
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account? ",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Navigate to SignInPage when Sign In is clicked
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SignInPage()),
                            );
                          },
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF3254ED),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Horizontal line with light grey color and shorter width
                    const Divider(
                      color: Color(0xFFB0BEC5),
                      thickness: 1,
                      indent: 100,
                      endIndent: 100,
                    ),
                    const SizedBox(height: 20),
                    // Continue with Google button
                    TextButton.icon(
                      onPressed: () {
                        // Handle Google Sign-In action
                      },
                      icon: Image.asset(
                        'lib/images/googleicon_img.png', // Replace with your Google icon path
                        width: 24,
                        height: 24,
                      ),
                      label: const Text(
                        'Continue with Google',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF3254ED),
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                          side: BorderSide(
                            color: const Color(0xFF3254ED),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
