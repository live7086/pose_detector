import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'Pose_Guide/TreePose/TreePose_Guide_One.dart';

class PoseDetectionPage extends StatefulWidget {
   @override
   _PoseDetectionPageState createState() => _PoseDetectionPageState();
}

class _PoseDetectionPageState extends State<PoseDetectionPage> {
   final ImagePicker _picker = ImagePicker();
   final PoseDetector _poseDetector =
      PoseDetector(options: PoseDetectorOptions());

   @override
   void dispose() {
      _poseDetector.close();
      super.dispose();
   }

   Future<Map<String, int>> pickImageAndDetectPose() async {
      Map<String, int> angles = {};
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      final InputImage inputImage = InputImage.fromFilePath(image!.path);
      final List<Pose> poses = await _poseDetector.processImage(inputImage);
      final Pose firstPose = poses.first;
   /*偵測到人物之後，抓取他們人體的landmark，接著傳進getAnkle()計算各個身體的角度*/
   /*左邊*/
      final PoseLandmark? leftShoulder =
         firstPose.landmarks[PoseLandmarkType.leftShoulder];
      final PoseLandmark? leftElbow =
         firstPose.landmarks[PoseLandmarkType.leftElbow];
      final PoseLandmark? leftWrist =
         firstPose.landmarks[PoseLandmarkType.leftWrist];
      final PoseLandmark? leftHip = firstPose.landmarks[PoseLandmarkType.leftHip];
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
         final int r_knee =
            getAngle(rightHip, rightKnee, rightAnkle).round();
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
         final int l_wrist =
            getAngle(leftIndex, leftWrist, leftElbow).round();
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
         final int l_hip =
            getAngle(leftShoulder, leftHip, leftKnee).round();
         angles['l_hip'] = l_hip;
         print("左髖部的角度是: $l_hip 度");
      }
      /*左膝蓋 */
      if (leftHip != null && leftKnee != null && leftAnkle != null) {
         final int l_knee =
            getAngle(leftHip, leftKnee, leftAnkle).round();
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
         final int l_shoulder = getAngle(leftElbow, leftShoulder, leftHip).round();
         angles['l_shoulder'] = l_shoulder;
         print("左肩膀的角度是: $l_shoulder 度");
         print(angles);
      }
      return angles;
   }
      // 計算角度的函式
      double getAngle(
         PoseLandmark firstPoint, PoseLandmark midPoint, PoseLandmark lastPoint) {
      var result = (math.atan2(
                  lastPoint.x - midPoint.y, lastPoint.x - midPoint.x) -
               math.atan2(firstPoint.y - midPoint.y, firstPoint.x - midPoint.x)) *
         (180 / math.pi);
      result = result.abs(); // 角度應該永遠不為負
      if (result > 180) {
         result = 360.0 - result; // 總是獲得角度的銳角表示
      }
      return result;
   }
   //辨識第一階段
   void checkPose() async {
      Map<String, int> angles = await pickImageAndDetectPose();
      bool result = TreePoseOnePass(angles);
      if (result) {
         print("是 Tree Pose");
      } else {
         print("不是 Tree Pose");
      }
      }


   // 實際頁面+按鍵
   @override
   Widget build(BuildContext context) {
      return Scaffold(
      appBar: AppBar(
         title: Text('Pose Detection'),
      ),
      body: Center(
         child: ElevatedButton(
            onPressed: () async {
            await pickImageAndDetectPose();
                  checkPose(); // 在圖片選擇和姿勢檢測之後調用
            },
            child: Text('Pick Image and Detect Pose'),
         ),
      ),
      );
   }
}
