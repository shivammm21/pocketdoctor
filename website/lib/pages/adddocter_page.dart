import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'hospitaldash_page.dart';

class AddDoctorPage extends StatefulWidget {
  final String Id;
  final String Username;

  const AddDoctorPage({Key? key, required this.Id, required this.Username}) : super(key: key);

  @override
  _AddDoctorPageState createState() => _AddDoctorPageState();
}

class _AddDoctorPageState extends State<AddDoctorPage> {
  TextEditingController doctorName = TextEditingController();
  TextEditingController doctorQulification = TextEditingController();
  TextEditingController doctorSpecialist = TextEditingController();
  TextEditingController doctorMobileno = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF4A8EFF),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.4,
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              // Left side: Doctor Register
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Doctor Register',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      _buildTextField('Doctor Name', controller: doctorName),
                      _buildTextField('Qualification', controller: doctorQulification),
                      _buildTextField('Specialist', controller: doctorSpecialist),
                      _buildTextField('Mobile Number', controller: doctorMobileno),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          _registerDoctor(
                            context,
                            widget.Id,
                            doctorName.text,
                            doctorQulification.text,
                            doctorSpecialist.text,
                            doctorMobileno.text,
                            widget.Username,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4A8EFF),
                          padding: EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'ADD',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hintText, {required TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        width: 250,
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: Colors.grey),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          ),
        ),
      ),
    );
  }

  Future<void> _registerDoctor(BuildContext context, String id, String name, String qualification,
      String specialist, String mobileNo, String username) async {

    List<String> user = name.split(" ");

    final url = Uri.parse('http://192.168.59.56:8585/api/doctor/add'); // Replace with your API URL
    final body = jsonEncode({
      'hospitalId': id,
      'name': name,
      "password":"x234hzwe",
      "username":user[0]+"_"+id,
      "verify":false,
      'qualification': qualification,
      'specialist': specialist,
      'mobileno': mobileNo,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Doctor registered successfully!')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HospitalDashPage(username: username),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to register doctor: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
