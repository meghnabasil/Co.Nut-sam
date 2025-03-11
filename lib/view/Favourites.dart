import 'package:dup/view/productlist.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoriteListPage extends StatefulWidget {
  @override
  _FavoriteListPageState createState() => _FavoriteListPageState();
}

class _FavoriteListPageState extends State<FavoriteListPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("My WishList",style: TextStyle(color: Colors.white),),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF033015), 
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('favorites')
            .doc(user!.uid)
            .collection('items')
            .orderBy('addedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No favorites added yet"));
          }

          var favoriteDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: favoriteDocs.length,
            itemBuilder: (context, index) {
              var favData = favoriteDocs[index].data() as Map<String, dynamic>;

              return Card(
                elevation: 8,
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                shadowColor: Colors.green.shade300,
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: ListTile(
                    leading: favData['imageUrl'] != null && favData['imageUrl'].isNotEmpty
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(01),
                      child: Image.network(favData['imageUrl'], width: 90, height: 100, fit: BoxFit.cover),
                    )
                        : Icon(Icons.image, size: 60, color: Colors.grey),
                    title: Text(
                      favData['productName'] ?? "Unnamed Product",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 5),
                        Text(
                          "Company: ${favData['name'] ?? 'Unknown'}",
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                        Text(
                          "Price: ₹${favData['price']?.toString() ?? 'N/A'}",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.green),
                        ),
                      ],
                    ),
                    onTap: () {
                      // Navigate to Product Detail Page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetail(
                            productIndex: favData['productId'], // Pass the product ID
                          ),
                        ),
                      );
                    },
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red, size: 28),
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('favorites')
                            .doc(user!.uid)
                            .collection('items')
                            .doc(favoriteDocs[index].id)
                            .delete();
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
