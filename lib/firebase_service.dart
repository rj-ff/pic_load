import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
 

  final String collectionName='0';


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

  
  Future<void> addData(int id, String name, GeoPoint location, Timestamp time) async {
    try {
      CollectionReference collection = FirebaseFirestore.instance.collection(collectionName);

      // Adding document to Firestore
      await collection.add({
        'id': id,
        'name': name,
        'location': location,
        'time': time,
      });

      print('Data added to Firestore!');
    } catch (e) {
      print('Error adding data: $e');
    }
  }
}
