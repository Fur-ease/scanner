import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:scanner/fullcamera.dart';
import 'package:scanner/home.dart';
//import 'package:qrscanner/splash.dart';

late final List<CameraDescription> cameras;

Future<void> main() async {
  // Ensure that plugin services are initialized
   WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  cameras = await availableCameras();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
//        "/": (context) => const Splash(),
        "/": (context) => Home(camera: cameras.first),
         "/fullcamera": (context) =>  FullCamera(camera: cameras.first, onClose: () {  }, onScanSuccess: (scannedData) {  },),
        // "/register":(context) => const Register(),
        // "/forgotpassword":(context) => ForgotPassword(),
      },
    );
  }
}