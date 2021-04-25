import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as Path;
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:login_app/src/screens/itemlist.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_database/firebase_database.dart';
import 'dart:math';
// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'dart:io' as io;
import 'dart:async';

import 'package:login_app/src/screens/login.dart';

class HomeScreen extends StatefulWidget {
  // final auth = FirebaseAuth.instance;
  HomeScreen({Key? key}) : super(key: key);
  final String title = 'Register Item';
  // final LoginScreen loginScreen = LoginScreen();

  // final _LoginScreenState _loginScreenState = _LoginScreenState();

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  final _picker = ImagePicker();
  final auth = FirebaseAuth.instance;
  String imageUrl = "";
  List<String> imageUrls = [];

  late final File _image;

  final ImageLabeler _imageLabeler = FirebaseVision.instance.imageLabeler();
  var result;

  bool uploading = false;
  double val = 0;

  late CollectionReference imgRef;
  late firebase_storage.Reference ref;
  List<File> _imageFileList = [];

//Multi Image Upload
  Future<void> _uploadMoreImageDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('AlertDialog Title'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Image Selection Error'),
                Text('Please select more than 1 image to upload'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Approve'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
//End

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0.0,
        actions: <Widget>[
          FlatButton.icon(
            icon: Icon(Icons.person),
            label: Text('Log Out'),
            onPressed: () async {
              await logout();
            },
          )
        ],
      ),
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
            new Expanded(
                child: Stack(
              children: [
                GridView.builder(
                    itemCount: _imageFileList.length + 1,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3),
                    itemBuilder: (context, index) {
                      return index == 0
                          ? Center(
                              child: IconButton(
                                icon: Icon(Icons.camera),
                                onPressed: () {
                                  !uploading
                                      ? addSourceImage() //chooseImage()//commented CS code
                                      // ignore: unnecessary_statements
                                      : null; // disable upload button when images in process of uploading
                                },
                              ),
                            )
                          : Container(
                              margin: EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image:
                                          FileImage(_imageFileList[index - 1]),
                                      fit: BoxFit.cover)),
                            );
                    }),
                uploading
                    ? Center(
                        child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          CircularProgressIndicator(
                            value: val,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.green),
                          )
                        ],
                      ))
                    : Container(),
              ],
            )),
            new TextButton(
                onPressed: () {
                  if (_imageFileList.length > 1) {
                    setState(() {
                      uploading =
                          true; // update state boolean variable uploading to true
                    });
                    uploadFile();
                    //to pop out the indicator once work is ---Resume Point
                    // uploadFile().whenComplete(() => Navigator.of(context)
                    //     .pushReplacement(MaterialPageRoute(
                    //         builder: (context) => HomeScreen())));
                  } else {
                    _uploadMoreImageDialog();
                  }
                },
                child: new Text('Upload Images')),
            SizedBox(
              height: 20.0,
            ),
            Container(
              child: Center(
                child: result == null
                    ? null
                    : Text(
                        result,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            // SizedBox(
            //   height: 10.0,
            // ),
            // FloatingActionButton(
            //   onPressed: () => getImage(),
            //   tooltip: 'Pick an item image...',
            //   child: Icon(Icons.add_a_photo),
            //   backgroundColor: Colors.brown,
            //   foregroundColor: Colors.white,
            // ), //htmodification
            // ElevatedButton(
            //   child: Text('Upload Image'),
            //   style: ButtonStyle(
            //       backgroundColor:
            //           MaterialStateProperty.all<Color>(Colors.grey.shade700)),
            //   onPressed: () => uploadImage(),
            // ),
            // SizedBox(
            //   height: 20.0,
            // ),
            Text("Put an Item up for Adoption",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    fontFamily: 'Roboto',
                    fontStyle: FontStyle.italic)),
            RegisterItem(firebaseStorageURLArray: imageUrls), //summon url
          ],
        ),
      ),
    );
  }

  Future logout() async {
    try {
      await auth.signOut();
      // Navigator.of(context).pop();
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()));
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

  chooseImage() async {
    // final _picker = ImagePicker();
    final pickedFile = (await _picker.getImage(source: ImageSource.gallery))!;
    setState(() {
      _imageFileList.add(File(pickedFile.path));
    });
    if (pickedFile.path == null) retrieveLostData();
  }

  Future multiImageUploader(selectedSource) async {
    final pickedFile = (await _picker.getImage(source: selectedSource))!;
    setState(() {
      _imageFileList.add(File(pickedFile.path));
    });
    // ignore: unnecessary_null_comparison
    if (pickedFile.path == null) {
      retrieveLostData();
    } else {
      print("-----------------------ML------------------");
      _image = File(pickedFile.path);
      processImageLabels();
    }
  }

  addSourceImage() async {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => ListView(children: [
        ListTile(
          leading: Icon(Icons.camera_alt),
          title: Text('Camera'),
          onTap: () {
            Navigator.pop(context);
            multiImageUploader(ImageSource.camera);
          },
        ),
        ListTile(
          leading: Icon(Icons.photo_album),
          title: Text('Gallery'),
          onTap: () {
            Navigator.pop(context);
            multiImageUploader(ImageSource.gallery);
          },
        ), //here
      ]),
    );
  }

  Future<void> retrieveLostData() async {
    final LostData response = await _picker.getLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _imageFileList.add(File(response.file!.path));
      });
    } else {
      print(response.file);
    }
  }

  Future uploadFile() async {
    await Permission.photos.request();
    //summon
    int i = 1; //initialized counter of progress bar to 1st image

    for (var img in _imageFileList) {
      // iterate through the _imageFileList array of images picked
      setState(() {
        val = i /
            _imageFileList
                .length; // set progress state of circular to fraction of total images uploaded
      });
      ref = firebase_storage.FirebaseStorage
          .instance // create a reference on FirebaseStorage (cloud) for each image from _imageFileList
          .ref()
          .child('images/${Path.basename(img.path)}');
      await ref.putFile(img).whenComplete(() async {
        await ref.getDownloadURL().then((value) {
          imgRef.add({'url': value});
          imageUrls.add(value);
          i++; // after each image upload success to firestore increment state of circular progress bar
        });
      });
    }
    print(imageUrls);
  }

  @override
  void initState() {
    super.initState();
    imgRef = FirebaseFirestore.instance.collection('imageURLs');
  }

  Future getImage() async {
    // final _picker = ImagePicker();
    final pickedFile = (await _picker.getImage(source: ImageSource.gallery))!;
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        processImageLabels();
      } else {
        print('No image selected...');
      }
    });
  }

  processImageLabels() async {
    FirebaseVisionImage myImage = FirebaseVisionImage.fromFile(_image);
    ImageLabeler labeler = FirebaseVision.instance.imageLabeler();
    var _imageLabels = await labeler.processImage(myImage);
    result = "";
    for (ImageLabel imageLabel in _imageLabels) {
      setState(() {
        result = result +
            imageLabel.text +
            ":" +
            imageLabel.confidence.toString() +
            "\n";
      });
    }
  }

  Future uploadImage() async {
    final _storage = FirebaseStorage.instance;
    final _picker = ImagePicker();

    PickedFile image;

    // Check Permissions
    await Permission.photos.request();
    // await Permission.camera.request();
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
  // final String firebaseStorageURL;
  List<String> firebaseStorageURLArray = [];
  RegisterItem({Key? key, required this.firebaseStorageURLArray})
      : super(key: key);

  @override
  _RegisterItemState createState() => _RegisterItemState();
}

class _RegisterItemState extends State<RegisterItem> {
  String imageUrl = "";
  List<String> imageUrls = [];
  final _formKey = GlobalKey<FormState>();
  final listOfPets = ["Clothing", "Food", "Electronics"];
  String dropdownValue = 'Electronics';
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
                          "images": widget.firebaseStorageURLArray,
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
                        onPrimary: Colors.grey.shade700,
                        textStyle: TextStyle(
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                        )),
                    child: Text('List Item'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ItemList(title: "Item List")),
                      );
                    },
                    child: Text(
                      'Available Items',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              )),
        ]))));
  }
}
