import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
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
      body: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Column(
          children: <Widget>[
            (imageUrl == null || imageUrl == "")
                ? Stack(
                    children: <Widget>[
                      Center(child: CircularProgressIndicator()),
                      Center(
                        child: FadeInImage.memoryNetwork(
                          placeholder: kTransparentImage,
                          image: 'https://picsum.photos/250?image=9',
                        ),
                      ),
                    ],
                  )
                : Stack(
                    children: <Widget>[
                      Center(child: CircularProgressIndicator()),
                      Center(child: Image.network(imageUrl)),
                    ],
                  ),
            SizedBox(
              height: 20.0,
            ),
            RaisedButton(
              child: Text('Upload Image'),
              color: Colors.brown,
              textColor: Colors.white,
              onPressed: () => uploadImage(),
            )
          ],
        ),
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
