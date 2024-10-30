import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'screens/permit_details_screen.dart';
import 'screens/substance_form_screen.dart';
import 'screens/permit_tracking_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mining App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Iconsax.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Iconsax.map_1), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Iconsax.document_text), label: 'Permits'),
          BottomNavigationBarItem(icon: Icon(Iconsax.archive_1), label: 'Substances'),
          BottomNavigationBarItem(icon: Icon(Iconsax.graph), label: 'Tracking'),
        ],
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Widget _getScreen() {
    switch (_currentIndex) {
      case 0:
        return HomeScreen();
      case 1:
        return MapScreen();
      case 2:
      // Passer des données fictives pour les détails du permis
        return PermitDetailsScreen(permitData: {
          'gid': '12345',
          'registre_1': 'John Doe',
          'type_tit_1': 'Mining Permit',
          'shape_area': '1000 ha',
        });
      case 3:
        return SubstanceFormScreen();
      case 4:
        return PermitTrackingScreen();
      default:
        return HomeScreen();
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
