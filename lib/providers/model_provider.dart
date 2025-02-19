import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:three_d_avatar_you/models/three_d_obj_model.dart';

// Provider to manage two 3D models
final modelProvider = StateNotifierProvider.autoDispose
    .family<ModelNotifier, Model, int>((ref, modelId) {
  // Define initial model paths based on modelId
  final initialModelPath = modelId == 0
      ? "assets/models/first_model_retargeted.glb"
      : "assets/models/second_model_retargeted.glb";
  return ModelNotifier(initialModelPath: initialModelPath);
});

class ModelNotifier extends StateNotifier<Model> {
  ModelNotifier({required String initialModelPath})
      : super(Model(modelPath: initialModelPath));

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
