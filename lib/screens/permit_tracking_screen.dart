import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'permit_details_screen.dart';

class PermitTrackingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Permit Tracking'),
        backgroundColor: Color(0xFF1976D2),
        actions: [
          IconButton(
            icon: Icon(Iconsax.notification5),
            onPressed: () {
              // Logic for notifications
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Track Your Permits',
              style: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976D2),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),

            // Search Field for Permit Tracking
            TextField(
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                labelText: 'Enter Permit ID or Holder Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFF1976D2)),
                ),
                suffixIcon: Icon(Iconsax.search_normal, color: Color(0xFF1976D2)),
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
                    context,  // Passer le context ici
                    '5226',
                    'Exploration',
                    'In Progress', // Statut statique
                    Iconsax.activity,
                    Colors.blueAccent,
                  ),
                  _buildTrackingCard(
                    context,  // Passer le context ici
                    '39412',
                    'Mining',
                    'Pending Approval', // Statut statique
                    Iconsax.timer,
                    Colors.orangeAccent,
                  ),
                  _buildTrackingCard(
                    context,  // Passer le context ici
                    '39850',
                    'Exploration',
                    'Approved', // Statut statique
                    Iconsax.shield_tick,
                    Colors.green,
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
  Widget _buildTrackingCard(BuildContext context, String permitId, String type, String status, IconData icon, Color iconColor) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      shadowColor: Colors.black26,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.2),
          child: Icon(icon, color: iconColor),
        ),
        title: Center(
          child: Text(
            'Permit ID: $permitId',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        subtitle: Center(
          child: Text(
            '$type - Status: $status',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
        trailing: Icon(Iconsax.arrow_right_3, color: Colors.grey[600]),
        onTap: () {
          // Navigation vers l'écran de détails avec les données du permis
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PermitDetailsScreen(
                permitData: {
                  'id': permitId,
                  'gid': '28', // Ajoutez le gid correspondant
                  'registre_1': 'PR GLOBAL RESOURCES', // Ajoutez le registre
                  'type_tit_1': type,
                  'shape_area': '137499991.68', // Ajoutez la surface
                  'status': status, // Statut statique
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
