import 'package:dup/view/chatdetailscreen.dart';
import 'package:flutter/material.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  // Dummy chat data (replace with Firebase or API data)
  List<Map<String, String>> chats = [
    {
      "name": "John Doe",
      "profileImage": "https://randomuser.me/api/portraits/men/1.jpg",
      "lastMessage": "Hello! How can I help you?",
    },
    {
      "name": "Emma Watson",
      "profileImage": "https://randomuser.me/api/portraits/women/2.jpg",
      "lastMessage": "Your order has been shipped!",
    },
    {
      "name": "Vendor XYZ",
      "profileImage": "https://randomuser.me/api/portraits/men/3.jpg",
      "lastMessage": "Let me know if you need more details.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF033015),
        title: const Text(
          "Chat",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 5, // Adds shadow effect
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              shadowColor: Colors.green.withOpacity(0.6), // Green shadow effect
              child: ListTile(
                contentPadding: const EdgeInsets.all(10),
                leading: CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(chats[index]["profileImage"]!),
                ),
                title: Text(
                  chats[index]["name"]!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(chats[index]["lastMessage"]!),
                trailing: const Icon(Icons.chat_bubble_outline, color: Colors.green),
                onTap: () {
                  // Navigate to individual chat screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatDetailScreen(
                        name: chats[index]["name"]!,
                        profileImage: chats[index]["profileImage"]!,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
