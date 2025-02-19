import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:three_d_avatar_you/models/three_d_obj_model.dart';

// Provider to manage two 3D models
final modelProvider = StateNotifierProvider.autoDispose
    .family<ModelNotifier, Model, int>((ref, id) {
  return ModelNotifier();
});

class ModelNotifier extends StateNotifier<Model> {
  ModelNotifier()
      : super(Model(modelPath: "assets/models/retarget_first_male_walk2.glb"));

  // Load model from file path
  void loadModel(String path) {
    state = state.copyWith(modelPath: path);
  }

  // Rotate model
  void rotate(double delta) {
    state = state.copyWith(rotationY: state.rotationY + delta);
  }

  // Trigger jump animation
  void jump() {
    state = state.copyWith(isJumping: true);
    Future.delayed(Duration(seconds: 1), () {
      state = state.copyWith(isJumping: false);
    });
  }
}
