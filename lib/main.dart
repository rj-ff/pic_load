import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart'; // For temporary storage
import 'google_drive_service.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Drive Upload App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final GoogleDriveService _googleDriveService = GoogleDriveService(); // Make sure you have this service class
  bool _isUploading = false;

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
                      setState(() {
                        _isUploading = true;
                      });
                      await _googleDriveService.uploadFile();
                      setState(() {
                        _isUploading = false;
                      });
                    }
                  : null, // Disables the button if not signed in or during upload
              child: _isUploading
                  ? CircularProgressIndicator() // Shows loading indicator during upload
                  : const Text("Upload File"), // Normal button when not uploading
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // This is a placeholder for taking a picture (not implemented yet)
              },
              child: const Text("Take Picture"),
            ),
          ],
        ),
      ),
    );
  }
}