import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart'; // For temporary storage


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TakePhotoScreen(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Take a Photo'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => TakePhotoScreen()),
            );
          },
          child: Text('Open Camera'),
        ),
      ),
    );
  }
}

class TakePhotoScreen extends StatefulWidget {
  @override
  _TakePhotoScreenState createState() => _TakePhotoScreenState();
}

class _TakePhotoScreenState extends State<TakePhotoScreen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _takePhoto() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      // Get the temporary directory for the device
      final Directory tempDir = await getTemporaryDirectory();
      // Create a new file in the temporary directory
      final File tempFile = File('${tempDir.path}/${pickedFile.name}');

      // Save the photo to the temporary directory
      final File savedImage = await File(pickedFile.path).copy(tempFile.path);

      setState(() {
        _imageFile = savedImage;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Photo saved temporarily: ${savedImage.path}')),
      );
    }
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
            if (_imageFile != null)
              Image.file(
                _imageFile!,
                width: 300,
                height: 300,
              )
            else
              Text('No photo taken yet.'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _takePhoto,
              child: Text('Take Photo'),
            ),
          ],
        ),
      ),
    );
  }
}
