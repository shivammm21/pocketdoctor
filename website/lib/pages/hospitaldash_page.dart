import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'adddocter_page.dart';
//import 'package:pocdoc_web/pages/adddocter_page.dart';

class HospitalDashPage extends StatefulWidget {
  final String username;
  const HospitalDashPage({Key? key, required this.username}) : super(key: key);

  @override
  _HospitalDashPageState createState() => _HospitalDashPageState();
}

class _HospitalDashPageState extends State<HospitalDashPage> {
  // Define a GlobalKey for the Scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String Name = "";
  String ID = "";
  int totalDoctors = 0;
  int totalPatients = 0;

  // Fetch data from the backend API
  Future<void> _fetchDashboardData() async {
    final url = Uri.parse('http://192.168.31.230:8585/api/hospitals/dashboard/${widget.username}');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        setState(() {
          ID = data['ID'].toString(); // Convert int to String
          Name = data['Name'];
          totalDoctors = data['totalDoctors'];
          totalPatients = data['totalPatients'];
        });
      } else {
        throw Exception('Failed to load dashboard data');
      }
    } catch (e) {
      print('Error fetching data: $e');
      _showErrorSnackBar('Error fetching data. Please try again later.');
    }
  }


// Show error message in Snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchDashboardData(); // Call the function to fetch the data when the page loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Assign the key to the Scaffold
      drawer: Drawer(
        child: Container(
          color: Colors.white, // Set the background color of the drawer
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Text('Hospital Menu', style: TextStyle(fontSize: 24)),
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  // Implement logout functionality here
                  Navigator.pop(context); // Close the drawer when tapped
                  _logout();
                },
              ),
            ],
          ),
        ),
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFA8E0C0), Color(0xFFB5C6FB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.menu,
                color: Colors.black,
                size: 40, // Set the desired size here
              ),
              onPressed: () {
                // Use the scaffold key to open the drawer
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFA8E0C0), Color(0xFFB5C6FB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 80,
                  bottom: 20,
                  child: Image.asset(
                    'lib/images/hospitaldash_img.png', // Replace with your image path
                    height: 400,
                    width: 200,
                  ),
                ),
                Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        '$Name', // Display hospital name
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Top Row with Cards
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildInfoCard('TOTAL DOCTOR', '$totalDoctors'),
                          const SizedBox(width: 100),
                          _buildInfoCard('TOTAL PATIENT', '$totalPatients'),
                        ],
                      ),
                      const SizedBox(height: 50),
                      _buildInfoCard('TOTAL BEDS', '50'),
                      const Spacer(),
                      // Add Doctor Button
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: ElevatedButton(
                            onPressed: () {
                              // Add functionality for adding a doctor here
                              _addDoctor(ID,widget.username);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4A8EFF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 24),
                            ),
                            child: const Text(
                              'Add Doctor',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      width: 280,
      height: 160,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        clipBehavior: Clip.none, // This allows widgets to overflow the container
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 75), // Left margin for the title text
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center, // Align text to the left
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
          Positioned(
            top: 126, // Position the avatar half inside, half outside
            left: 100, // Adjust horizontal position to center the avatar
            child: Material(
              elevation: 8, // Set the elevation for the shadow effect
              shape: CircleBorder(), // Makes sure the shadow is circular
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 25,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to log out the user
  void _logout() {
    // You can use Navigator to navigate to the login page or any other route
    Navigator.pushReplacementNamed(context, '/login');
  }

  // Function to add a doctor (you can implement the functionality)
  void _addDoctor(String Id,String username) {
     Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddDoctorPage(Id: Id,Username:username)),
    );
  }
}
