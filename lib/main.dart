import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'screens/field_capture_screen.dart';
import 'theme/bcmm_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BCMM Terrain',
      theme: Bcmm.theme(),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Navigation terrain BCMM : 3 actions principales + carte.
/// (Pattern FieldForce / inspection : peu d'onglets, labels clairs.)
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  static const _pages = <Widget>[
    HomeScreen(),
    FieldCaptureScreen(),
    MapScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Bcmm.border)),
          color: Bcmm.card,
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: _index,
            onTap: (i) => setState(() => _index = i),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Iconsax.home_2),
                label: 'Accueil',
              ),
              BottomNavigationBarItem(
                icon: Icon(Iconsax.gps),
                label: 'Terrain',
              ),
              BottomNavigationBarItem(
                icon: Icon(Iconsax.map_1),
                label: 'Carte',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
