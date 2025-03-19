import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String vendorId;
  final String businessName;

  ChatScreen({required this.vendorId, required this.businessName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = _auth.currentUser?.uid ?? "";
    _initializeChatRoom();
  }

  String _getChatRoomId(String user1, String user2) {
    List<String> users = [user1, user2]..sort(); // Ensure consistent ID
    return users.join("_");
  }

  void _initializeChatRoom() async {
    String chatRoomId = _getChatRoomId(currentUserId, widget.vendorId);

    DocumentSnapshot chatRoom = await _firestore.collection("chat_rooms").doc(chatRoomId).get();

    if (!chatRoom.exists) {
      await _firestore.collection("chat_rooms").doc(chatRoomId).set({
        "participants": [currentUserId, widget.vendorId],
        "createdAt": FieldValue.serverTimestamp(),
      });
    }
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    String chatRoomId = _getChatRoomId(currentUserId, widget.vendorId);

    await _firestore.collection("chat_rooms").doc(chatRoomId).set({
      "participants": [currentUserId, widget.vendorId], // Ensure room exists
    }, SetOptions(merge: true));

    await _firestore.collection("chat_rooms").doc(chatRoomId).collection("messages").add({
      "senderId": currentUserId,
      "message": _messageController.text.trim(),
      "timestamp": FieldValue.serverTimestamp(), // Ensure timestamp exists
    });

    _messageController.clear();
  }

  Stream<QuerySnapshot> _getMessages() {
    String chatRoomId = _getChatRoomId(currentUserId, widget.vendorId);
    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat with ${widget.businessName}"),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getMessages(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No messages yet..."));
                }

                var messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: false, // Ensure newest messages appear at the bottom
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    bool isMe = message["senderId"] == currentUserId;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          message["message"],
                          style: TextStyle(color: isMe ? Colors.white : Colors.black),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
