import 'dart:async';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:test_pose_detector/Pose_Guide/TreePose/TreePose_Guide_Three.dart';
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
  bool ischeckPoseLooping = false;
  String poseTip = '';
  //
  bool _shouldUpdateUI = false;
  int poseIndex = 0; // 記錄當前完成的最高動作階段
  //每個階段的PASS
  bool isDetecting = false;
  //googlemlkit相關，動作角度座標等等
  Map<String, int> angles = {};
  late PoseDetector _poseDetector;
  List<Pose> poses = [];
  //相機相關
  late CameraController _cameraController;
  bool isFrontCamera = false;
  //fps設定
  double _fpsAverage = 0.0;
  int _fpsCounter = 0;
  DateTime? _lastFrameTime;
  //初始化camera 以及 poseDetector
  @override
  void initState() {
    print("initState poseIndex$poseIndex");
    super.initState();
    _initializeCamera();
    _poseDetector = PoseDetector(
      options: PoseDetectorOptions(
        model: PoseDetectionModel.base,
        mode: PoseDetectionMode.stream,
      ),
    );
    checkPoses();
  }

  //實作初始化相機
  Future<void> _initializeCamera() async {
    print("initCamera poseIndex$poseIndex");

    final CameraDescription selectedCamera = isFrontCamera
        ? widget.cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front)
        : widget.cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back);

    _cameraController = CameraController(selectedCamera, ResolutionPreset.high);
    await _cameraController.initialize();
    //如果初始化了
    if (mounted) {
      setState(() {}); //更新widget
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
    print("_detectPose poseIndex$poseIndex");

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
      //把所有的landmark抓取成變數
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
        //開始計算身體各點的角度 變儲存
        /*右手腕 */
        if (rightIndex != null && rightWrist != null && rightElbow != null) {
          final int r_wrist =
              getAngle(rightIndex, rightWrist, rightElbow).round();
          angles['r_wrist'] = r_wrist;
        }
        /*右手肘 */
        if (rightWrist != null && rightElbow != null && rightShoulder != null) {
          final int r_elbow =
              getAngle(rightWrist, rightElbow, rightShoulder).round();
          angles['r_elbow'] = r_elbow;
        }
        /*右肩膀 */
        if (rightElbow != null && rightShoulder != null && rightHip != null) {
          final int r_shoulder =
              getAngle(rightElbow, rightShoulder, rightHip).round();
          angles['r_shoulder'] = r_shoulder;
        }
        /*右髖部 */
        if (rightShoulder != null && rightHip != null && rightKnee != null) {
          final int r_hip =
              getAngle(rightShoulder, rightHip, rightKnee).round();
          angles['r_hip'] = r_hip;
        }
        /*右膝蓋 */
        if (rightHip != null && rightKnee != null && rightAnkle != null) {
          final int r_knee = getAngle(rightHip, rightKnee, rightAnkle).round();
          angles['r_knee'] = r_knee;
        }
        /*右腳趾 */
        if (rightKnee != null && rightAnkle != null && rightFootIndex != null) {
          final int r_footindex =
              getAngle(rightKnee, rightAnkle, rightFootIndex).round();
          angles['r_footindex'] = r_footindex;
        }
        /*左手腕 */
        if (leftIndex != null && leftWrist != null && leftElbow != null) {
          final int l_wrist = getAngle(leftIndex, leftWrist, leftElbow).round();
          angles['l_wrist'] = l_wrist;
        }
        /*左手肘 */
        if (leftWrist != null && leftElbow != null && leftShoulder != null) {
          final int l_elbow =
              getAngle(leftWrist, leftElbow, leftShoulder).round();
          angles['l_elbow'] = l_elbow;
        }
        /*左肩膀 */
        if (leftElbow != null && leftShoulder != null && leftHip != null) {
          final int l_shoulder =
              getAngle(leftElbow, leftShoulder, leftHip).round();
          angles['l_shoulder'] = l_shoulder;
        }
        /*左髖部 */
        if (leftShoulder != null && leftHip != null && leftKnee != null) {
          final int l_hip = getAngle(leftShoulder, leftHip, leftKnee).round();
          angles['l_hip'] = l_hip;
        }
        /*左膝蓋 */
        if (leftHip != null && leftKnee != null && leftAnkle != null) {
          final int l_knee = getAngle(leftHip, leftKnee, leftAnkle).round();
          angles['l_knee'] = l_knee;
        }
        /*左腳趾 */
        if (leftKnee != null && leftAnkle != null && leftFootIndex != null) {
          final int l_footindex =
              getAngle(leftKnee, leftAnkle, leftFootIndex).round();
          angles['l_footindex'] = l_footindex;
        }
        // 集中輸出所有 print 語句
        Future.delayed(Duration(seconds: 1));
        // print("右手腕的角度是: ${angles['r_wrist']} 度");
        // print("右手肘的角度是: ${angles['r_elbow']} 度");
        // print("右肩膀的角度是: ${angles['r_shoulder']} 度");
        // print("右髖部的角度是: ${angles['r_hip']} 度");
        // print("右膝蓋的角度是: ${angles['r_knee']} 度");
        // print("右腳趾的角度是: ${angles['r_footindex']} 度");
        // print("左手腕的角度是: ${angles['l_wrist']} 度");
        // print("左手肘的角度是: ${angles['l_elbow']} 度");
        // print("左肩膀的角度是: ${angles['l_shoulder']} 度");
        // print("左髖部的角度是: ${angles['l_hip']} 度");
        // print("左膝蓋的角度是: ${angles['l_knee']} 度");
        // print("左腳趾的角度是: ${angles['l_footindex']} 度");
        // print("/n");
      }
      setState(() {
        poses = detectedPoses;
      });
    } catch (e) {
      print("Error detecting pose: $e");
    } finally {
      isDetecting = false;
    }
  }

  //循序跑完三個檢查點

  Future<void> checkPoses() async {
    print("checkPoses poseIndex$poseIndex");

    _shouldUpdateUI = false;
    await _checkPose(poseIndex); // 從第一個動作開始檢查
  }

  Future<void> _checkPose(int poseIndex) async {
    if (!ischeckPoseLooping) {
      print("_checkPoses poseIndex$poseIndex");
      bool result;
      String poseTipText = '';

      switch (poseIndex) {
        case 0:
          result = await TreePoseOnePass(angles);
          poseTipText = '這是TreePose0';
          break;
        case 1:
          result = await TreePoseTwoPass(angles);
          poseTipText = '這是TreePose1';
          break;
        case 2:
          result = await TreePoseThreePass(angles);
          poseTipText = '這是TreePose2';
          break;
        default:
          return;
      }

      if (result) {
        // 當前動作檢查通過
        if (poseIndex < 2) {
          // 進入下一個動作檢查
          poseTip = '$poseTipText通過，進入下一個動作';
          setState(() {});
          await Future.delayed(Duration(milliseconds: 700));
          await _checkPose(poseIndex + 1);
        } else {
          // 所有階段都通過
          poseTip = '$poseTipText通過，所有動作完成';
          setState(() {});
        }
      } else {
        // 當前動作未達標
        poseTip = '$poseTipText未通過，請重試';
        setState(() {});
        await Future.delayed(Duration(milliseconds: 700));
        await _checkPose(poseIndex); // 重試當前階段
      }
    } else {
      return;
    }
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    List<int> allBytes = [];
    for (Plane plane in planes) {
      allBytes.addAll(plane.bytes);
    }
    return Uint8List.fromList(allBytes);
  }

//更新率計算
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

//放棄資源
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
          Positioned(
            top: 30.0,
            right: 10.0,
            child: Text(
              poseTip,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
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
          2.0,
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
