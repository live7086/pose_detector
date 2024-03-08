import 'package:flutter/material.dart';
import 'package:test_pose_detector/pose.dart';
import 'package:camera/camera.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder(
        future: availableCameras(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraScreen(
                cameras: snapshot.data as List<CameraDescription>);
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
