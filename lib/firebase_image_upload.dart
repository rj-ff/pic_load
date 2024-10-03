import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart';

class ImageUploader {
  // Upload image to Firebase Storage and store the URL in Firestore
  Future<String> uploadImage(String imagePath) async {
    try {
      File imageFile = File(imagePath); // Convert imagePath to a File object
      String fileName = basename(imageFile.path); // Extract file name from the path

      // Step 1: Upload image to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child('images/$fileName');
      UploadTask uploadTask = storageRef.putFile(imageFile);

      // Step 2: Wait for the upload to complete and get the download URL
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadURL = await taskSnapshot.ref.getDownloadURL();

      // Step 3: Store the download URL and other metadata in Firestore
      await FirebaseFirestore.instance.collection('images').add({
        'url': downloadURL,
        'name': fileName,
        'uploaded_at': Timestamp.now(),
      });

      // Return the download URL
      return downloadURL;
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }

  // Retrieve all image URLs from Firestore
  Future<List<String>> retrieveImageURLs() async {
    List<String> imageURLs = [];
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('images').get();
      for (var doc in snapshot.docs) {
        imageURLs.add(doc['url']);
      }
    } catch (e) {
      print('Error retrieving image URLs: $e');
    }
    return imageURLs;
  }
}