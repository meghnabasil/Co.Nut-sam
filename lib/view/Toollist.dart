import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ToolsDetail extends StatefulWidget {
  final int toolIndex;

  ToolsDetail({required this.toolIndex});

  @override
  _ToolsDetailState createState() => _ToolsDetailState();
}

class _ToolsDetailState extends State<ToolsDetail> {
  String selectedOption = 'Retail';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tool Details", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF033015),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text(
              'Tool ' + (widget.toolIndex + 1).toString() + ' - An ideal tool for your tasks!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 80),
            CarouselSlider(
              items: [
                'asset/210379377.png',
                'asset/img1.jpg',
                'asset/music.jpg'
              ].map((item) => Image.asset(
                item,
                fit: BoxFit.cover,
                width: double.infinity,
              )).toList(),
              options: CarouselOptions(
                height: 150,
                enlargeCenterPage: true,
                enableInfiniteScroll: true,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 5),
                aspectRatio: 16 / 9,
                viewportFraction: 0.8,
              ),
            ),
            const SizedBox(height: 60), // Space between Carousel and Divider
            const Divider(thickness: 2, color: Colors.grey),
            const SizedBox(height: 10),

            Text('Tool Company', style: TextStyle(color: Colors.grey[600])),
            SizedBox(height: 10),
            Text(
              '₹${(widget.toolIndex + 1) * 20}',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF380230)),
            ),
            // Added description under the price box
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
