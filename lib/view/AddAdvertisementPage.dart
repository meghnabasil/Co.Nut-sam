import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class AddAdvertisementPage extends StatefulWidget {
  final String? productId;

  const AddAdvertisementPage({Key? key, this.productId}) : super(key: key);

  @override
  _AddAdvertisementPageState createState() => _AddAdvertisementPageState();
}

class _AddAdvertisementPageState extends State<AddAdvertisementPage> {
  File? _image;
  File? _video;
  final TextEditingController _descriptionController = TextEditingController();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickVideo() async {
    final pickedFile = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _video = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadFile(File file, String folder) async {
    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      Reference ref = _storage.ref().child('$folder/$fileName');
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed: $e")),
      );
      return null;
    }
  }

  Future<void> _submitImageAd() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please add an image to post")),
      );
      return;
    }

    String? imageUrl = await _uploadFile(_image!, "advertisements/images");
    if (imageUrl != null) {
      await _firestore.collection('advertisements').add({
        'type': 'image',
        'url': imageUrl,
        'productId':widget.productId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image Advertisement Posted Successfully!")),
      );

      setState(() {
        _image = null;
      });
    }
  }

  Future<void> _submitVideoAd() async {
    if (_video == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please add a video to post")),
      );
      return;
    }

    String? videoUrl = await _uploadFile(_video!, "advertisements/videos");
    if (videoUrl != null) {
      await _firestore.collection('advertisements').add({
        'type': 'video',
        'url': videoUrl,
        'description': _descriptionController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Video Advertisement Posted Successfully!")),
      );

      setState(() {
        _video = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Advertisement", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF033015),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: Colors.green, width: 2),
            ),
            elevation: 5,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Dear Vendors, Upload your advertisement below and enhance your company to the next level in the market.",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 15),
                  _buildUploadSection("Post Image", _image, _pickImage, _submitImageAd),
                  SizedBox(height: 20),
                  _buildUploadSection("Post Video", _video, _pickVideo, _submitVideoAd),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadSection(String label, File? file, VoidCallback pickFunction, VoidCallback submitFunction) {
    return Column(
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.green, width: 2),
          ),
          elevation: 5,
          child: Container(
            height: 150,
            width: double.infinity,
            child: Center(
              child: file == null
                  ? Text(label, style: TextStyle(color: Colors.black))
                  : file.path.endsWith("mp4")
                  ? Icon(Icons.video_collection, size: 50, color: Colors.red)
                  : Image.file(file, fit: BoxFit.cover),
            ),
          ),
        ),
        SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: pickFunction,
          icon: Icon(Icons.upload, color: Colors.white),
          label: Text("Upload", style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF033015)),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: submitFunction,
          style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF033015)),
          child: Text("Post Advertisement", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
