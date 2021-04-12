import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:login_app/src/screens/itemlist.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_database/firebase_database.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);
  final String title = 'Register Item';
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  final auth = FirebaseAuth.instance;
  String imageUrl = "";

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text(widget.title)),
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
            ),
            SizedBox(
              height: 20.0,
            ),
            Text("Put an Item up for Adoption",
                style: TextStyle(
                    fontWeight: FontWeight.w200,
                    fontSize: 30,
                    fontFamily: 'Roboto',
                    fontStyle: FontStyle.italic)),
            RegisterItem(firebaseStorageURL: imageUrl),
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
        var snapshot =
            await _storage.ref().child(getRandomString(15)).putFile(file);

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

  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
}

class RegisterItem extends StatefulWidget {
  final String firebaseStorageURL;
  RegisterItem({Key? key, required this.firebaseStorageURL}) : super(key: key);

  @override
  _RegisterItemState createState() => _RegisterItemState();
}

class _RegisterItemState extends State<RegisterItem> {
  String imageUrl = "";
  final _formKey = GlobalKey<FormState>();
  final listOfPets = ["Clothing", "Food", "Electronics"];
  String dropdownValue = 'Clothing';
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final dbRef = FirebaseDatabase.instance.reference().child("items");

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Flexible(
            child: SingleChildScrollView(
                child: Column(children: <Widget>[
          Padding(
            padding: EdgeInsets.all(20.0),
            child: TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Enter Item Name",
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Item Name is required!';
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: DropdownButtonFormField(
              value: dropdownValue,
              icon: Icon(Icons.arrow_downward),
              decoration: InputDecoration(
                labelText: "Select Item Category",
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              items: listOfPets.map((String value) {
                return new DropdownMenuItem<String>(
                  value: value,
                  child: new Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  dropdownValue = newValue.toString();
                });
              },
              validator: (value) {
                if (value == 'null') {
                  return 'Item must belong to a valid category!';
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: TextFormField(
              keyboardType: TextInputType.number,
              controller: ageController,
              decoration: InputDecoration(
                labelText: "Enter Item Age (months)",
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Item age is required!';
                }
                return null;
              },
            ),
          ),
          Padding(
              padding: EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        dbRef.push().set({
                          "name": nameController.text,
                          "age": ageController.text,
                          "type": dropdownValue,
                          "image": widget.firebaseStorageURL,
                        }).then((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Successfully Added')));
                          ageController.clear();
                          nameController.clear();
                        }).catchError((onError) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(onError)));
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        primary: Colors.lime,
                        onPrimary: Colors.black,
                        textStyle: TextStyle(
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                        )),
                    child: Text('Put Item up for Adoption'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ItemList(title: "Item List")),
                      );
                    },
                    child: Text('Adopt an Item'),
                  ),
                ],
              )),
        ]))));
  }
}
