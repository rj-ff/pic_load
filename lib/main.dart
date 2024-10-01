import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'google_drive_service.dart'; // The working GoogleDriveService

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please take a picture first!')),
                        );
                        return;
                      }
                      setState(() {
                        _isUploading = true;
                      });
                      await _googleDriveService.uploadFile(_imagePath!);
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
                  _takePicture(); //_takePicture();
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

  try {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Picture taken: $_imagePath')),
      );
    } else {
      // This will get called if no image is returned (e.g., user cancels)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No picture was taken')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}
 Future<void> capturePictureFromCamera(BuildContext context) async {
  final ImagePicker _picker = ImagePicker();

  try {
    // Pick image from the camera
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    // Ensure we wait for the result properly
    if (pickedFile != null && context.mounted) {
      // Handle successful image capture
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Picture taken: ${pickedFile.path}')),
      );
    } else {
      // Show a message that the capture was canceled
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No picture was taken')),
      );
    }
  } catch (e) {
    // Handle any errors during the process
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}
}
