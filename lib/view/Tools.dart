import 'package:dup/view/Toollist.dart';
import 'package:flutter/material.dart';

class ListOfTools extends StatelessWidget {
  // Total number of tools to display.
  final int toolCount = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tools List", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF033015),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.white,
      body: GridView.builder(
        padding: EdgeInsets.all(10),
        itemCount: toolCount,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,           // Two columns in the grid
          crossAxisSpacing: 10,        // Horizontal spacing between grid items
          mainAxisSpacing: 10,         // Vertical spacing between grid items
          childAspectRatio: 0.8,       // Adjust this ratio as needed
        ),
        itemBuilder: (context, index) {
          final String toolName = "Tool ${index + 1}";
          final String companyName = "Tool Company ${index + 1}";
          final String price = "₹${(index + 1) * 100}";
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            shadowColor: Colors.green,
            elevation: 8,
            child: InkWell(
              onTap: () {
                // Navigate to a detail page for the tool.
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
                    // Increase image size by setting a fixed height.
                    Container(
                      height: 110, // Adjust height to increase image size.
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'asset/mach.webp', // Update with your actual image asset path
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      toolName,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(companyName),
                    Text(
                      price,
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
