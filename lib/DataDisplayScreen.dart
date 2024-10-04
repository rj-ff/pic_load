import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart' ;
import 'package:googleapis/securitycenter/v1.dart' as con;





class DataRowItem {
  
  final String img;
  
  final String uname;
  final String cname;
 
  final String uid;
  // final Geolocation location;
  // final Timestamp time;
  //  final int slab;

 

  DataRowItem({
    required this.uname,
    required this.cname,
    required this.img,
    // required this.location,
    // required this.slab,
    // required this.time,
    required this.uid

  });

  // Factory method to create a DataRowItem from Firestore document data
  factory DataRowItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return DataRowItem(
      uname: data['uname'] ?? 'No Field 1',
      cname: data['cname'] ?? 'No Field 2',
      uid: data['uid'] ?? 'No Field 3',
      img: data['img'] ?? '',
      // location: data['location'] ?? '',
      // slab: data['slab'] ?? 0,
      // time: data['time'] ?? '',


    );
  }
}
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to fetch all documents from the Firestore collection 'dataItems'
  Future<List<DataRowItem>> fetchAllData() async {
    List<DataRowItem> dataItems = [];

    try {
      // Query all documents in the collection
      QuerySnapshot querySnapshot = await _firestore.collection('dataItems').get();

      // Convert each document to a DataRowItem and add to the list
      for (var doc in querySnapshot.docs) {
        dataItems.add(DataRowItem.fromFirestore(doc));
      }
    } catch (e) {
      print('Error fetching data: $e');
    }

    return dataItems;
  }
}
class DataDisplayScreen extends StatelessWidget {
  // Function to fetch the image URL from Firebase Storage
  Future<String> getImageUrl(String imageName) async {
    try {
      // Access Firebase Storage and get the URL
      Reference ref = FirebaseStorage.instance.ref().child('images/$imageName');
      String imageUrl = await ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print('Error fetching image: $e');
      return ''; // Return empty string if an error occurs
    }
  }

  // Populate the list with default values and Firebase image URLs
  Future<List<DataRowItem>> fetchDataItems() async {
    List<DataRowItem> dataItems = [
      DataRowItem(uname: 'Default Field 1-1', cname: 'Default Field 1-2', uid: 'Default Field 1-3', img: 'https://firebasestorage.googleapis.com/v0/b/slab-e0d7d.appspot.com/o/images%2FCAP3205802377813231306.jpg?alt=media&token=0b24a3b8-f4ca-43af-b850-4fbd21d54eaf'),
      // DataRowItem(field1: 'Default Field 2-1', field2: 'Default Field 2-2', field3: 'Default Field 2-3', imageUrl: await getImageUrl('image2.png')),
      // DataRowItem(field1: 'Default Field 3-1', field2: 'Default Field 3-2', field3: 'Default Field 3-3', imageUrl: await getImageUrl('image3.png')),
    ];

    return dataItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Display Screen'),
      ),
      body: FutureBuilder<List<DataRowItem>>(
        future: fetchDataItems(), // Fetch data items asynchronously
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Show a loading indicator
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching data'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          } else {
            final dataItems = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.separated(
                itemCount: dataItems.length,
                itemBuilder: (context, index) {
                  final item = dataItems[index];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon on the left or image with error handling
                      Image.network(
                        item.img,
                        height: 40,
                        width: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 40,
                            width: 40,
                            color: Colors.grey, // Placeholder color
                            child: Icon(Icons.error, color: Colors.red), // Error icon
                          );
                        },
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
                  color: Colors.grey, // Change divider color if needed
                  thickness: 1, // Adjust thickness of the divider
                  indent: 8, // Optional: Indent the divider to align with the text
                  endIndent: 8, // Optional: Add padding on the right side of the divider
                ),
              ),
            );
          }
        },
      ),
    );
  }
}


// import 'package:flutter/material.dart';

// class DataDisplayScreen extends StatefulWidget {
//   @override
//   _DataDisplayScreenState createState() => _DataDisplayScreenState();
// }

// class _DataDisplayScreenState extends State<DataDisplayScreen> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

//   // Sample data to display
//   final List<Map<String, String>> data = [
//     {
//       'title': 'Title 1',
//       'subtitle1': 'Subtitle 1.1',
//       'subtitle2': 'Subtitle 1.2',
//       'image': 'assets/image1.png', // Placeholder for image path
//     },
//     {
//       'title': 'Title 2',
//       'subtitle1': 'Subtitle 2.1',
//       'subtitle2': 'Subtitle 2.2',
//       'image': 'assets/image2.png', // Placeholder for image path
//     },
//   ];

//   String? dropdownValue1;
//   String? dropdownValue2;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _scaffoldKey,
//       appBar: AppBar(
//         title: Text('Data Display Screen'),
//         leading: IconButton(
//           icon: Icon(Icons.menu),
//           onPressed: () {
//             _scaffoldKey.currentState?.openDrawer();
//           },
//         ),
//       ),
//       drawer: Drawer(
//         child: Column(
//           children: [
//             DrawerHeader(
//               decoration: BoxDecoration(
//                 color: Colors.blue,
//               ),
//               child: Text('Select Options'), // Kept simple label here
//             ),
//             // Dropdown for selection 1
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: DropdownButton<String>(
//                 isExpanded: true,
//                 hint: Text('Select Option 1'),
//                 value: dropdownValue1,
//                 onChanged: (String? newValue) {
//                   setState(() {
//                     dropdownValue1 = newValue;
//                   });
//                 },
//                 items: <String>['Option 1', 'Option 2', 'Option 3']
//                     .map<DropdownMenuItem<String>>((String value) {
//                   return DropdownMenuItem<String>(
//                     value: value,
//                     child: Text(value),
//                   );
//                 }).toList(),
//               ),
//             ),
//             // Dropdown for selection 2
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: DropdownButton<String>(
//                 isExpanded: true,
//                 hint: Text('Select Option 2'),
//                 value: dropdownValue2,
//                 onChanged: (String? newValue) {
//                   setState(() {
//                     dropdownValue2 = newValue;
//                   });
//                 },
//                 items: <String>['Option A', 'Option B', 'Option C']
//                     .map<DropdownMenuItem<String>>((String value) {
//                   return DropdownMenuItem<String>(
//                     value: value,
//                     child: Text(value),
//                   );
//                 }).toList(),
//               ),
//             ),
//             // OK Button
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.of(context).pop(); // Closes the drawer
//                   // Store or print dropdown values here
//                   print('Selected: $dropdownValue1 and $dropdownValue2');
//                 },
//                 child: Text('OK'),
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: data.isEmpty
//           ? Center(child: Text('No data available.'))
//           : ListView.builder(
//               itemCount: data.length,
//               itemBuilder: (context, index) {
//                 return Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Row(
//                     children: [
//                       // Icon on the left side
//                       Container(
//                         width: 50, // Adjust width as per the design
//                         height: 70, // Height matches the total height of 3 text rows
//                         child: Image.asset(
//                           data[index]['image']!, // Placeholder for actual image
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                       SizedBox(width: 10), // Space between icon and text
//                       // Nested rows of text
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               data[index]['title']!, // First text
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 16,
//                               ),
//                             ),
//                             Text(data[index]['subtitle1']!), // Second text
//                             Text(data[index]['subtitle2']!), // Third text
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }
