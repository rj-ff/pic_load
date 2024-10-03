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
   Map<String, dynamic> prepareData(int slab, String uid, String uname, String cname,GeoPoint location, Timestamp time, String imagepath) {
  return {
    'uid': uid,
    'uname': uname,
    'cname': cname,
    'slab' : slab,
    'location': location,
    'time': time,
    'img' : imagepath,
  };
}

  
  Future<bool> addData(String? localimagePath, int slab, String uid, String uname, String cname,GeoPoint location, Timestamp time) async {
    try {
     // Strimg imagePath ='';
      CollectionReference collection = FirebaseFirestore.instance.collection(collectionName);
      String imagepath = await imageUploader.uploadImage(localimagePath ?? ''); //if imagepath is null returns empty
      if(imagepath == '') return false;

      // Adding document to Firestore
      await collection.add({
       'uid': uid,
    'uname': uname,
    'cname': cname,
    'slab' : slab,
    'location': location,
    'time': time,
    'img' : imagepath,
      });

      print('Data added to Firestore!');
      return true;
    } catch (e) {
      print('Error adding data: $e');
      return false;
    }
  }
}
