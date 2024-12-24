import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'hospitaldash_page.dart';
import 'signin_page.dart';
import 'profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardPage extends StatefulWidget {
  final String mobilenopref;

  const DashboardPage({super.key, required this.mobilenopref});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String name = "";
  String userId = "";
  String mobileno = "";
  dynamic appointment;
  late List<dynamic> hospitals = [];
  int _selectedIndex = 0;
  late List<dynamic> usedData = [];
  String userCity = "";
  String profileName = "";
  Uint8List? _profileImage;

  TextEditingController _searchController = new TextEditingController();

  String mobilenopref = "";

  @override
  void initState() {
    super.initState();
    _initializeData(); // Combine both SharedPreferences loading and server call
  }

  Future<void> _initializeData() async {


    await _loadStoredData();
    mobilenopref = widget.mobilenopref;
    _fetchDashboardData(); // Call once after loading stored data

  }


  // Load the data from SharedPreferences
  Future<void> _loadStoredData() async {

    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? "";
      //city = prefs.getString('city') ?? "";
      //hospitalId = prefs.getString('id') ?? "";
      mobilenopref = prefs.getString('mobileno') ?? "";


    });
    print('$mobilenopref');
    print('$name');
    print('$userCity');
    print('$mobileno');

    _fetchDashboardData();

  }

  // Fetch the dashboard data from the server
  Future<void> _fetchDashboardData() async {
    //print(mobileno);

    //print(widget.mobileno);

    //final url = Uri.parse('http://localhost:8585/api/dashboard/${mobileno}');
    final url = Uri.parse('http://localhost:8585/api/dashboard/${mobilenopref}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        setState(() {
          final data = responseData['data'] ?? {};
          userId = data['id']?.toString() ?? "";
          name = data['Name'] ?? "Unknown";
          mobileno = data['mobileno'] ?? "";
          hospitals = data['Hospitals'] ?? [];
          usedData = data['Hospitals'] ?? [];
          userCity = data['city'];
          profileName = data['profileName'];
          appointment = data['appointmentData'];
        });

        // Save the fetched data to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('name', name);
        //await prefs.setString('id', hospitalId);
        await prefs.setString('mobileno', mobileno);
        await prefs.setString('hospitals', json.encode(hospitals));
      } else {
        throw Exception('Failed to load dashboard data');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
    print('$usedData');
    print('profile name $profileName');
    getProfileFile(profileName);
  }

  Future<void> getProfileFile(String fileName) async {
    final url = Uri.parse('http://localhost:8585/image/$fileName');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final imageBytes = response.bodyBytes;

        setState(() {
          if (kIsWeb) {
            _profileImage = imageBytes; // Use bytes for web.
          } else {
            _profileImage = File.fromRawPath(imageBytes) as Uint8List?; // Use File for mobile.
          }
        });

        print('Image fetched and displayed successfully.');
      } else {
        throw Exception('Failed to load image: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile image')),
      );
    }
  }


  Future<void> _fetchSearchData(String city) async {
    final url = Uri.parse('http://localhost:8585/api/dashboard/city/$city');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        setState(() {
          final data = responseData['data'] ?? {};
          hospitals = data['Hospitals'] ?? [];
        });
      } else {
        throw Exception('Failed to load search results');
      }
    } catch (e) {
      print('Error fetching search data: $e');
    }
  }


  // Logout function
  Future<void> _logout(BuildContext context) async {
  // Show confirmation dialog
  final confirmLogout = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirm Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // User cancels logout
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // User confirms logout
            },
            child: Text('Logout'),
          ),
        ],
      );
    },
  );

  // If the user confirms, proceed with logout
  if (confirmLogout == true) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false); // Clear login status
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInPage()),
    );
  }
}

  // Function for bottom navigation bar item click
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage(userId:userId)), // Navigate to ProfilePage
            );
          },
          child: CircleAvatar(
            backgroundImage: _profileImage != null
                ? MemoryImage(_profileImage as Uint8List) // Display fetched image
                : AssetImage('lib/images/profile.png') as ImageProvider, // Fallback to placeholder
          ),
        ),
      ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Good Day', style: TextStyle(color: Colors.black, fontSize: 16)),
            Text('$name', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black),
            onPressed: () => _logout(context), // Call the logout function
          ),
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboardContent(),
          Center(child: Text("Appointments Content")),
          Center(child: Text("Nearby Content")),
          Center(child: Text("History Content")),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.grey),
            label: '',
            activeIcon: _buildActiveTabIcon(Icons.home, 'Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.adb, color: Colors.grey),
            label: '',
            activeIcon: _buildActiveTabIcon(Icons.adb, 'Chatbot'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on, color: Colors.grey),
            label: '',
            activeIcon: _buildActiveTabIcon(Icons.location_on, 'Track'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history, color: Colors.grey),
            label: '',
            activeIcon: _buildActiveTabIcon(Icons.history, 'History'),
          ),
        ],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: false,
        showSelectedLabels: false,
      ),
    );
  }

  // Method to create the active tab icon in bottom navigation
  Widget _buildActiveTabIcon(IconData icon, String label) {
    return SizedBox(
      width: 128,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.only(top: 4, left: 8, right: 8, bottom: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(height: 1),
            Text(label, style: TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // Main content of the dashboard
  Widget _buildDashboardContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView(
        children: [
          Text(
            'How Are You\nFeeling Today?',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildOptionCard(Icons.check_circle_outline, 'Check Up'),
              _buildOptionCard(Icons.medical_services_outlined, 'Consult'),
            ],
          ),
          SizedBox(height: 16),
          _buildSearchBar(),
          SizedBox(height: 16),
          Text('Emergency Services', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildEmergencyButton('Help ?', Icons.help_outline),
              _buildEmergencyButton('Book\nAmbulance', Icons.local_hospital),
            ],
          ),
          SizedBox(height: 16),
          // Displaying hospitals list as cards
          _buildHospitalCards(),
        ],
      ),
    );
  }

  // Function to build a list of hospital cards
  Widget _buildHospitalCards() {
    if (hospitals.isEmpty) {
      return Center(child: Text('No hospitals available'));
    }

    //print(hospitalId);

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: hospitals.length,
      itemBuilder: (context, index) {
        final hospital = hospitals[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(

                builder: (context) => HospitalDashPage(hospitalId: hospital['id'].toString(),hospitalName: hospital['name'], address: hospital['address']),
              ),
            );
          },
          child: _buildHospitalCard(
            hospital['name'] ?? 'Hospital Name',
            hospital['address'] ?? 'Hospital Address',
            'lib/images/signin_img.png',
            hospital['rating']?.toString() ?? 'Not Rated', // Show rating
          ),
        );
      },
    );
  }

  // Function to build a hospital card
  Widget _buildHospitalCard(String name, String address, String imgPath, String rating) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(imgPath, width: 80, height: 80, fit: BoxFit.cover),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 0),
                Text(
                  address,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  maxLines: null, // Allows text to wrap into multiple lines
                  overflow: TextOverflow.visible,
                ),
                SizedBox(height: 0),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    Icon(Icons.star_half, color: Colors.amber, size: 16),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Function to build an option card (Consult/Checkup)
  Widget _buildOptionCard(IconData icon, String title) {
    return Container(
      width: 150,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: Colors.blue),
          SizedBox(height: 8),
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Function to build the search bar
  Widget _buildSearchBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by city',
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            Future.delayed(Duration(milliseconds: 300), () {
              _fetchSearchData(value);
            });
          } else {


              //hospitals = usedData;

              print('$usedData');
              print('$hospitals');
             // _buildHospitalCards();
              //_fetchDashboardData();
              Future.delayed(Duration(milliseconds: 300), () {
                _fetchSearchData(userCity);
              });
              print('$userCity');

          }
        },
      ),
    );
  }


  // Emergency button widget
  Widget _buildEmergencyButton(String title, IconData icon) {
    return Expanded(
      child: InkWell(
        onTap: () {},
        splashColor: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 100,
          margin: EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: Colors.blue),
              SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
