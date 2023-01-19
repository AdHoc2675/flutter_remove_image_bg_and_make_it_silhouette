import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:remove_bg_example/api_client.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RemoveBackground(),
    ),
  );
}

class RemoveBackground extends StatefulWidget {
  @override
  _RemoveBackgroundState createState() => new _RemoveBackgroundState();
}

class _RemoveBackgroundState extends State<RemoveBackground> {
  Uint8List? imageAsUint8List;

  String? imagePathAsString;

  ScreenshotController controller = ScreenshotController();

  double _currentImageOpacity = 0.5;

  bool isSilhouetteModeOn = false;

  @override
  void initState() {
    super.initState();
    isSilhouetteModeOn = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remove Bg'),
        actions: [
          IconButton(
              onPressed: () {
                getImage(ImageSource.gallery);
              },
              icon: const Icon(Icons.image)),
          IconButton(
              onPressed: () {
                getImage(ImageSource.camera);
              },
              icon: const Icon(Icons.camera_alt)),
          IconButton(
              onPressed: () async {
                imageAsUint8List =
                    await ApiClient().removeBgApi(imagePathAsString!);
                setState(() {});
              },
              icon: const Icon(Icons.delete)),
          IconButton(
              onPressed: () async {
                saveImage();
              },
              icon: const Icon(Icons.save))
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            (imageAsUint8List != null)
                ? isSilhouetteModeOn
                    ? Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.width,
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                  Colors.black
                                      .withOpacity(_currentImageOpacity),
                                  BlendMode.srcIn),
                              image: MemoryImage(imageAsUint8List!),
                            ),
                          ),
                        ),
                      )
                    : Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.width,
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                  Colors.black
                                      .withOpacity(_currentImageOpacity),
                                  BlendMode.dstATop),
                              image: MemoryImage(imageAsUint8List!),
                            ),
                          ),
                        ),
                      )
                : Container(
                    width: 300,
                    height: 300,
                    color: Colors.grey[300]!,
                    child: const Icon(
                      Icons.image,
                      size: 100,
                    ),
                  ),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _currentImageOpacity,
                    min: 0,
                    max: 1,
                    activeColor: Colors.white,
                    inactiveColor: Colors.white30,
                    onChanged: (value) async {
                      setState(() {
                        _currentImageOpacity = value;
                      });
                    },
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _currentImageOpacity.toStringAsFixed(1) + 'x',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (() {
          setState(() {
            isSilhouetteModeOn = !isSilhouetteModeOn;
          });
        }),
        child: isSilhouetteModeOn
            ? Icon(Icons.edit_sharp)
            : Icon(Icons.edit_off_sharp),
      ),
    );
  }

  void getImage(ImageSource imageSource) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: imageSource);
      if (pickedImage != null) {
        imagePathAsString = pickedImage.path;
        imageAsUint8List = await pickedImage.readAsBytes();
        setState(() {});
      }
    } catch (e) {
      imageAsUint8List = null;
      setState(() {});
    }
  }

  void saveImage() async {
    print('test');
    bool isGranted = await Permission.storage.status.isGranted;
    if (!isGranted) {
      isGranted = await Permission.storage.request().isGranted;
    }

    if (isGranted) {
      String directory = (await getExternalStorageDirectory())!.path;
      String fileName =
          DateTime.now().microsecondsSinceEpoch.toString() + ".png";
      controller.captureAndSave(directory, fileName: fileName);
    }
  }
}
