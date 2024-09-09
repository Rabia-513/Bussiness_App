import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';

import '../widgets/bussiness.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FoodScreen(),
    );
  }
}

class FoodScreen extends StatefulWidget {
  const FoodScreen({super.key});

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  final DatabaseReference ref = FirebaseDatabase.instance.ref('bussiness_App');
  String searchQuery = '';
  String selectedLocation = 'All';

  List<String> locations = ['All', 'New York', 'Los Angeles', 'Chicago'];

  Query _getBusinessesQuery() {
    Query query = ref.orderByChild('category').equalTo('Food');
    if (selectedLocation != 'All') {
      query = query.orderByChild('location').equalTo(selectedLocation);
    }
    if (searchQuery.isNotEmpty) {
      query = query.orderByChild('name').startAt(searchQuery).endAt('$searchQuery\uf8ff');
    }
    return query;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text('Food Businesses'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: BusinessSearch());
            },
          )
        ],
      ),
      body: Column(
        children: [
          _buildLocationFilter(),

          Expanded(
            child: FirebaseAnimatedList(
              query: _getBusinessesQuery(),
              itemBuilder: (context, snapshot, animation, index) {
                final business = snapshot.value.toString() as Map<dynamic, dynamic>;
                return _buildBusinessItem(business);
              },
            ),
          ),
        ],
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

  Widget _buildLocationFilter() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          DropdownButton<String>(
            value: selectedLocation,
            items: locations.map((location) {
              return DropdownMenuItem(value: location, child: Text(location));
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedLocation = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessItem(Map<dynamic, dynamic> business) {
    return ListTile(
      title: Text(business['name'].value.toString(),),
      subtitle: Text('${business['address'].value.toString()}\nContact: ${business['phone'].value.toString()}'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BusinessDetailScreen(business: business)),
        );
      },
    );
  }
}

class BusinessDetailScreen extends StatelessWidget {
  final Map<dynamic, dynamic> business;

  BusinessDetailScreen({required this.business});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(business['name'])),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Text(business['name'], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Address: ${business['address']}'),
            SizedBox(height: 10),
            Text('Phone: ${business['phone']}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Call business logic
              },
              child: Text('Call Business'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Read/write reviews logic
              },
              child: Text('Write Review'),
            ),
          ],
        ),
      ),
    );
  }
}

class BusinessSearch extends SearchDelegate {
  final DatabaseReference ref = FirebaseDatabase.instance.ref('bussiness_App');

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [IconButton(icon: Icon(Icons.search), onPressed: () => query = '')];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FirebaseAnimatedList(
      query: ref
          .orderByChild('category')
          .equalTo('Food')
          .orderByChild('name')
          .startAt(query)
          .endAt('$query\uf8ff'),
      itemBuilder: (context, snapshot, animation, index) {
        final business = snapshot.value as Map<dynamic, dynamic>;
        return ListTile(
          title: Text(business['name']),
          subtitle: Text(business['address']),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Center(child: Text('Search for businesses...'));
  }
}
