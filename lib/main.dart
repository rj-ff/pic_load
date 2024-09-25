import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;  // Alias to avoid conflicts
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures the binding is initialized
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(TakePhotoApp());
}

class TakePhotoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Take a Photo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(), // Set HomePage as the home widget
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photo App'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TakePhotoScreen()), // Navigate to the TakePhotoScreen
            );
          },
          child: Text('Take a Photo'),
        ),
      ),
    );
  }
}

class TakePhotoScreen extends StatefulWidget {
  const TakePhotoScreen({Key? key}) : super(key: key); // Added named key parameter

  @override
  _TakePhotoScreenState createState() => _TakePhotoScreenState();
}

class _TakePhotoScreenState extends State<TakePhotoScreen> {
  File? _image; // To store the selected image
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false; // To track if the file is uploading

  // Function to take a photo
  Future<void> _takePhoto() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      // Automatically upload the photo after it's taken
      if (_image != null) {
        await _uploadPhoto(_image!); // Upload the photo to Firebase
      }
    }
  }

  // Independent function to upload photo to Firebase
  Future<void> _uploadPhoto(File image) async {
    setState(() {
      _isUploading = true;
    });

    try {
      String fileName = path.basename(image.path); // Extract filename using the aliased path
      Reference storageRef = FirebaseStorage.instance.ref().child("uploads/$fileName");

      // Upload the file
      await storageRef.putFile(image);

      // Get the download URL
      String downloadUrl = await storageRef.getDownloadURL();

      // Show a Snackbar using the context from the state
      _showSnackBar('Photo uploaded successfully: $downloadUrl');
    } catch (e) {
      // Show a Snackbar using the context from the state
      _showSnackBar('Failed to upload image: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  // Helper method to show Snackbar
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Take a Photo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image == null
                ? Text('No image selected.')
                : Image.file(_image!), // Display the selected image
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _takePhoto, // Trigger the function to take a photo
              child: Text('Take a Photo'),
            ),
            if (_isUploading) CircularProgressIndicator(), // Show a loading spinner when uploading
          ],
        ),
      ),
    );
  }
}