import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dup/view/Toollist.dart';

class ListOfTools extends StatefulWidget {
  @override
  _ListOfToolsState createState() => _ListOfToolsState();
}

class _ListOfToolsState extends State<ListOfTools> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? currentVendorId;
  List<Map<String, dynamic>> allTools = [];
  List<Map<String, dynamic>> filteredTools = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentVendor();
  }

  void _getCurrentVendor() {
    final User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        currentVendorId = user.uid;
        _fetchVendorTools();
      });
    }
  }

  Future<void> _fetchVendorTools() async {
    if (currentVendorId == null) return;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('tools')
        .where('vendorId', isEqualTo: currentVendorId)
        .get();

    setState(() {
      allTools = snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
      filteredTools = allTools;
    });
  }

  void _filterTools(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredTools = allTools;
      } else {
        filteredTools = allTools
            .where((tool) => tool['name']
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          decoration: BoxDecoration(
            color: Colors.white54, // Light grey background
            borderRadius: BorderRadius.circular(30), // Circular border radius 30
          ),
          child: TextField(
            controller: searchController,
            onChanged: _filterTools,
            style: TextStyle(color: Colors.black), // Text color
            decoration: InputDecoration(
              hintText: 'Search tools...',
              hintStyle: TextStyle(color: Colors.white70),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30), // Circular border (30)
                borderSide: BorderSide(color: Colors.transparent), // No visible border
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.green, width: 1), // Green border on focus
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.transparent), // No border when not focused
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15), // Padding
              prefixIcon: Icon(Icons.search, color: Colors.black54), // Search icon
              filled: true,
              fillColor: Colors.white54, // Background color
            ),
          ),
        ),
        backgroundColor: Color(0xFF033015),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.white,
      body: filteredTools.isEmpty
          ? Center(child: Text("No tools available."))
          : GridView.builder(
        padding: EdgeInsets.all(10),
        itemCount: filteredTools.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (context, index) {
          var tool = filteredTools[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 8,
            shadowColor: Colors.green,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ToolsDetail(toolIndex: index),
                  ),
                );
              },
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 110,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: (tool['imageUrls'] != null &&
                            tool['imageUrls'] is List &&
                            (tool['imageUrls'] as List).isNotEmpty)
                            ? Image.network(
                          tool['imageUrls'][0],
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.broken_image, size: 50, color: Colors.red);
                          },
                        )
                            : Icon(Icons.image, size: 50, color: Colors.grey),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      tool['name'] ?? 'Unnamed Tool',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(tool['company'] ?? 'No Company'),
                    Text(
                      "₹${tool['price']?.toStringAsFixed(2) ?? 'N/A'}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF380230),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
