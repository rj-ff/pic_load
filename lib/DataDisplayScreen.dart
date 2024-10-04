import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DataRowItem {
  final String img;
  final String uname;
  final String cname;
  final String uid;

  DataRowItem({
    required this.uname,
    required this.cname,
    required this.img,
    required this.uid,
  });
}

class DataDisplayScreen extends StatefulWidget {
  @override
  DataDisplayScreenState createState() => DataDisplayScreenState();
}

class DataDisplayScreenState extends State<DataDisplayScreen> {
  List<DataRowItem> dataItems = [];

  @override
  void initState() {
    super.initState();
    fetchDataFromFirestore();
  }

  Future<void> fetchDataFromFirestore() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('0').get();
      final data = snapshot.docs.map((doc) {
        final docData = doc.data();

        return DataRowItem(
          uname: docData.containsKey('uname') ? docData['uname'] as String : 'Default Name',
          cname: docData.containsKey('cname') ? docData['cname'] as String : 'Default Company',
          img: docData.containsKey('img') ? docData['img'] as String : 'default_image_url',
          uid: docData.containsKey('uid') ? docData['uid'] as String : 'Default UID',
        );
      }).toList();

      setState(() {
        dataItems = data;
      });
    } catch (e) {
      print('Error fetching data from Firestore: $e');
    }
  }

  // Fetch data from Firestore and map to DataRowItem
  // Future<void> fetchDataFromFirestore() async {
  //   try {
  //     QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('0').get();

  //     // Process documents and map to dataItems list
  //     List<DataRowItem> tempItems = querySnapshot.docs.map((doc) {
  //       return DataRowItem(
  //        uname: docData.containsKey('uname') ? docData['uname'] as String : 'Default Name',
  //         cname: docData.containsKey('cname') ? docData['cname'] as String : 'Default Company',
  //         img: docData.containsKey('img') ? docData['img'] as String : 'default_image_url',
  //         uid: docData.containsKey('uid') ? docData['uid'] as String : 'Default UID',
  //       );
  //     }).toList();

  //     // Update the state to display fetched data
  //     setState(() {
  //       dataItems = tempItems;
  //     });
  //   } catch (e) {
  //     print('Error fetching data from Firestore: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Display Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: dataItems.isEmpty
            ? Center(child: CircularProgressIndicator()) // Loading indicator if data is being fetched
            : ListView.separated(
                itemCount: dataItems.length,
                itemBuilder: (context, index) {
                  final item = dataItems[index];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fetch image from Firebase using URL
                      Image.network(
                        item.img,
                        height: 40,
                        width: 40,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(width: 8), // Space between icon and text

                      // Text fields on the right
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.uname,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              item.cname,
                              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                            ),
                            Text(
                              item.uid,
                              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
                separatorBuilder: (context, index) => Divider(
                  color: Colors.grey,
                  thickness: 1,
                  indent: 8,
                  endIndent: 8,
                ),
              ),
      ),
    );
  }
}
