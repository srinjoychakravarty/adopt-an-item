import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  final auth = FirebaseAuth.instance;
  String imageUrl = "";

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Garage Item')),
      body: Column(
        children: <Widget>[
          (imageUrl != null || imageUrl != "")
              ? Image.network(imageUrl)
              : Placeholder(
                  fallbackHeight: 200.0,
                  fallbackWidth: double.infinity,
                ),
          SizedBox(
            height: 20.0,
          ),
          RaisedButton(
            child: Text('Upload Image'),
            color: Colors.brown,
            onPressed: () => uploadImage(),
          )
        ],
      ),
    );
  }

  Future uploadImage() async {
    final _storage = FirebaseStorage.instance;
    final _picker = ImagePicker();
    PickedFile image;

    // Check Permissions
    await Permission.photos.request();

    var permissionStatus = await Permission.photos.status;

    if (permissionStatus.isGranted) {
      // Select Image
      image = (await _picker.getImage(source: ImageSource.gallery))!;
      var file = File(image.path);

      // ignore: unnecessary_null_comparison
      if (image != null) {
        // Upload to Firebase
        var snapshot = await _storage.ref().child('srinjoy/item').putFile(file);

        var downloadUrl = await snapshot.ref.getDownloadURL();
        print(downloadUrl);

        setState(() {
          imageUrl = downloadUrl;
        });
      } else {
        print('Error: No image path detected!');
      }
    } else {
      print('Error: Gallery permission not granted!');
    }
  }
}
