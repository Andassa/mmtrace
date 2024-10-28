import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'map_screen.dart'; // Importez vos écrans ici
import 'permit_details_screen.dart';
import 'substance_form_screen.dart';
import 'permit_tracking_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Mining App Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Color(0xFF1976D2),
        elevation: 4,
        actions: [
          IconButton(
            icon: Icon(Iconsax.setting_2),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Real-Time Substance Prices Section
              Container(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1976D2), Color(0xFF64B5F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: Offset(2, 4),
                    ),
                  ],
                ),
                width: MediaQuery.of(context).size.width * 0.9,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Real-Time Substance Prices',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    SizedBox(height: 15),
                    FutureBuilder<Map<String, dynamic>>(
                      future: fetchMetalPrices(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Erreur: ${snapshot.error}'));
                        } else if (snapshot.hasData && snapshot.data != null) {
                          final prices = snapshot.data!['rates'];
                          if (prices.isEmpty) {
                            return Center(child: Text('Aucune donnée de prix disponible.'));
                          }

                          List<Widget> priceCards = [
                            _buildPriceTile('Gold', '\$${prices['XAU']}/oz', Iconsax.dollar_circle),
                            _buildPriceTile('Silver', '\$${prices['XAG']}/oz', Iconsax.diamonds),
                            _buildPriceTile('Platinum', '\$${prices['XPT']}/oz', Iconsax.chart),
                            _buildPriceTile('Palladium', '\$${prices['XPD']}/oz', Iconsax.chart),
                          ];

                          return Container(
                            height: 150,
                            child: PageView(
                              children: priceCards,
                            ),
                          );
                        } else {
                          return Center(child: Text('Données de prix manquantes'));
                        }
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Welcome, explore your mining data!',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              // Utiliser un Container pour le GridView
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildHomeButton(
                      icon: Iconsax.map,
                      label: 'Map',
                      color: Color(0xFF42A5F5),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MapScreen()),
                        );
                      },
                    ),
                    _buildHomeButton(
                      icon: Iconsax.note_text,
                      label: 'Permit Details',
                      color: Color(0xFF1E88E5),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PermitDetailsScreen()),
                        );
                      },
                    ),
                    _buildHomeButton(
                      icon: Iconsax.flash_1,
                      label: 'Substance Form',
                      color: Color(0xFF1A237E),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SubstanceFormScreen()),
                        );
                      },
                    ),
                    _buildHomeButton(
                      icon: Iconsax.chart,
                      label: 'Permit Tracking',
                      color: Color(0xFF0D47A1),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PermitTrackingScreen()),
                        );
                      },
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

  Future<Map<String, dynamic>> fetchMetalPrices() async {
    final apiKey = 'sk_5E3e1acF0C247396E429bD6fe99f9c74FDde046eCd92dcFF';
    final url = 'https://metals.g.apised.com/v1/latest?symbols=XAU,XAG,XPD,XPT&base_currency=USD';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'x-api-key': apiKey,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'] != null ? data['data'] : {};
    } else {
      throw Exception('Erreur lors de la récupération des prix des métaux');
    }
  }

  Widget _buildPriceTile(String substance, String price, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 6,
      shadowColor: Colors.black12,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Color(0xFF1976D2), size: 24),
            SizedBox(height: 8),
            Text(
              substance,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              price,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 6,
        shadowColor: Colors.black12,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: Colors.white),
                SizedBox(height: 12),
                Text(
                  label,
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
