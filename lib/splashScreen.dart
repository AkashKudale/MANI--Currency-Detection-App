import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mani/takePictureScreen.dart';

import 'app_translations_delegate.dart';
import 'application.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    Key key,
  }) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  AppTranslationsDelegate _newLocaleDelegate;
  @override
  void initState() {
    // TODO: implement initState
    _newLocaleDelegate = AppTranslationsDelegate(newLocale: null);
    application.onLocaleChanged = onLocaleChange;

    Timer(
      Duration(seconds: 2),
      () => cameraInit(),
    );
  }
  void onLocaleChange(Locale locale) {
    setState(() {
      _newLocaleDelegate = AppTranslationsDelegate(newLocale: locale);
    });
  }

  Future<void> cameraInit() async {
    // Ensure that plugin services are initialized so that `availableCameras()`
    // can be called before `runApp()`
    WidgetsFlutterBinding.ensureInitialized();

    // Obtain a list of the available cameras on the device.
    final cameras = await availableCameras();

    // Get a specific camera from the list of available cameras.
    final firstCamera = cameras.first;

    runApp(
      MaterialApp(
        theme: ThemeData.dark(),
        home: TakePictureScreen(
          // Pass the appropriate camera to the TakePictureScreen widget.
          camera: firstCamera,
        ),
        localizationsDelegates: [
          _newLocaleDelegate,
          //provides localised strings
          GlobalMaterialLocalizations.delegate,
          //provides RTL support
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale("en", ""),
          const Locale("hi", ""),
          const Locale("kn", ""),
          const Locale("mr", ""),
          const Locale("pa", ""),
          const Locale("ur", ""),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(color: Colors.blueGrey),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        padding: EdgeInsets.all(10.0),
                        child: Image.asset('assets/launcher/icon.png')),
                    Padding(padding: EdgeInsets.only(top: 10.0)),
                    Text(
                      "M A N I",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 50.0,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                )),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(),
                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                    ),
                    Text(
                      "Mobile Aided Note Identifier",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
