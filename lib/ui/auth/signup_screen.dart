import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart'; // For storing images
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';  // For picking images
import 'dart:io';
import 'package:firebase/ui/auth/login_screen.dart';
import 'package:firebase/utills/utils.dart';
import 'package:firebase/widgets/round_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool loading = false;
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final cityController = TextEditingController();
  final addressController = TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;
  final databaseRef = FirebaseDatabase.instance.ref('Data Base');
  final FirebaseStorage _storage = FirebaseStorage.instance;

  File? _image;  // To store the selected image

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    confirmPasswordController.dispose();
    cityController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImageToFirebase(File image) async {
    try {
      String fileName = 'user_profile_images/${DateTime.now().microsecondsSinceEpoch}.png';
      UploadTask uploadTask = _storage.ref(fileName).putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      Utils().toastMessage(e.toString());
      return null;
    }
  }

  void signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        loading = true;
      });

      if (passwordController.text != confirmPasswordController.text) {
        Utils().toastMessage('Passwords do not match');
        setState(() {
          loading = false;
        });
        return;
      }

      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        String? imageUrl;
        if (_image != null) {
          imageUrl = await _uploadImageToFirebase(_image!);
        }

        await databaseRef.child(userCredential.user!.uid).set({
          'Name': nameController.text.trim(),
          'Email': emailController.text.trim(),
          'Password': passwordController.text.trim(),
          'City': cityController.text.trim(),
          'Address': addressController.text.trim(),
          'ImageURL': imageUrl ?? '',

        });

        Utils().toastMessage("Signup successful");
        setState(() {
          loading = false;
        });

        // Navigate to the home screen
        Navigator.pushReplacementNamed(context, '/home');
      } catch (error) {
        Utils().toastMessage(error.toString());
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[600],
        foregroundColor: Colors.white,
        title: Text("Signup"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _image == null
                      ? AssetImage('assets/placeholder.png') // Placeholder image
                      : FileImage(_image!) as ImageProvider,
                  child: _image == null
                      ? Icon(Icons.camera_alt, size: 50, color: Colors.grey[700])
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Welcome, sign up here!',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'Name',
                        prefixIcon: Icon(Icons.person),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty || !value.contains('@')) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty || value.length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Confirm Password',
                        prefixIcon: Icon(Icons.lock),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Confirm your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: cityController,
                      decoration: InputDecoration(
                        hintText: 'City',
                        prefixIcon: Icon(Icons.location_city),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter your city';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: addressController,
                      decoration: InputDecoration(
                        hintText: 'Address',
                        prefixIcon: Icon(Icons.home),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter your address';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              RoundButton(
                title: 'Signup',
                loading: loading,
                onTap: () {
                  signup();
                  setState(() {
                    loading=true;
                  });
                  String id  = DateTime.now().millisecondsSinceEpoch.toString();
                  databaseRef.child(id).set({
                    'Address': addressController.text.toString(),
                    'Password': passwordController.text.toString(),
                    'Name': nameController.text.toString(),
                    'Email': emailController.text.toString(),
                    'City': cityController.text.toString(),
                    'ID':id,


                  }).then((value) {
                    Utils().toastMessage("data added");
                    setState(() {
                      loading=false;
                    });
                  }).onError((error, stackTrance) {
                    Utils().toastMessage(error.toString());
                    setState(() {
                      loading=false;
                    });
                  });

                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Already have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: Text('Login'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
