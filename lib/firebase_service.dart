import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pic_load/firebase_image_upload.dart';
class FirebaseService {
 

  final String collectionName='0';
  final ImageUploader imageUploader = ImageUploader();


  FirebaseService() {
    
    // Initialize Firebase when the class is created
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp();
  }
   Map<String, dynamic> prepareData(int id, String name, GeoPoint location, Timestamp time) {
  return {
    'id': id,
    'name': name,
    'location': location,
    'time': time,
  };
}

  
  Future<bool> addData(String? imagePath,int id, String name, GeoPoint location, Timestamp time) async {
    try {
     // Strimg imagePath ='';
      CollectionReference collection = FirebaseFirestore.instance.collection(collectionName);
      String path = await imageUploader.uploadImage(imagePath ?? ''); //if imagepath is null returns empty
      if(path == '') return false;

      // Adding document to Firestore
      await collection.add({
        'id': id,
        'name': name,
        'location': location,
        'time': time,
      });

      print('Data added to Firestore!');
      return true;
    } catch (e) {
      print('Error adding data: $e');
      return false;
    }
  }
}
