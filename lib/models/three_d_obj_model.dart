// State for each 3D model (position, rotation, and animation)
class Model {
  /// Path to the .glb file
  final String? modelPath;

  /// Current rotation of the model
  final double rotationY;

  /// Whether the model is jumping
  final bool isJumping;

  Model({
    this.modelPath,
    this.rotationY = 0.0,
    this.isJumping = false,
  });

  Model copyWith({
    String? modelPath,
    double? rotationY,
    bool? isJumping,
  }) {
    return Model(
      modelPath: modelPath ?? this.modelPath,
      rotationY: rotationY ?? this.rotationY,
      isJumping: isJumping ?? this.isJumping,
    );
  }
}
