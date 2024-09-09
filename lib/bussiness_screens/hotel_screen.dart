import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/bussiness.dart';

class HotelScreen extends StatefulWidget {
  const HotelScreen({super.key});

  @override
  State<HotelScreen> createState() => _HotelScreenState();
}

class _HotelScreenState extends State<HotelScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String searchQuery = '';
  String selectedLocation = 'All';
  List<String> locations = ['All', 'Rawalpindi', 'Lahore', 'Islamabad'];

  Stream<QuerySnapshot> _getBusinesses() {
    CollectionReference businessesRef = _firestore.collection('businesses');
    Query query = businessesRef.where('category', isEqualTo: 'Hotels');

    if (selectedLocation != 'All') {
      query = query.where('location', isEqualTo: selectedLocation);
    }

    if (searchQuery.isNotEmpty) {
      query = query.where('name', isGreaterThanOrEqualTo: searchQuery)
          .where('name', isLessThanOrEqualTo: '$searchQuery\uf8ff');
    }

    return query.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text('Hotels'),
        foregroundColor: Colors.white,
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
            child: StreamBuilder<QuerySnapshot>(
              stream: _getBusinesses(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final businesses = snapshot.data!.docs;

                if (businesses.isEmpty) {
                  return Center(child: Text('No businesses found'));
                }

                return ListView.builder(
                  itemCount: businesses.length,
                  itemBuilder: (context, index) {
                    var business = businesses[index];
                    return ListTile(
                      leading: business['thumbnail'] != null
                          ? Image.network(business['thumbnail'], width: 50, height: 50, fit: BoxFit.cover)
                          : Icon(Icons.hotel, size: 50),
                      title: Text(business['name']),
                      subtitle: Text('${business['address']}\n${business['speciality']}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BusinessDetailScreen(businessId: business.id),
                          ),
                        );
                      },
                    );
                  },
                );
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
            MaterialPageRoute(
              builder: (context) => AddBusinessScreen(category: 'Hotels'),
            ),
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
}

class BusinessDetailScreen extends StatelessWidget {
  final String businessId;

  BusinessDetailScreen({required this.businessId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Business Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('businesses').doc(businessId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Business not found.'));
          }

          var business = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(business['thumbnail'] ?? '', width: double.infinity, height: 200, fit: BoxFit.cover),
                SizedBox(height: 10),
                Text(business['name'], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text('Address: ${business['address']}'),
                SizedBox(height: 10),
                Text('Phone: ${business['phone']}'),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Call business action
                  },
                  child: Text('Call Business'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WriteReviewScreen(businessId: businessId),
                      ),
                    );
                  },
                  child: Text('Write Review'),
                ),
                SizedBox(height: 20),
                Text('Reviews:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('businesses')
                        .doc(businessId)
                        .collection('reviews')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(child: Text('No reviews yet.'));
                      }

                      var reviews = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: reviews.length,
                        itemBuilder: (context, index) {
                          var review = reviews[index].data() as Map<String, dynamic>;
                          return ListTile(
                            title: Text(review['user']),
                            subtitle: Text(review['review']),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class WriteReviewScreen extends StatefulWidget {
  final String businessId;

  WriteReviewScreen({required this.businessId});

  @override
  _WriteReviewScreenState createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  String reviewText = '';
  String user = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Write a Review')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Your Name'),
                validator: (value) => value!.isEmpty ? 'Enter your name' : null,
                onChanged: (value) => setState(() => user = value),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Review'),
                validator: (value) => value!.isEmpty ? 'Enter your review' : null,
                onChanged: (value) => setState(() => reviewText = value),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitReview,
                child: Text('Submit Review'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitReview() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('businesses').doc(widget.businessId).collection('reviews').add({
        'user': user,
        'review': reviewText,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Review submitted successfully!')));
      Navigator.pop(context);
    }
  }
}

class BusinessSearch extends SearchDelegate {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [IconButton(icon: Icon(Icons.clear), onPressed: () => query = '')];
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
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('businesses')
          .where('category', isEqualTo: 'Hotels')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No businesses found'));
        }

        final businesses = snapshot.data!.docs;

        return ListView.builder(
          itemCount: businesses.length,
          itemBuilder: (context, index) {
            var business = businesses[index];
            return ListTile(
              leading: business['thumbnail'] != null
                  ? Image.network(business['thumbnail'], width: 50, height: 50, fit: BoxFit.cover)
                  : Icon(Icons.hotel, size: 50),
              title: Text(business['name']),
              subtitle: Text('${business['address']}\n${business['speciality']}'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BusinessDetailScreen(businessId: business.id),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
