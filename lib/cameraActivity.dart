import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';


void main() => runApp(MaterialApp(
      theme:
          ThemeData(primaryColor: Colors.blueAccent, accentColor: Colors.white),
      home: CameraActivity(),
    ));

class CameraActivity extends StatefulWidget {
  @override
  _CameraActivityState createState() => _CameraActivityState();
}

class _CameraActivityState extends State<CameraActivity> {
  List<CameraDescription> cameras;
  CameraController controller;
  bool isReady = false;
  String _path = null;

  @override
  void initState() {
    super.initState();
    setupCameras();
  }

  Future<void> setupCameras() async {
    try {
      cameras = await availableCameras();
      controller = new CameraController(cameras[0], ResolutionPreset.medium);
      await controller.initialize();
    } on CameraException catch (_) {
      setState(() {
        isReady = false;
      });
    }
    setState(() {
      isReady = true;
    });
  }

  void _takePicture(BuildContext context) async {
    try {


      final path =
      join((await getTemporaryDirectory()).path, '${DateTime.now()}.png');

      await controller.takePicture(path);

      Navigator.pop(context,path);

    } catch (e) {
      print(e);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scan Currency')),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: CameraPreview(controller),
            ),

            ButtonTheme(
              minWidth: 200.0,
              height: 150.0,
              child: RaisedButton(
                onPressed: () {
                  _takePicture(context);
                },
                color: Colors.blueAccent,

                child: Icon(
                  Icons.camera_alt,
                  size: 90.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
