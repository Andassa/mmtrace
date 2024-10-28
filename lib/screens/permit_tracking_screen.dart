import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart'; // Icons for enhanced UI elements

class PermitTrackingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Permit Tracking'),
        backgroundColor: Colors.greenAccent[700],
        actions: [
          IconButton(
            icon: Icon(Iconsax.notification5), // Notification icon
            onPressed: () {
              // Notification logic here
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Track Your Permits',
              style: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
                color: Colors.greenAccent[700],
              ),
            ),
            SizedBox(height: 16),

            // Search Field for Permit Tracking
            TextField(
              textAlign: TextAlign.center, // Center the text
              decoration: InputDecoration(
                labelText: 'Enter Permit ID or Holder Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.greenAccent[700]!),
                ),
                suffixIcon: Icon(Iconsax.search_normal, color: Colors.greenAccent[700]),
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: (value) {
                // Search logic here
              },
            ),
            SizedBox(height: 20),

            // Progress Tracking Cards
            Expanded(
              child: ListView(
                children: [
                  _buildTrackingCard(
                      'Permit ID: 12345',
                      'Exploration',
                      'In Progress',
                      Iconsax.activity,
                      Colors.blueAccent
                  ),
                  _buildTrackingCard(
                      'Permit ID: 98765',
                      'Mining',
                      'Pending Approval',
                      Iconsax.timer,
                      Colors.orangeAccent
                  ),
                  _buildTrackingCard(
                      'Permit ID: 65432',
                      'Exploration',
                      'Approved',
                      Iconsax.shield_tick,
                      Colors.green
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget to build the tracking card for each permit
  Widget _buildTrackingCard(String permitId, String type, String status, IconData icon, Color iconColor) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 6,
      shadowColor: Colors.black26,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.2),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(permitId, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$type - Status: $status', style: TextStyle(color: Colors.grey[600])),
        trailing: Icon(Iconsax.arrow_right_3, color: Colors.grey[600]),
        onTap: () {
          // Navigate to full tracking details
        },
      ),
    );
  }
}
