import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:tflite/tflite.dart';
import 'LanguageSelectorPage.dart';
import 'app_translations.dart';


// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.high,
    );
    print(_controller);

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();

    print(_initializeControllerFuture);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppTranslations.of(context).text("take_picture_screen"),
        ),
        actions: <Widget>[
          IconButton(
            tooltip: "Change Language",
            icon: Icon(
              Icons.language,
              color: Colors.grey,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return LanguageSelectorPage();
                  },
                ),
              );
            },
          ),
        ],
      ),
      // Wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner
      // until the controller has finished initializing.
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            height: 600.0,

            child: FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  // If the Future is complete, display the preview.
                  print("preview");
                  print(_controller);
                  return CameraPreview(_controller);
                } else {
                  // Otherwise, display a loading indicator.
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          SizedBox(
            height: 8.0,
          ),
          ButtonTheme(
            minWidth: 300.0,
            height: 100.0,
            child: RaisedButton(
              elevation: 10.0,
              child: Icon(
                Icons.camera_alt,
                size: 70.0,
                semanticLabel: "Capture Image",
              ),
              // Provide an onPressed callback.
              color: Colors.blueGrey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              onPressed: () async {
                // Take the Picture in a try / catch block. If anything goes wrong,
                // catch the error.
                HapticFeedback.vibrate();
                try {
                  // Ensure that the camera is initialized.
                  await _initializeControllerFuture;

                  // Construct the path where the image should be saved using the
                  // pattern package.
                  final path = join(
                    // Store the picture in the temp directory.
                    // Find the temp directory using the `path_provider` plugin.
                    (await getTemporaryDirectory()).path,
                    '${DateTime.now()}.png',
                  );

                  // Attempt to take a picture and log where it's been saved.
                  await _controller.takePicture(path);

                  // If the picture was taken, display it on a new screen.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DisplayPictureScreen(imagePath: path),
                    ),
                  );
                } catch (e) {
                  // If an error occurs, log the error to the console.
                  print(e);
                }
              },
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }
}

class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;

  const DisplayPictureScreen({Key key, this.imagePath}) : super(key: key);

  @override
  _DisplayPictureScreenState createState() =>
      _DisplayPictureScreenState(imagePath);
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  final String imagePath;
  List _outputs;
  File _image;
  bool _loading = false;

  _DisplayPictureScreenState(this.imagePath);

  @override
  void initState() {
    super.initState();
    _loading = true;
    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });

    initClassify(imagePath);
  }

  initClassify(imagePath) async {
    var image = File(imagePath);
    if (image == null) return null;
    setState(() {
      _loading = true;
      _image = image;
    });
    classifyImage(_image);
  }

  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
        path: image.path,
        imageMean: 0.0,
        imageStd: 255.0,
        numResults: 2,
        threshold: 0.2,
        asynch: true);

    setState(() {
      _loading = false;
      _outputs = output;
    });
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
      numThreads: 1,
    );
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppTranslations.of(context).text("display_picture"),
        ),
        elevation: 10,
      ),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.

      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(20),
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                      height: 600,
                      child: _image == null
                          ? Container()
                          : Image.file(File(imagePath))),
                  SizedBox(
                    height: 20,
                  ),
                  _image == null
                      ? Container()
                      : _outputs != null
                          ? Text(
                              "₹ " + _outputs[0]["label"],
                              style:
                                  TextStyle(color: Colors.yellow, fontSize: 60),
                            )
                          : Container(child: Text("")),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
