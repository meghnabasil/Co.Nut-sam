import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ToolDisplayPage extends StatefulWidget {
  @override
  _ToolDisplayPageState createState() => _ToolDisplayPageState();
}

class _ToolDisplayPageState extends State<ToolDisplayPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? currentVendorId;

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
      });
    }
  }

  Future<List<Map<String, dynamic>>> _fetchVendorTools() async {
    if (currentVendorId == null) return [];

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('tools')
        .where('vendorId', isEqualTo: currentVendorId)
        .get();

    return snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  void _showUpdateStockBottomSheet(Map<String, dynamic> tool) {
    final TextEditingController _stockController = TextEditingController();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Update Stock for ${tool['name']}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Enter new stock quantity"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF008000)),
                onPressed: () async {
                  final int? newStock = int.tryParse(_stockController.text);
                  if (newStock != null) {
                    await FirebaseFirestore.instance
                        .collection('tools')
                        .doc(tool['id'])
                        .update({'stock': newStock});
                    setState(() {
                      tool['stock'] = newStock;
                    });
                    Navigator.of(context).pop();
                  }
                },
                child: Text("Update Stock", style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteTool(String toolId) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Tool"),
          content: Text("Are you sure you want to delete this tool?"),
          actions: [
            TextButton(
              child: Text("Cancel", style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF008000)),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text("Delete", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      await FirebaseFirestore.instance.collection('tools').doc(toolId).delete();
      setState(() {});
    }
  }

  Widget _buildToolCard(Map<String, dynamic> tool, String toolId) {
    List<dynamic>? imageUrls = tool['imageUrls'];
    List<String> imageList = imageUrls != null && imageUrls.isNotEmpty
        ? List<String>.from(imageUrls)
        : [];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              child: imageList.isNotEmpty
                  ? ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: imageList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageList[index],
                        width: 322,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              )
                  : Center(
                child: Text("No Images Available", style: TextStyle(color: Colors.grey)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tool['name'] ?? 'Unnamed Tool',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  SizedBox(height: 4),
                  Text("Category: ${tool['category'] ?? 'N/A'}", style: TextStyle(color: Colors.grey[600])),
                  SizedBox(height: 4),
                  Text("Company name/Brand name: ${tool['company'] ?? 'N/A'}", style: TextStyle(color: Colors.grey[600])),
                  SizedBox(height: 4),
                  Text("Price: \$${tool['price']?.toStringAsFixed(2) ?? 'N/A'}", style: TextStyle(color: Colors.grey[600])),
                  SizedBox(height: 4),
                  Text("Description: ${tool['description'] ?? 'No description'}", style: TextStyle(color: Colors.grey[600])),
                  SizedBox(height: 4),
                  Text("Stock: ${tool['stock'] ?? 'N/A'}", style: TextStyle(color: Colors.grey[600])),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF033015)),
                          onPressed: () => _showUpdateStockBottomSheet(tool),
                          child: Text("Update Stock", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                          onPressed: () => _deleteTool(tool['id']),
                          child: Text("Delete", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Tool Display"),
      //   backgroundColor: Color(0xFF008000),
      // ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchVendorTools(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error fetching tools"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No tools available"));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final tool = snapshot.data![index];
              return _buildToolCard(tool, tool['id']);
            },
          );
        },
      ),
    );
  }
}
