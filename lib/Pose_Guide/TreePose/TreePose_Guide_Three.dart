//TreePoseGuideThree
bool TreePoseThreePass(Map<String, int> angles) {
  //min max 值還需要調整

// r_wrist angle
  const int r_wrist_perfect_min = 80;
  const int r_wrist_good_min = r_wrist_perfect_min - 20;
  const int r_wrist_perfect_max = 90;
  const int r_wrist_good_max = r_wrist_perfect_max + 20;

  // r_knee angle
  const int r_knee_perfect_min = 80;
  const int r_knee_good_min = r_knee_perfect_min - 20;
  const int r_knee_perfect_max = 90;
  const int r_knee_good_max = r_knee_perfect_max + 20;

  if (angles.containsKey('r_knee') && angles.containsKey('r_wrist')) {
    int r_knee = angles['r_knee']!;
    int r_wrist = angles['r_wrist']!;
    // Angles In Perfect Level
    if (
        // r_knee >= r_knee_perfect_min &&
        // r_knee <= r_knee_perfect_max &&
        r_wrist >= r_wrist_perfect_min && r_wrist <= r_wrist_perfect_max) {
      return true; // 符合 Tree Pose 的條件
    }
    // Angles In Good Level
    else if (
        // r_knee >= r_knee_good_min &&
        // r_knee <= r_knee_good_max &&
        r_wrist >= r_wrist_good_min && r_wrist <= r_wrist_good_max) {
      return true;
    } else {
      return false; // 不符合條件
    }
  }
  return false; // 不符合條件
}
