import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'vendormessagescreen.dart';

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = _auth.currentUser?.uid ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chats")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection("chat_rooms")
            .where("participants", arrayContains: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No chats available"));
          }

          List<QueryDocumentSnapshot> chatRooms = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              var chatRoom = chatRooms[index];
              List<String> participants = List<String>.from(chatRoom["participants"]);
              String otherUserId = participants.firstWhere((id) => id != currentUserId, orElse: () => "");

              if (otherUserId.isEmpty) return const SizedBox.shrink();

              return FutureBuilder<DocumentSnapshot?>(
                future: _getOtherUserData(otherUserId),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink();
                  }

                  if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                    return const SizedBox.shrink();
                  }

                  var userData = userSnapshot.data!.data() as Map<String, dynamic>;
                  String otherUserName = userData["name"] ?? "Unknown User";

                  return ListTile(
                    title: Text(otherUserName),
                    subtitle: StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection("chat_rooms")
                          .doc(chatRoom.id)
                          .collection("messages")
                          .orderBy("timestamp", descending: true)
                          .limit(1)
                          .snapshots(),
                      builder: (context, messageSnapshot) {
                        if (!messageSnapshot.hasData || messageSnapshot.data!.docs.isEmpty) {
                          return const Text("No messages yet");
                        }
                        var lastMessage = messageSnapshot.data!.docs.first;
                        return Text(lastMessage["message"] ?? "", maxLines: 1, overflow: TextOverflow.ellipsis);
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            vendorId: otherUserId,
                            businessName: otherUserName,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<DocumentSnapshot?> _getOtherUserData(String otherUserId) async {
    var userDoc = await _firestore.collection("users").doc(otherUserId).get();
    if (userDoc.exists) return userDoc;
    var vendorDoc = await _firestore.collection("vendors").doc(otherUserId).get();
    return vendorDoc.exists ? vendorDoc : null;
  }
}
