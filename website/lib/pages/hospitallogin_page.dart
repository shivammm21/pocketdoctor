import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'hospitaldash_page.dart';

class HospitalLoginPage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController loginUsernameController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();
  final TextEditingController bedsController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF4A8EFF), // Background color matching the image
      body: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              // Left: Registration Section
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Hospital Register',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildTextField('Hospital Name', controller: nameController),
                    SizedBox(height: 15),
                    _buildTextField('Complete Address', controller: addressController),
                    SizedBox(height: 15),
                    _buildTextField('City', controller: cityController),
                    SizedBox(height: 15),
                    _buildAttachmentField('Attach License'),
                    SizedBox(height: 25),
                    _buildTextField('Total no. of beds', controller: bedsController),
                    SizedBox(height: 25),
                    _buildTextField('Username', controller: usernameController),
                    SizedBox(height: 15),
                    _buildTextField('Password', controller: passwordController, obscureText: true),
                    SizedBox(height: 15),
                    _buildButton('VERIFY', onPressed: () => _handleVerify(context)),
                  ],
                ),
              ),
              // Divider
              VerticalDivider(
                color: Colors.grey.shade300,
                thickness: 1,
                width: 40,
              ),
              // Right: Login Section
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Hospital Login',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildTextField('Username', controller: loginUsernameController),
                    SizedBox(height: 15),
                    _buildTextField('Password', controller: loginPasswordController, obscureText: true),
                    SizedBox(height: 25),
                    _buildButton('SIGN IN', onPressed: () => _handleSignIn(context)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, {bool obscureText = false, TextEditingController? controller}) {
    return SizedBox(
      width: 250, // Adjust the width of the text box here
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(
              color: Colors.grey.shade300,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(
              color: Colors.grey.shade300,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(
              color: Colors.blue,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentField(String label) {
    return SizedBox(
      width: 250,
      child: OutlinedButton.icon(
        onPressed: () {
          // Add functionality for attachment handling here
        },
        icon: Icon(Icons.attach_file, color: Colors.blue),
        label: Text(
          label,
          style: TextStyle(
            color: Colors.blue,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, {required VoidCallback onPressed}) {
  return SizedBox(
    width: 150,
    child: ElevatedButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white, // Set text color to white
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF4A8EFF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.symmetric(vertical: 15),
      ),
    ),
  );
}


  Future<void> _handleVerify(BuildContext context) async {
    final String name = nameController.text;
    final String username = usernameController.text;
    final String password = passwordController.text;
    final String address = addressController.text;
    final String beds = bedsController.text;
    final String city = cityController.text;

    if (name.isEmpty || username.isEmpty || password.isEmpty || address.isEmpty || beds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill out all fields')),
      );
      return;
    }

    final Map<String, dynamic> jsonData = {
      "name": name,
      "username": username,
      "password": password,
      "address": address,
      "city":city,
      "beds": beds,
      "verify": false
    };

    try {
      final response = await http.post(
        Uri.parse('http://192.168.59.56:8585/api/hospitals/add'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(jsonData),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration successful')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _handleSignIn(BuildContext context) async {
    final String username = loginUsernameController.text;
    final String password = loginPasswordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter both username and password')),
      );
      return;
    }

    final Map<String, dynamic> loginData = {
      "username": username,
      "password": password
    };

    try {
      final response = await http.post(
        Uri.parse('http://192.168.59.56:8585/api/hospitals/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(loginData),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login successful')),
        );

        // Navigate to HospitalDashPage with username
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HospitalDashPage(username: username),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

}
