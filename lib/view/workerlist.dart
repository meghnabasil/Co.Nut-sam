import 'package:flutter/material.dart';

class WorkersList extends StatelessWidget {
  // Define the total number of workers you want to display.
  final int workerCount = 6;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Workers List", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF033015),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(20),
        itemCount: workerCount,
        itemBuilder: (context, index) {
          // Dynamically generate worker details based on the index.
          final String workerName = "Worker ${index + 1}";
          final String jobTitle = "Job Title ${index + 1}";
          final String details =
              " This worker has years of experience in their field.";
         final String city = "city";

          return GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workerName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            jobTitle,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 9),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              details,
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                          SizedBox(height: 9),
                          Text("city: city"),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                // Add call functionality here.
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF033015),
                                foregroundColor: Colors.white,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.phone, color: Colors.white),
                                  SizedBox(width: 7),
                                  Text("Call", style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 8,
              shadowColor: Colors.green,
              margin: EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Worker details column.
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workerName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            jobTitle,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8),
                          // Worker Details inside a box (Container)
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[500],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              details,
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Call button positioned on the right side.
                    ElevatedButton(
                      onPressed: () {
                        // Add call functionality here.
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF033015),
                        foregroundColor: Colors.white,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.phone, color: Colors.white),
                          SizedBox(width: 7),
                          Text("Call", style: TextStyle(fontSize: 9)),
                        ],
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
