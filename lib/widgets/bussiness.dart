import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Business App'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Center(
        child: Text('Welcome to Business App'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepOrange,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddBusinessScreen(category: 'Food')),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddBusinessScreen extends StatefulWidget {
  final String category;

  AddBusinessScreen({required this.category});

  @override
  _AddBusinessScreenState createState() => _AddBusinessScreenState();
}

class _AddBusinessScreenState extends State<AddBusinessScreen> {
  final _formKey = GlobalKey<FormState>();
  String businessName = '';
  String address = '';
  String phone = '';
  String thumbnailUrl = '';
  String location = '';
  String speciality = '';
  String popularity = 'Regular';

  final List<String> popularityOptions = ['Regular', 'Popular'];

  final DatabaseReference ref = FirebaseDatabase.instance.ref('bussiness_App');
  Future<void> _addBusiness() async {
    if (_formKey.currentState!.validate()) {
      String id  = DateTime.now().millisecondsSinceEpoch.toString();

      await ref.push().child(id).set({
        'name': businessName,
        'address': address,
        'phone': phone,
        'thumbnail': thumbnailUrl,
        'location': location,
        'speciality': speciality,
        'popularity': popularity,
        'category': widget.category,
        'created_at': DateTime.now().toString(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Business added successfully!')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Business in ${widget.category}'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Business Name'),
                validator: (value) => value!.isEmpty ? 'Enter business name' : null,
                onChanged: (value) => setState(() => businessName = value),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Address'),
                validator: (value) => value!.isEmpty ? 'Enter address' : null,
                onChanged: (value) => setState(() => address = value),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Phone Number'),
                validator: (value) => value!.isEmpty ? 'Enter phone number' : null,
                onChanged: (value) => setState(() => phone = value),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Thumbnail URL'),
                validator: (value) => value!.isEmpty ? 'Enter thumbnail URL' : null,
                onChanged: (value) => setState(() => thumbnailUrl = value),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Location'),
                validator: (value) => value!.isEmpty ? 'Enter location' : null,
                onChanged: (value) => setState(() => location = value),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Speciality'),
                validator: (value) => value!.isEmpty ? 'Enter speciality' : null,
                onChanged: (value) => setState(() => speciality = value),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Popularity'),
                value: popularity,
                items: popularityOptions.map((String option) {
                  return DropdownMenuItem(value: option, child: Text(option));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    popularity = value!;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addBusiness,
                child: Text('Submit Business'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
