import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PermitDetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Permit Details', style: TextStyle(color: CupertinoColors.white)),
        backgroundColor: CupertinoColors.systemBlue,
        brightness: Brightness.light,
      ),
      child: SafeArea(
        child: Container(
          color: CupertinoColors.systemGrey6,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Permit Information',
                  style: TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.black,
                  ),
                ),
                SizedBox(height: 20),

                // Permit Details Section
                Expanded(
                  child: ListView(
                    children: [
                      _buildPermitDetailCard('Permit ID', '12345', Icons.perm_identity),
                      _buildPermitDetailCard('Permit Holder', 'John Doe Mining Co.', Icons.business),
                      _buildPermitDetailCard('Permit Type', 'Exploration', Icons.category),
                      _buildPermitDetailCard('Issued Date', '01/09/2023', Icons.calendar_today),
                      _buildPermitDetailCard('Expiration Date', '01/09/2028', Icons.calendar_today),
                      _buildPermitDetailCard('Status', 'Active', Icons.check_circle_outline),
                    ],
                  ),
                ),

                // Modify Button
                Center(
                  child: CupertinoButton(
                    color: CupertinoColors.activeBlue,
                    borderRadius: BorderRadius.circular(8),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Text(
                      'Modify Permit Details',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      // Logic to modify or view full permit details
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper Widget to create iOS-style Permit Detail Cards
  Widget _buildPermitDetailCard(String title, String value, IconData icon) {
    return GestureDetector(
      onTap: () {
        // Optional: Logic for card tap
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withOpacity(0.2),
              blurRadius: 4.0,
              spreadRadius: 1.0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Icon(icon, color: CupertinoColors.activeBlue, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
