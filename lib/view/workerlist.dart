import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/worker_model.dart';
import 'package:url_launcher/url_launcher.dart';


class WorkersList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Workers List", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF033015),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('workers').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No workers found'));
          }

          var workers = snapshot.data!.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            return Worker.fromMap(data);
          }).toList();

          return ListView.builder(
            padding: EdgeInsets.all(20),
            itemCount: workers.length,
            itemBuilder: (context, index) {
              var worker = workers[index];
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
                                worker.workerName,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                worker.jobTitle,
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
                                  worker.description,
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                              SizedBox(height: 9),
                              Text("City: ${worker.city}"),
                              Align(
                                alignment: Alignment.centerRight,
                                child:  ElevatedButton(
                                  onPressed: () {
                                    launchUrl(Uri.parse('tel:${worker.phone}'));
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
                                worker.workerName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                worker.jobTitle,
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
                                  worker.description,
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Call button positioned on the right side.
                        // Call button positioned on the right side.
                        ElevatedButton(
                          onPressed: () {
                            launchUrl(Uri.parse('tel:${worker.phone}'));
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
          );
        },
      ),
    );
  }
}
