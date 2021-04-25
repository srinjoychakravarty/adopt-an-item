// ignore: import_of_legacy_library_into_null_safe
import 'package:extended_image/extended_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login_app/src/screens/login.dart';

class ItemList extends StatefulWidget {
  ItemList({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _ItemListState createState() => _ItemListState();
}

class _ItemListState extends State<ItemList> {
  final auth = FirebaseAuth.instance;
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

  final dbRef = FirebaseDatabase.instance.reference().child("items");
  List<Map<dynamic, dynamic>> lists = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        body: FutureBuilder(
            future: dbRef.once(),
            builder: (context, AsyncSnapshot<DataSnapshot> snapshot) {
              if (snapshot.hasData) {
                lists.clear();
                Map<dynamic, dynamic> values = snapshot.data!.value;
                values.forEach((key, values) {
                  lists.add(values);
                });
                return new ListView.builder(
                    shrinkWrap: true,
                    itemCount: lists.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text("Name: " + lists[index]["name"]),
                            Text("Age: " + lists[index]["age"]),
                            Text("Type: " + lists[index]["type"]),
                            SizedBox(
                              height: 400,
                              child: GridView.count(
                                crossAxisCount: 2,
                                children: [
                                  ...lists[index]["images"].map(
                                    (i) => Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Material(
                                          shape: CircleBorder(),
                                          elevation: 2.0,
                                          child: Image.network(
                                            i != ""
                                                ? i
                                                : "https://en.wikipedia.org/wiki/No_symbol#/media/File:ProhibitionSign2.svg", //to use this for not present images
                                            fit: BoxFit.fitWidth,
                                            height: 100,
                                            width: 100,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    });
              }
              return CircularProgressIndicator(strokeWidth: 10);
            }));
  }

  _resizeImage(String firebaseImageURL) async {
    http.Response response = await http.get(Uri.parse(firebaseImageURL));
    var originalUnit8List = response.bodyBytes;
    ui.Image originalUiImage = await decodeImageFromList(originalUnit8List);
    ByteData? originalByteData = await originalUiImage.toByteData();
    print('original image ByteData size is ${originalByteData!.lengthInBytes}');
    var codec = await ui.instantiateImageCodec(originalUnit8List,
        targetHeight: 50, targetWidth: 50);
    var frameInfo = await codec.getNextFrame();
    ui.Image targetUiImage = frameInfo.image;
    ByteData? targetByteData =
        await targetUiImage.toByteData(format: ui.ImageByteFormat.png);
    print('target image ByteData size is ${targetByteData!.lengthInBytes}');
    var targetlUinit8List = targetByteData.buffer.asUint8List();
    return targetlUinit8List;
  }
}
