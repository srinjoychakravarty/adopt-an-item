import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as Path;
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart'; //remove later
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:login_app/src/screens/itemlist.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_database/firebase_database.dart';
import 'dart:math';
// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
// import 'dart:io' as io; //remove later
import 'dart:async';
import 'package:login_app/src/screens/login.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);
  final String title = '📝 Register Item';
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  final _picker = ImagePicker();
  // ignore: unused_field
  final _multiPicker = MultiImagePicker();
  final auth = FirebaseAuth.instance;
  String imageUrl = "";
  List<String> imageUrls = [];

  // late final File _image;
  late File _image;

  // ignore: unused_field
  final ImageLabeler _imageLabeler =
      FirebaseVision.instance.imageLabeler(); //remove later
  var result;

  bool uploading = false;
  double val = 0;

  late CollectionReference imgRef;
  late firebase_storage.Reference ref;
  List<File> _imageFileList = [];

  Future<void> _cannotUploadMoreImageDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Max Selection Error'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Please proceed with the image upload process.'),
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

  Future<void> _uploadMoreImageDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Image Selection Error'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Please select upto 4 images.'),
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

  Future logout() async {
    try {
      await auth.signOut();
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()));
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0.0,
        actions: <Widget>[
          TextButton.icon(
            icon: Icon(
              Icons.logout_rounded,
              color: Colors.white,
            ),
            label: Text('Log Out', style: TextStyle(color: Colors.white)),
            onPressed: () async {
              await logout();
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text("Put an Item up for Adoption",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 42,
                    fontFamily: 'Roboto',
                    fontStyle: FontStyle.italic,
                    color: Colors.teal.shade900)),
            new SizedBox(
              width: 400,
              height: 90,
              // flex: 1,
              // fit: FlexFit.loose,
              child: Stack(
                children: [
                  Container(
                      height: 0,
                      alignment: Alignment.center,
                      margin: EdgeInsets.all(3),
                      padding: EdgeInsets.all(6)),
                  GridView.builder(
                      itemCount: _imageFileList.length + 1,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5),
                      itemBuilder: (context, index) {
                        return index == 0
                            ? Center(
                                child: IconButton(
                                  icon: Icon(Icons.photo_library_outlined),
                                  color: Colors.teal,
                                  focusColor: Colors.green,
                                  hoverColor: Colors.blue,
                                  highlightColor: Colors.grey,
                                  iconSize: 50,
                                  tooltip: "Add Images",
                                  alignment: Alignment.center,
                                  onPressed: () {
                                    !uploading && _imageFileList.length < 4
                                        ? addSourceImage()
                                        : _cannotUploadMoreImageDialog();
                                  },
                                ),
                              )
                            : Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.all(3),
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: FileImage(
                                            _imageFileList[index - 1]),
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
                                  AlwaysStoppedAnimation<Color>(Colors.teal),
                            )
                          ],
                        ))
                      : Container(),
                ],
              ),
            ),
            new ElevatedButton.icon(
                onPressed: () {
                  if (_imageFileList.length > 0) {
                    setState(() {
                      uploading =
                          true; // update state boolean variable uploading to true
                    });
                    uploadFile();
                  } else {
                    print(_imageFileList.length);
                    _uploadMoreImageDialog();
                  }
                },
                icon: Icon(
                  Icons.upload_rounded,
                  color: Colors.white, //white or black
                ),
                label: Text(
                  'Upload Images',
                  style: TextStyle(color: Colors.white),
                )), //white or black

            SizedBox(
              height: 300,
              child: Center(
                child: result == null
                    ? Text("Nothing here...")
                    : Text(
                        result,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            RegisterItem(firebaseStorageURLArray: imageUrls), //summon url
          ],
        ),
      ),
    );
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
      _image = File(pickedFile.path);
      processImageLabels();
    }
  }

  addSourceImage() async {
    // final _picker = ImagePicker();
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
        ),
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
    int i = 1; //initialized counter of progress bar to 1st image

    for (var img in _imageFileList) {
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
    setState(() {
      val =
          0; // set progress state of circular to fraction of total images uploaded
    });
    print(imageUrls);
  }

  @override
  void initState() {
    super.initState();
    imgRef = FirebaseFirestore.instance.collection('imageURLs');
  }

  Future getImage() async {
    final pickedFile = (await _picker.getImage(source: ImageSource.gallery))!;
    setState(() {
      // ignore: unnecessary_null_comparison
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
    result = "ML vision suggests the selected image is : \n \n";
    for (ImageLabel imageLabel in _imageLabels) {
      setState(() {
        result = result +
            imageLabel.text +
            " : " +
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

// ignore: must_be_immutable
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
  final _formKey = GlobalKey<FormState>();
  final listOfPets = ["Clothing", "Food", "Electronics"];
  String dropdownValue = 'Clothing';
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final dbRef = FirebaseDatabase.instance.reference().child("items");
  Future<void> _uploadMoreImageDialog() async {
    return showDialog<void>(
      context: context, // summon kurama
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Image Selection Error'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Please select more than 1 image and upload before listing your item.'),
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

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Flexible(
            child: SingleChildScrollView(
                child: Column(children: <Widget>[
          Padding(
            padding: EdgeInsets.all(5.0),
            child: TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Enter Item Name",
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
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
            padding: EdgeInsets.all(5.0),
            child: DropdownButtonFormField(
              value: dropdownValue,
              icon: Icon(Icons.arrow_downward),
              decoration: InputDecoration(
                labelText: "Select Item Category",
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
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
            padding: EdgeInsets.all(5.0),
            child: TextFormField(
              keyboardType: TextInputType.number,
              controller: ageController,
              decoration: InputDecoration(
                labelText: "Enter Item Age (months)",
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
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
              padding: EdgeInsets.all(5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (widget.firebaseStorageURLArray != []) {
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
                        } else {
                          print(widget.firebaseStorageURLArray);
                          _uploadMoreImageDialog();
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        primary: Colors.teal,
                        onPrimary: Colors.grey.shade900,
                        textStyle: TextStyle(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                        )),
                    child: Text(
                      '📲 List Item',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ItemList(title: "📱 Item List")),
                      );
                    },
                    child: Text(
                      '🔍 Available Items',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              )),
        ]))));
  }
}
