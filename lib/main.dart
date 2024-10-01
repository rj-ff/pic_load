import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  runApp(MyApp(camera: firstCamera));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  const MyApp({super.key, required this.camera});

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
  final CameraDescription camera;

  const HomeScreen({super.key, required this.camera});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                // Navigate to the camera screen to take a picture
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TakePictureScreen(camera: widget.camera),
                  ),
                );

                // If a picture was taken and returned, update the imagePath
                if (result != null) {
                  setState(() {
                    imagePath = result as String;
                  });
                }
              },
              child: const Text('Take Picture'),
            ),
            const SizedBox(height: 20),
            if (imagePath != null)
              Image.file(
                File(imagePath!),
                width: 300,
                height: 300,
                fit: BoxFit.cover,
              ),
          ],
        ),
      ),
    );
  }
}

// The camera screen where users can take a picture
class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen({super.key, required this.camera});

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  XFile? _capturedImage;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.medium);
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
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              alignment: Alignment.bottomCenter,
              children: [
                CameraPreview(_controller),
                if (_capturedImage == null)
                  FloatingActionButton(
                    onPressed: () async {
                      try {
                        await _initializeControllerFuture;
                        final image = await _controller.takePicture();
                        setState(() {
                          _capturedImage = image;
                        });
                      } catch (e) {
                        print(e);
                      }
                    },
                    child: const Icon(Icons.camera_alt),
                  )
                else
                  _buildImageReviewOverlay(context),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  // The overlay with two icons: Keep and Cancel after taking a picture
  Widget _buildImageReviewOverlay(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.file(
            File(_capturedImage!.path),
            fit: BoxFit.cover,
          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: IconButton(
              icon: const Icon(Icons.cancel, color: Colors.red, size: 50),
              onPressed: () {
                setState(() {
                  _capturedImage = null; // Cancel and retake
                });
              },
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: IconButton(
              icon: const Icon(Icons.check_circle, color: Colors.green, size: 50),
              onPressed: () {
                Navigator.of(context).pop(_capturedImage!.path); // Keep and return image path
              },
            ),
          ),
        ),
      ],
    );
  }
}
