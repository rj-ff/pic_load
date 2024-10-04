import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
  _DataDisplayScreenState createState() => _DataDisplayScreenState();
}

class _DataDisplayScreenState extends State<DataDisplayScreen> {
  List<DataRowItem> dataItems = [];
  bool isLoading = true;

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

      // Load all images before setting state to avoid individual loading indicators
      await Future.wait(data.map((item) => precacheImage(NetworkImage(item.img), context)));

      setState(() {
        dataItems = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching data from Firestore: $e');
    }
  }

  void _showImagePreview(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: InteractiveViewer(
          panEnabled: true, // Allows panning
          minScale: 0.5, // Minimum zoom scale
          maxScale: 4.0, // Maximum zoom scale
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            errorWidget: (context, url, error) => Icon(Icons.error), // Error icon if loading fails
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Display Screen'),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(), // Single loading indicator for all images
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.separated(
                itemCount: dataItems.length,
                itemBuilder: (context, index) {
                  final item = dataItems[index];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image with tap to preview using CachedNetworkImage
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          _showImagePreview(context, item.img);
                        },
                        child: CachedNetworkImage(
                          
                          imageUrl: item.img,
                          height: 40,
                          width: 40,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Icon(Icons.error), // Error icon
                        ),
                      ),
                      ),
                      SizedBox(width: 8), // Space between image and text

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
                  color: Colors.grey, // Divider color
                  thickness: 1, // Divider thickness
                  indent: 8, // Optional left padding for the divider
                  endIndent: 8, // Optional right padding for the divider
                ),
              ),
            ),
    );
  }
}
