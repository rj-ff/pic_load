import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  FirebaseService() {
    // Initialize Firebase when the class is created
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp();
  }

  Future<void> addData(int id, String name, GeoPoint location, Timestamp time) async {
    try {
      CollectionReference collection = FirebaseFirestore.instance.collection('your_collection_name');

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
