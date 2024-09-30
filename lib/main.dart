import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
//import 'dart:io';
import 'google_drive_service.dart'; // The working GoogleDriveService

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GoogleDriveService _googleDriveService = GoogleDriveService();
  bool _isUploading = false;
  String? _imagePath; // Path to the picture taken by the camera

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Google Drive File Upload"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                await _googleDriveService.signIn();
                setState(() {});
              },
              child: const Text("Sign in with Google"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _googleDriveService.isUserSignedIn() && !_isUploading
                  ? () async {
                      if (_imagePath == null) {
                        // Display message if no picture is taken
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please take a picture first!')),
                        );
                        return;
                      }
                      setState(() {
                        _isUploading = true;
                      });
                      await _googleDriveService.uploadFile(_imagePath!); // Use image path
                      setState(() {
                        _isUploading = false;
                      });
                    }
                  : null,
              child: _isUploading ? CircularProgressIndicator() : Text("Upload File"),
            ),
            const SizedBox(height: 20),
            // New button to take a picture
            ElevatedButton(
              onPressed: () async {
                await _takePicture();
                setState(() {});
              },
              child: const Text("Take Picture"),
            ),
            if (_imagePath != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Picture taken: $_imagePath"),
              ),
          ],
        ),
      ),
    );
  }

  // Function to take a picture using the camera and store the path in a global variable
  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      _imagePath = pickedFile.path;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No picture was taken')),
      );
    }
  }
}
