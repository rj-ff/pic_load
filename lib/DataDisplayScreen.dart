import 'package:flutter/material.dart';

class DataDisplayScreen extends StatefulWidget {
  @override
  _DataDisplayScreenState createState() => _DataDisplayScreenState();
}

class _DataDisplayScreenState extends State<DataDisplayScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Sample data to display
  final List<Map<String, String>> data = [
    {
      'title': 'Title 1',
      'subtitle1': 'Subtitle 1.1',
      'subtitle2': 'Subtitle 1.2',
      'image': 'assets/image1.png', // Placeholder for image path
    },
    {
      'title': 'Title 2',
      'subtitle1': 'Subtitle 2.1',
      'subtitle2': 'Subtitle 2.2',
      'image': 'assets/image2.png', // Placeholder for image path
    },
  ];

  String? dropdownValue1;
  String? dropdownValue2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Data Display Screen'),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Select Options'), // Kept simple label here
            ),
            // Dropdown for selection 1
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton<String>(
                isExpanded: true,
                hint: Text('Select Option 1'),
                value: dropdownValue1,
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownValue1 = newValue;
                  });
                },
                items: <String>['Option 1', 'Option 2', 'Option 3']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            // Dropdown for selection 2
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton<String>(
                isExpanded: true,
                hint: Text('Select Option 2'),
                value: dropdownValue2,
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownValue2 = newValue;
                  });
                },
                items: <String>['Option A', 'Option B', 'Option C']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            // OK Button
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Closes the drawer
                  // Store or print dropdown values here
                  print('Selected: $dropdownValue1 and $dropdownValue2');
                },
                child: Text('OK'),
              ),
            ),
          ],
        ),
      ),
      body: data.isEmpty
          ? Center(child: Text('No data available.'))
          : ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      // Icon on the left side
                      Container(
                        width: 50, // Adjust width as per the design
                        height: 70, // Height matches the total height of 3 text rows
                        child: Image.asset(
                          data[index]['image']!, // Placeholder for actual image
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 10), // Space between icon and text
                      // Nested rows of text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data[index]['title']!, // First text
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(data[index]['subtitle1']!), // Second text
                            Text(data[index]['subtitle2']!), // Third text
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
