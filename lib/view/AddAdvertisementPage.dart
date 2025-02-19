import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddAdvertisementPage extends StatefulWidget {
  @override
  _AddAdvertisementPageState createState() => _AddAdvertisementPageState();
}

class _AddAdvertisementPageState extends State<AddAdvertisementPage> {
  File? _image;
  File? _video;
  final TextEditingController _descriptionController = TextEditingController();

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

  void _submitImageAd() {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please add an image to post")),
      );
      return;
    }
    print("Image Advertisement Submitted");
    print("Image selected: ${_image!.path}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Image Advertisement Posted Successfully!")),
    );
    setState(() {
      _image = null;
    });
  }

  void _submitVideoAd() {
    if (_video == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please add a video to post")),
      );
      return;
    }
    print("Video Advertisement Submitted");
    print("Video selected: ${_video!.path}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Video Advertisement Posted Successfully!")),
    );
    setState(() {
      _video = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Advertisement"), backgroundColor: Color(0xFF033015)),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: "Advertisement Description",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.text_fields),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 15),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 5,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  child: Center(
                    child: _image == null
                        ? Text("Post Image", style: TextStyle(color: Colors.white))
                        : Image.file(_image!, fit: BoxFit.cover),
                  ),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.image, color: Colors.white),
                label: Text("Upload Image", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF033015)),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _submitImageAd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF033015),
                ),
                child: Text("Post Image Advertisement", style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 5,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  child: Center(
                    child: _video == null
                        ? Text("Post Video", style: TextStyle(color: Colors.white))
                        : Icon(Icons.video_collection, size: 50, color: Colors.red),
                  ),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _pickVideo,
                icon: Icon(Icons.video_call, color: Colors.white),
                label: Text("Upload Video", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF033015)),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _submitVideoAd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF033015),
                ),
                child: Text("Post Video Advertisement", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}