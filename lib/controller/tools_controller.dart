import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../model/tools_model.dart';

class ToolController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<List<String>> uploadImages(List<File> images) async {
    List<String> downloadUrls = [];
    for (File image in images) {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = _storage.ref().child('tools/$fileName');
      UploadTask uploadTask = ref.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      downloadUrls.add(downloadUrl);
    }
    return downloadUrls;
  }

  Future<void> addTool(Tool tool) async {
    await _firestore.collection('tools').add(tool.toMap());
  }

  Stream<List<Tool>> getTools() {
    return _firestore.collection('tools').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Tool.fromMap(doc.id, doc.data())).toList();
    });
  }
}
