import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HospitalDashPage extends StatefulWidget {
  final String hospitalId;
  final String hospitalName;
  final String address;

  const HospitalDashPage({
    Key? key,
    required this.hospitalId,
    required this.hospitalName,
    required this.address,
  }) : super(key: key);

  @override
  _HospitalDashPageState createState() => _HospitalDashPageState();
}

class _HospitalDashPageState extends State<HospitalDashPage> {
  List<dynamic> doctors = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    final url = Uri.parse('http://192.168.59.56:8585/api/dashboard/doctor/${widget.hospitalId}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          doctors = data['data'] ?? [];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load dashboard data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching data: $e';
      });
    }

    print('$doctors');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.hospitalName,
          style: const TextStyle(fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : doctors.isEmpty
          ? const Center(child: Text('No doctors available for this hospital'))
          : ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: doctors.length,
        itemBuilder: (context, index) {
          final doctor = doctors[index];
          return createDoctorCard(
            context,
            doctorImageUrl: doctor['imageUrl'] ?? 'lib/images/profile.png',
            doctorName: doctor['name'] ?? 'Unknown',
            doctorQualification: doctor['qualification'] ?? 'Unknown',
            doctorSpeciality: doctor['specialist'] ?? 'Unknown',
          );
        },
      ),
    );
  }

  Widget createDoctorCard(
      BuildContext context, {
        required String doctorImageUrl,
        required String doctorName,
        required String doctorQualification,
        required String doctorSpeciality,
      }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage(doctorImageUrl),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctorName,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    doctorQualification,
                    style: const TextStyle(fontSize: 14.0, color: Colors.grey),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    doctorSpeciality,
                    style: const TextStyle(fontSize: 14.0, color: Colors.grey),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                // Handle appointment logic here
              },
              icon: const Icon(Icons.calendar_today, size: 16),
              label: const Text('Get Appointment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                elevation: 4.0,
                shadowColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
