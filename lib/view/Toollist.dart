import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ToolsDetail extends StatefulWidget {
  final String toolId; // Fetch tool using ID

  ToolsDetail({required this.toolId});

  @override
  _ToolsDetailState createState() => _ToolsDetailState();
}

class _ToolsDetailState extends State<ToolsDetail> {
  Map<String, dynamic>? toolData;

  @override
  void initState() {
    super.initState();
    _fetchToolDetails();
  }

  Future<void> _fetchToolDetails() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('tools')
          .doc(widget.toolId)
          .get();

      if (doc.exists) {
        setState(() {
          toolData = doc.data() as Map<String, dynamic>;
        });
      }
    } catch (e) {
      print("Error fetching tool details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tool Details", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF033015),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.white,
      body: toolData == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text(
              toolData!['name'] ?? 'Unnamed Tool',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // **Carousel Slider for Images**
            if (toolData!['imageUrls'] != null &&
                toolData!['imageUrls'] is List &&
                (toolData!['imageUrls'] as List).isNotEmpty)
              CarouselSlider(
                items: (toolData!['imageUrls'] as List).map((url) {
                  return Image.network(
                    url,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  );
                }).toList(),
                options: CarouselOptions(
                  height: 200,
                  enlargeCenterPage: true,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 5),
                  viewportFraction: 0.8,
                ),
              )
            else
              Center(
                child: Icon(Icons.broken_image, size: 80, color: Colors.grey),
              ),

            SizedBox(height: 20),
            Divider(thickness: 2, color: Colors.grey),
            SizedBox(height: 10),

            // **Tool Company**
            Text(
              toolData!['company'] ?? 'No Company',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 10),

            // **Price**
            Text(
              "₹${toolData!['price']?.toString() ?? 'N/A'}",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF380230)),
            ),

            SizedBox(height: 5),
            Text(
              'This price includes all applicable taxes and fees.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),

            SizedBox(height: 40),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF033015),
                      foregroundColor: Color(0xFFFFFFFF),
                    ),
                    child: Text('Add to Cart'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF033015),
                      foregroundColor: Color(0xFFFFFFFF),
                    ),
                    child: Text('Buy'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
