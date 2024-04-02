// pose_selection_page.dart

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'pose.dart';

class PoseSelectionPage extends StatelessWidget {
  final List<CameraDescription> cameras;

  const PoseSelectionPage({Key? key, required this.cameras}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Pose'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CameraScreen(
                      cameras: cameras,
                      selectedPose: 'Tree',
                    ),
                  ),
                );
              },
              child: Text('Tree Pose'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CameraScreen(
                      cameras: cameras,
                      selectedPose: 'Warrior2',
                    ),
                  ),
                );
              },
              child: Text('Warrior Pose'),
            ),
          ],
        ),
      ),
    );
  }
}
