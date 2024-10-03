import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pic_load/firebase_service.dart';
import 'geolocation_service.dart';  // Replace with your project name
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore for GeoPoint and Timestamp
import 'firebase_image_upload.dart';

Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();
  final firstCamera = cameras.first;


  runApp(MyApp(camera: firstCamera));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.camera});

  final CameraDescription camera;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera App',
      theme: ThemeData.dark(),
      home: HomeScreen(camera: camera),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.camera});

  final CameraDescription camera;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _imagePath;
  final FirebaseService _firebaseService = FirebaseService();
  final ImageUploader imageUploader = ImageUploader();

  // Dummy data to be uploaded to Firestore
  int id = 1;
  String name = "Default Name";
  GeoPoint location = GeoPoint(37.7749, -122.4194); // Example location (San Francisco)
  Timestamp time = Timestamp.now();

  void _setImagePath(String path) {
    setState(() {
      _imagePath = path;
    });
  }

  Future<void> _uploadImage() async {
    // Replace this with your cloud upload logic
    if (_imagePath != null) {
      // Simulate uploading the image
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Uploading $_imagePath...')),
      );
      // Add your upload logic here
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No image to upload.')),
      );
    }
  }
  //  Future<void> _fetchLocation() async {
  //   Position? position = await _geolocationService.getGeolocation();
  //   if (position != null) {
  //     setState(() {
  //       location = 'Latitude: ${position.latitude}, Longitude: ${position.longitude}';
  //     });
  //   } else {
  //     setState(() {
  //       location = 'Failed to get location.';
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_imagePath != null) 
              Column(
                children: [
                  // Display the image path
                  Text('Image Path: $_imagePath'),
                  const SizedBox(height: 20),
                  // Display the image with a 40% size
                  Image.file(
                    File(_imagePath!),
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: MediaQuery.of(context).size.width * 0.4,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ElevatedButton(
              onPressed: () async {
                final imagePath = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TakePictureScreen(camera: widget.camera, setImagePath: _setImagePath),
                  ),
                );
                if (imagePath != null) {
                  _setImagePath(imagePath);
                  //imageUploader.uploadImage(imagePath);
                }
              },
              child: const Text('Take Picture'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
              bool success=  await _firebaseService.addData(_imagePath,, name, location, time);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data Uploaded')));
          
              },
              child: const Text('Upload to Cloud'),
            ),
          ],
        ),
      ),
    );
  }
}

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    super.key,
    required this.camera,
    required this.setImagePath,
  });

  final CameraDescription camera;
  final Function(String) setImagePath;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a picture')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await _initializeControllerFuture;
            final image = await _controller.takePicture();

            if (!context.mounted) return;

            // Show dialog to keep or cancel the picture
            final keepImage = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Keep Picture?'),
                  content: Image.file(File(image.path)),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        widget.setImagePath(image.path);
                        Navigator.of(context).pop(true);
                      },
                      child: const Text('Keep'),
                    ),
                  ],
                );
              },
            );

            if (keepImage == true) {
              Navigator.of(context).pop(image.path);
            } else {
              Navigator.of(context).pop();
            }
          } catch (e) {
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
