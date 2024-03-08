import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:test_pose_detector/Pose_Guide/TreePose/TreePose_Guide_Two.dart';
import 'dart:typed_data';
import 'dart:math' as math;
import 'Pose_Guide/TreePose/TreePose_Guide_One.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  //每個階段的PASS
  bool onePass = false;
  bool twoPass = false;
  bool threePass = false;
  //
  Map<String, int> angles = {};
  late CameraController _cameraController;
  bool isDetecting = false;
  late PoseDetector _poseDetector;
  List<Pose> poses = [];
  bool isFrontCamera = false;
  //fps設定
  double _fpsAverage = 0.0;
  int _fpsCounter = 0;
  DateTime? _lastFrameTime;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _poseDetector = PoseDetector(
      options: PoseDetectorOptions(
        model: PoseDetectionModel.base,
        mode: PoseDetectionMode.stream,
      ),
    );
  }

  Future<void> _initializeCamera() async {
    final CameraDescription selectedCamera = isFrontCamera
        ? widget.cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front)
        : widget.cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back);

    _cameraController = CameraController(selectedCamera, ResolutionPreset.low);
    await _cameraController.initialize();
    if (mounted) {
      setState(() {});
      _cameraController.startImageStream((CameraImage image) {
        if (!isDetecting) {
          isDetecting = true;
          _detectPose(image, isFrontCamera);
        }
      });
    }
  }

  void _toggleCamera() {
    setState(() {
      isFrontCamera = !isFrontCamera;
      _initializeCamera();
    });
  }

  Future<void> _detectPose(CameraImage image, bool isFrontCamera) async {
    final InputImageRotation rotation = isFrontCamera
        ? InputImageRotation.rotation270deg // 前置摄像头
        : InputImageRotation.rotation90deg; // 后置摄像头

    final InputImage inputImage = InputImage.fromBytes(
      bytes: _concatenatePlanes(image.planes),
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: InputImageFormat.nv21,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );

    try {
      final List<Pose> detectedPoses =
          await _poseDetector.processImage(inputImage);
      this.angles.clear();
      // Map<String, int> angles = {};
      if (detectedPoses.isNotEmpty) {
        final Pose firstPose = detectedPoses.first;
        final PoseLandmark? leftShoulder =
            firstPose.landmarks[PoseLandmarkType.leftShoulder];
        final PoseLandmark? leftElbow =
            firstPose.landmarks[PoseLandmarkType.leftElbow];
        final PoseLandmark? leftWrist =
            firstPose.landmarks[PoseLandmarkType.leftWrist];
        final PoseLandmark? leftHip =
            firstPose.landmarks[PoseLandmarkType.leftHip];
        final PoseLandmark? leftKnee =
            firstPose.landmarks[PoseLandmarkType.leftKnee];
        final PoseLandmark? leftAnkle =
            firstPose.landmarks[PoseLandmarkType.leftAnkle];
        final PoseLandmark? leftIndex =
            firstPose.landmarks[PoseLandmarkType.leftIndex];
        final PoseLandmark? leftFootIndex =
            firstPose.landmarks[PoseLandmarkType.leftFootIndex];

        /*右邊*/
        final PoseLandmark? rightShoulder =
            firstPose.landmarks[PoseLandmarkType.rightShoulder];
        final PoseLandmark? rightElbow =
            firstPose.landmarks[PoseLandmarkType.rightElbow];
        final PoseLandmark? rightWrist =
            firstPose.landmarks[PoseLandmarkType.rightWrist];
        final PoseLandmark? rightHip =
            firstPose.landmarks[PoseLandmarkType.rightHip];
        final PoseLandmark? rightKnee =
            firstPose.landmarks[PoseLandmarkType.rightKnee];
        final PoseLandmark? rightAnkle =
            firstPose.landmarks[PoseLandmarkType.rightAnkle];
        final PoseLandmark? rightIndex =
            firstPose.landmarks[PoseLandmarkType.rightIndex];
        final PoseLandmark? rightFootIndex =
            firstPose.landmarks[PoseLandmarkType.rightFootIndex];

        /*右手腕 */
        if (rightIndex != null && rightWrist != null && rightElbow != null) {
          final int r_wrist =
              getAngle(rightIndex, rightWrist, rightElbow).round();
          angles['r_wrist'] = r_wrist;
          print("右手腕的角度是: $r_wrist 度");
        }
        /*右手肘 */
        if (rightWrist != null && rightElbow != null && rightShoulder != null) {
          final int r_elbow =
              getAngle(rightWrist, rightElbow, rightShoulder).round();
          angles['r_elbow'] = r_elbow;
          print("右手肘的角度是: $r_elbow 度");
        }
        /*右肩膀 */
        if (rightElbow != null && rightShoulder != null && rightHip != null) {
          final int r_shoulder =
              getAngle(rightElbow, rightShoulder, rightHip).round();
          angles['r_shoulder'] = r_shoulder;
          print("右肩膀的角度是: $r_shoulder 度");
        }
        /*右髖部 */
        if (rightShoulder != null && rightHip != null && rightKnee != null) {
          final int r_hip =
              getAngle(rightShoulder, rightHip, rightKnee).round();
          angles['r_hip'] = r_hip;
          print("右髖部的角度是: $r_hip 度");
        }
        /*右膝蓋 */
        if (rightHip != null && rightKnee != null && rightAnkle != null) {
          final int r_knee = getAngle(rightHip, rightKnee, rightAnkle).round();
          angles['r_knee'] = r_knee;
          print("右膝蓋的角度是: $r_knee 度");
        }
        /*右腳踝 */
        if (rightKnee != null && rightAnkle != null && rightFootIndex != null) {
          final int r_footindex =
              getAngle(rightKnee, rightAnkle, rightFootIndex).round();
          angles['r_footindex'] = r_footindex;
          print("右腳踝的角度是: $r_footindex 度");
        }
        /*左手腕 */
        if (leftIndex != null && leftWrist != null && leftElbow != null) {
          final int l_wrist = getAngle(leftIndex, leftWrist, leftElbow).round();
          angles['l_wrist'] = l_wrist;
          print("左手腕的角度是: $l_wrist 度");
        }
        /*左手肘 */
        if (leftWrist != null && leftElbow != null && leftShoulder != null) {
          final int l_elbow =
              getAngle(leftWrist, leftElbow, leftShoulder).round();
          angles['l_elbow'] = l_elbow;
          print("左手肘的角度是: $l_elbow 度");
        }
        /*左肩膀 */
        if (leftElbow != null && leftShoulder != null && leftHip != null) {
          final int l_shoulder =
              getAngle(leftElbow, leftShoulder, leftHip).round();
          angles['l_shoulder'] = l_shoulder;
          print("左肩膀的角度是: $l_shoulder 度");
        }
        /*左髖部 */
        if (leftShoulder != null && leftHip != null && leftKnee != null) {
          final int l_hip = getAngle(leftShoulder, leftHip, leftKnee).round();
          angles['l_hip'] = l_hip;
          print("左髖部的角度是: $l_hip 度");
        }
        /*左膝蓋 */
        if (leftHip != null && leftKnee != null && leftAnkle != null) {
          final int l_knee = getAngle(leftHip, leftKnee, leftAnkle).round();
          angles['l_knee'] = l_knee;
          print("左膝蓋的角度是: $l_knee 度");
        }
        /*左腳踝 */
        if (leftKnee != null && leftAnkle != null && leftFootIndex != null) {
          final int l_footindex =
              getAngle(leftKnee, leftAnkle, leftFootIndex).round();
          angles['l_footindex'] = l_footindex;
          print("左腳踝的角度是: $l_footindex 度");
        }
        if (leftElbow != null && leftShoulder != null && leftHip != null) {
          final int l_shoulder =
              getAngle(leftElbow, leftShoulder, leftHip).round();
          angles['l_shoulder'] = l_shoulder;
          print("左肩膀的角度是: $l_shoulder 度");
          // print(angles);
        }
      }
      setState(() {
        poses = detectedPoses;
      });
    } catch (e) {
      print("Error detecting pose: $e");
    } finally {
      isDetecting = false;
    }
    //
    checkPoses();
    // await onePassCheck();
    // //應該要確認是完成的才進行下一步 不是成功就好
    // await twoPassCheck();
  }

  //循序跑完三個檢查點
  Future<void> checkPoses() async {
    _checkPoseRecursive(0);
  }

  Future<void> _checkPoseRecursive(int poseIndex) async {
    bool result;

    switch (poseIndex) {
      case 0:
        result = await TreePoseOnePass(angles);
        break;
      case 1:
        result = await TreePoseTwoPass(angles);
        break;
      // case 2:
      //   result = await threePassCheck();
      //   break;
      default:
        return; // 所有動作檢查完畢,退出遞迴
    }

    if (result) {
      // 當前動作檢查通過, 進入下一個動作檢查
      if (poseIndex < 2) {
        // 假設您總共有 3 個動作要檢查，編號為 0, 1, 2
        _checkPoseRecursive(poseIndex + 1);
      }
      poseTip = Text("這是TreePose$poseIndex");
      setState(() {});
    } else {
      // 當前動作未達標,稍後再次檢查
      Future.delayed(
          Duration(seconds: 1), () => _checkPoseRecursive(poseIndex));
      poseTip = Text("不是正確的動作 $poseIndex，稍後將重新檢查");
      setState(() {});
    }
  }

  // 計算角度的函式
  double getAngle(
      PoseLandmark firstPoint, PoseLandmark midPoint, PoseLandmark lastPoint) {
    // 確保midPoint在firstPoint和lastPoint之間
    if ((midPoint.x - firstPoint.x) * (lastPoint.x - firstPoint.x) +
            (midPoint.y - firstPoint.y) * (lastPoint.y - firstPoint.y) <
        0) {
      final temp = firstPoint;
      firstPoint = lastPoint;
      lastPoint = temp;
    }

    final result =
        math.atan2(lastPoint.y - midPoint.y, lastPoint.x - midPoint.x) -
            math.atan2(firstPoint.y - midPoint.y, firstPoint.x - midPoint.x);
    final angle = result * (180 / math.pi);

    return angle.abs() <= 180 ? angle.abs() : 360 - angle.abs();
  }

  Widget poseTip = Text('不是 Tree Pose');
  // Widget posecheck = Text('not enterd');
  //辨識第一階段
  Future<void> onePassCheck() async {
    // posecheck = Text("entered");
    // Map<String, int> angles = await pickImageAndDetectPose();
    Future.delayed(Duration(seconds: 5));
    bool result = TreePoseOnePass(angles);
    if (result) {
      poseTip = Text("是 Tree Pose One");
      onePass = true;
    } else {
      poseTip = Text("是 Tree Pose One");
      onePass = false;
    }
    setState(() {});
  }

  //辨識第二階段
  Future<void> twoPassCheck() async {
    // posecheck = Text("entered");
    // Map<String, int> angles = await pickImageAndDetectPose();
    Future.delayed(Duration(seconds: 5));
    bool result = TreePoseTwoPass(angles);
    if (result) {
      poseTip = Text("是 Tree Pose Two");
      twoPass = true;
    } else {
      poseTip = Text("不是 Tree Pose Two");
      twoPass = false;
    }
    setState(() {});
  }

  //辨識第三階段
  // Future<void> threePassCheck() async {
  //   // posecheck = Text("entered");
  //   // Map<String, int> angles = await pickImageAndDetectPose();
  //   Future.delayed(Duration(seconds: 5));
  //   bool result = TreePoseOnePass(angles);
  //   if (result) {
  //     poseTip = Text("是 Tree Pose");
  //     onePass = true;
  //   } else {
  //     poseTip = Text("不是 Tree Pose");
  //     onePass = false;
  //   }
  //   setState(() {});
  // }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    List<int> allBytes = [];
    for (Plane plane in planes) {
      allBytes.addAll(plane.bytes);
    }
    return Uint8List.fromList(allBytes);
  }

  String _getFps() {
    DateTime currentTime = DateTime.now();
    double currentFps = _lastFrameTime != null
        ? 1000 / currentTime.difference(_lastFrameTime!).inMilliseconds
        : 0;

    _fpsAverage = (_fpsAverage * _fpsCounter + currentFps) / (_fpsCounter + 1);
    _fpsCounter++;

    if (_fpsCounter > 100) {
      _fpsCounter = 0;
      _fpsAverage = currentFps;
    }

    _lastFrameTime = currentTime;

    return _fpsAverage.toStringAsFixed(1);
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraController.value.isInitialized) {
      return Container();
    }

    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _cameraController.value.previewSize?.height ?? 1,
                height: _cameraController.value.previewSize?.width ?? 1,
                child: CameraPreview(_cameraController),
              ),
            ),
          ),
          CustomPaint(
            painter: PosePainter(poses, isFrontCamera),
          ),
          Positioned(top: 30.0, right: 10.0, child: poseTip),
          Positioned(
            top: 30.0,
            left: 10.0,
            child: Text(
              'FPS: ${_getFps()}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var entry in this.angles.entries)
                  Text(
                    '${entry.key}: ${entry.value}度',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleCamera,
        child: const Icon(Icons.switch_camera),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
    );
  }
}

class PosePainter extends CustomPainter {
  final List<Pose> poses;
  final bool isFrontCamera;

  PosePainter(this.poses, this.isFrontCamera);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 5;

    for (var pose in poses) {
      for (var landmark in pose.landmarks.values) {
        double x = landmark.x;
        double y = landmark.y;

        // 如果是前置摄像头，进行垂直翻转
        // if (isFrontCamera) {
        x = size.width + 240 - x;
        // }

        canvas.drawCircle(
          Offset(x, y),
          10.0,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
