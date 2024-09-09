import 'package:firebase/bussiness_screens/home_screen.dart';
import 'package:firebase/profile_screens/update_screen.dart';
import 'package:firebase/ui/auth/login_screen.dart';
import 'package:firebase/utills/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase/profile_screens/profile_screen.dart'; // Import your profile screen

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final auth = FirebaseAuth.instance;

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Logout"),
          content: Text("Are you sure you want to logout?"),
          actions: <Widget>[
            TextButton(
              child: Text("No"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text("Yes"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                auth.signOut().then((value) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                }).onError((error, stackTrace) {
                  Utils().toastMessage(error.toString());
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToProfileScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfileScreen()),
    );
  }

  void _navigateToBusinessScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  void _navigateToUpdateProfileScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UpdateScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[600],
        foregroundColor: Colors.white,
        title: Text("Post Screen"),
        actions: [
          IconButton(
            onPressed: () {
              _showLogoutConfirmationDialog(context);
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _navigateToProfileScreen,
              child: Card(
                margin: EdgeInsets.all(16.0),
                child: Center(
                  child: ListTile(
                    leading: Icon(Icons.person, color: Colors.blue, size: 48),
                    title: Text("Profile", style: TextStyle(fontSize: 24)),
                    subtitle: Text("View your profile"),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: _navigateToBusinessScreen,
              child: Card(
                margin: EdgeInsets.all(16.0),
                child: Center(
                  child: ListTile(
                    leading: Icon(Icons.business, color: Colors.blue, size: 48),
                    title: Text("Business", style: TextStyle(fontSize: 24)),
                    subtitle: Text("View business information"),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: _navigateToUpdateProfileScreen,
              child: Card(
                margin: EdgeInsets.all(16.0),
                child: Center(
                  child: ListTile(
                    leading: Icon(Icons.edit, color: Colors.blue, size: 48),
                    title: Text("Update Profile", style: TextStyle(fontSize: 24)),
                    subtitle: Text("Update your profile information"),
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
