import 'dart:io';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
//import 'package:googleapis_auth/auth_io.dart';

class GoogleDriveService {
  final String folderID = "18B86folBnlGvnLWHXKbbzDQ7p2u_MATB"; // Replace with your folder ID
  final GoogleSignIn _googleSignIn = GoogleSignIn.standard(
    scopes: [drive.DriveApi.driveFileScope],
  );

  GoogleSignInAccount? _currentUser;

  Future<void> signIn() async {
    try {
      _currentUser = await _googleSignIn.signIn();
    } catch (error) {
      print("Error during sign in: $error");
    }
  }

  bool isUserSignedIn() {
    return _currentUser != null;
  }

  Future<void> uploadFile(String filePath) async {
    if (_currentUser == null) {
      throw Exception("User not signed in");
    }

    File fileToUpload = File(filePath);
    if (!await fileToUpload.exists()) {
      throw Exception("File does not exist: $filePath");
    }

    var driveFile = drive.File();
    driveFile.name = fileToUpload.path.split('/').last;
    driveFile.parents = [folderID]; // Set parent folder ID

    // Get authentication headers
    final authHeaders = await _currentUser!.authHeaders;

    // Create an authenticated HTTP client using auth headers
    final authenticateClient = GoogleAuthClient(authHeaders);

    // Instantiate the Google Drive API with the authenticated client
    var driveApi = drive.DriveApi(authenticateClient);

    try {
      // Set the correct MIME type for the file being uploaded
      String mimeType = "application/octet-stream"; // Adjust this as needed
      var media = drive.Media(fileToUpload.openRead(), fileToUpload.lengthSync(), contentType: mimeType);

      // Upload the file
      var response = await driveApi.files.create(driveFile, uploadMedia: media);
      print('Uploaded file ID: ${response.id}');
    } catch (error) {
      print("Error during file upload: $error");
    } finally {
      // Close the authenticated client
      authenticateClient.close();
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null; // Clear the current user
  }
}

// Helper class to add Google auth headers to an HTTP client
class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}


 // Future<void> uploadFile() async {
  //   if (_currentUser == null) return;

  //   // Get authentication headers
  //   final authHeaders = await _currentUser!.authHeaders;

  //   // Create an authenticated HTTP client using auth headers
  //   final authenticateClient = GoogleAuthClient(authHeaders);

  //   // Instantiate the Google Drive API with the authenticated client
  //   var driveApi = drive.DriveApi(authenticateClient);

  //   // Create metadata for the file
  //   var fileToUpload = drive.File();
  //   fileToUpload.name = "example.txt";

  //   // Provide the shared folder's ID where the files will be uploaded
  //   fileToUpload.parents = [folderID];

  //   // Dummy file data, replace this with actual file data
  //   var media = drive.Media(
  //     Stream.fromIterable([List<int>.generate(100, (index) => index)]), 
  //     100,
  //   );

  //   // Upload the file
  //   var response = await driveApi.files.create(fileToUpload, uploadMedia: media);
  //   print('Uploaded file ID: ${response.id}');

  //   // Close the authenticated client (optional, depending on your needs)
  //   authenticateClient.close();
  // }

 