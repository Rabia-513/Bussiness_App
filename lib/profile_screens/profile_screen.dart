import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../utills/utils.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DatabaseReference ref = FirebaseDatabase.instance.ref('Data Base');
  final FirebaseAuth auth = FirebaseAuth.instance;
  String searchQuery = '';
  TextEditingController searchController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text("Profile Search"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            // Search bar for email input
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search by Email',
                suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      setState(() {
                        // Update the search query when the search button is pressed
                        searchQuery = searchController.text.trim();
                      });
                    }
                ),
                border: const OutlineInputBorder(),
              ),
            ),

            // FirebaseAnimatedList to show the filtered profile
            Expanded(
              child: searchQuery.isEmpty
                  ? const Center(child: Text("Enter an email to search"))
                  : FirebaseAnimatedList(
                query: ref.orderByChild('Email').equalTo(searchQuery),
                itemBuilder: (context, snapshot, animation, index) {
                  if (snapshot.exists) {
                    // Display all user information
                    return ListTile(
                      title: Text(
                        snapshot.child('Name').value.toString(),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Text("ID: ${snapshot.child('ID').value.toString()}", style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 10),
                          Text("Email: ${snapshot.child('Email').value.toString()}", style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 10),
                          Text("Password: ${snapshot.child('Password').value.toString()}", style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 10),
                          Text("Address: ${snapshot.child('Address').value.toString()}", style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 10),
                          Text("City: ${snapshot.child('City').value.toString()}", style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                      trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            // Edit Menu Option
                            PopupMenuItem(
                              child: ListTile(
                                onTap: () {
                                  Navigator.pop(context);
                                  showEditDialog(
                                    snapshot.child('Name').value.toString(),
                                    snapshot.child('Email').value.toString(),
                                    snapshot.child('Password').value.toString(),
                                    snapshot.child('Address').value.toString(),
                                    snapshot.child('City').value.toString(),
                                    snapshot.child('ID').value.toString(),
                                  );
                                },
                                leading: const Icon(Icons.edit),
                                title: const Text('Edit'),
                              ),
                            ),
                            // Delete Menu Option
                            PopupMenuItem(
                              child: ListTile(
                                onTap: () {
                                  Navigator.pop(context);
                                  showDeleteConfirmation(snapshot.child('ID').value.toString());
                                },
                                leading: const Icon(Icons.delete),
                                title: const Text('Delete'),
                              ),
                            ),
                          ]
                      ),
                    );
                  } else {
                    Fluttertoast.showToast(
                      msg: "No profile found for this email.",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                    return Container();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showEditDialog(String name, String email, String password, String address, String city, String id) async {
    // Pre-fill the controllers with the current values
    nameController.text = name;
    emailController.text = email;
    passwordController.text = password;
    addressController.text = address;
    cityController.text = city;

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Edit Information'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: 'Address'),
                  ),
                  TextField(
                    controller: cityController,
                    decoration: const InputDecoration(labelText: 'City'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  // Update the user's data in Firebase
                  ref.child(id).update({
                    'Name': nameController.text,
                    'Email': emailController.text,
                    'Password': passwordController.text,
                    'Address': addressController.text,
                    'City': cityController.text,
                  }).then((value) {
                    Navigator.pop(context);
                    Utils().toastMessage("Profile updated successfully.");
                  }).catchError((error) {
                    Utils().toastMessage(error.toString());
                  });
                },
                child: const Text('Update'),
              ),
            ],
          );
        }
    );
  }

  // Function to confirm deletion
  Future<void> showDeleteConfirmation(String id) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete Profile'),
            content: const Text('Are you sure you want to delete this profile? This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  // Delete the user's data from Firebase
                  ref.child(id).remove().then((value) {
                    Navigator.pop(context);
                    Utils().toastMessage("Profile deleted successfully.");
                  }).catchError((error) {
                    Utils().toastMessage(error.toString());
                  });
                },
                child: const Text('Delete'),
              ),
            ],
          );
        }
    );
  }
}
