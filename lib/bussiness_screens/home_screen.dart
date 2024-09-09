import 'package:firebase/bussiness_screens/eduction_screen.dart';
import 'package:firebase/bussiness_screens/food_screen.dart';
import 'package:firebase/bussiness_screens/health_screen.dart';
import 'package:firebase/bussiness_screens/hotel_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // List of categories with titles and icons

  void _navigateToEducationScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EducationScreen()),
    );
  }
  void _navigateToFoodScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FoodScreen()),
    );
  }

  void _navigateToHotelScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HotelScreen()),
    );
  }

  void _navigateToHealthScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HealthScreen()),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan[100],
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: const Text('Home Screen'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap:_navigateToHealthScreen,
              child: Card(

                margin: EdgeInsets.all(16.0),
                child: Center(
                  child: ListTile(

                    leading: Icon(Icons.person, color: Colors.blue, size: 48),
                    title: Text("HeathCare", style: TextStyle(fontSize: 24)),
                    subtitle: Text("View Heathcare"),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: _navigateToHotelScreen,
              child: Card(
                margin: EdgeInsets.all(16.0),
                child: Center(
                  child: ListTile(
                    leading: Icon(Icons.business, color: Colors.blue, size: 48),
                    title: Text("Hotel", style: TextStyle(fontSize: 24)),
                    subtitle: Text("View Hotel info"),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: _navigateToFoodScreen,
              child: Card(
                margin: EdgeInsets.all(16.0),
                child: Center(
                  child: ListTile(
                    leading: Icon(Icons.edit, color: Colors.blue, size: 48),
                    title: Text("Food", style: TextStyle(fontSize: 24)),
                    subtitle: Text("view food section"),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: _navigateToEducationScreen,
              child: Card(
                margin: EdgeInsets.all(16.0),
                child: Center(
                  child: ListTile(
                    leading: Icon(Icons.edit, color: Colors.blue, size: 48),
                    title: Text("Education", style: TextStyle(fontSize: 24)),
                    subtitle: Text("view Education section"),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Category Screen
