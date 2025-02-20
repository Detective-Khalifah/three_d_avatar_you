import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:three_d_avatar_you/providers/model_provider.dart';

class ModelControls extends ConsumerStatefulWidget {
  const ModelControls({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ModelControlsState();
}

class _ModelControlsState extends ConsumerState<ModelControls> {
  Future<void> _pickModel(BuildContext context, int modelId) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['glb'],
        // type: FileType.any,
        // allowedExtensions: ['glb'],
      );
      if (result != null) {
        final path = result.files.single.path!;
        ref.read(modelProvider(modelId).notifier).loadModel(path);
      }
    } catch (e) {
      debugPrint("File picker error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ExpansionTile(title: Text("Model Controls")),
        // Controls
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () {
                  // _controller.setCameraOrbit(20, 20, 5);
                  //controller.setCameraTarget(0.3, 0.2, 0.4);
                },
                icon: const Icon(Icons.camera_alt_outlined),
              ),
              IconButton(
                onPressed: () {
                  // _controller.resetCameraOrbit();
                  //controller.resetCameraTarget();
                },
                icon: const Icon(Icons.cameraswitch_outlined),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Rotation/Jump Controls
class ControlFABs extends StatefulWidget {
  final Flutter3DController? controller0;
  final Flutter3DController? controller1;

  const ControlFABs({
    super.key,
    this.controller0,
    this.controller1,
  });

  @override
  State<ControlFABs> createState() => _ControlFABsState();
}

class _ControlFABsState extends State<ControlFABs> {
  bool isRightFABExpanded = false, isLeftFABExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: 16,
          left: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              AnimatedSlide(
                duration: const Duration(milliseconds: 150),
                offset: isLeftFABExpanded ? Offset.zero : const Offset(0, 1),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: isLeftFABExpanded ? 1.0 : 0.0,
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      // Rotate Model 1 left
                      debugPrint("Turning left");
                      widget.controller0?.setCameraTarget(-.1, 45.0, 5.0);
                      debugPrint("turned left");
                    },
                    label: Text("Turn Left"),
                    icon: Icon(Icons.arrow_left),
                  ),
                ),
              ),
              AnimatedSlide(
                duration: const Duration(milliseconds: 150),
                offset: isLeftFABExpanded ? Offset.zero : const Offset(0, 1),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: isLeftFABExpanded ? 1.0 : 0.0,
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      // Rotate Model 1 right
                      widget.controller0?.setCameraOrbit(.1, 45.0, 5.0);
                    },
                    label: Text("Turn Right"),
                    icon: Icon(Icons.arrow_right),
                  ),
                ),
              ),
              AnimatedSlide(
                duration: const Duration(milliseconds: 150),
                offset: isLeftFABExpanded ? Offset.zero : const Offset(0, 1),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: isLeftFABExpanded ? 1.0 : 0.0,
                  child: FloatingActionButton.extended(
                    onPressed: () async {
                      // Jump animation for Model 1
                      final jumpAnimationName = await widget.controller0
                          ?.getAvailableAnimations()
                          .then((onValue) {
                        for (var value in onValue) {
                          if (value.toLowerCase().contains("jump")) {
                            debugPrint("Jump anim m1 name: $value");
                            return value;
                          }
                        }
                      });
                      widget.controller0
                          ?.playAnimation(animationName: jumpAnimationName);
                      // widget.controller0?.resetCameraOrbit();
                      // widget.controller0?.resetCameraTarget();
                      // widget.controller0?.stopAnimation();
                    },
                    label: Text("Jump"),
                    icon: Icon(Icons.arrow_upward),
                  ),
                ),
              ),
              FloatingActionButton.extended(
                onPressed: () {
                  setState(() {
                    isLeftFABExpanded = !isLeftFABExpanded;
                  });
                },
                label: Text("Model 1"),
                icon: Icon(Icons.face),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 8,
            children: [
              AnimatedSlide(
                duration: const Duration(milliseconds: 150),
                offset: isRightFABExpanded ? Offset.zero : const Offset(0, 1),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: isRightFABExpanded ? 1.0 : 0.0,
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      // Rotate Model 2 left
                      widget.controller1?.setCameraOrbit(-.1, 45.0, 2.0);
                    },
                    label: Text("Turn Left"),
                    icon: Icon(Icons.arrow_left),
                  ),
                ),
              ),
              AnimatedSlide(
                duration: const Duration(milliseconds: 150),
                offset: isRightFABExpanded ? Offset.zero : const Offset(0, 1),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: isRightFABExpanded ? 1.0 : 0.0,
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      // Rotate Model 2 right
                      widget.controller1?.setCameraOrbit(10.0, 45.0, 2.0);
                    },
                    label: Text("Turn Right"),
                    icon: Icon(Icons.arrow_right),
                  ),
                ),
              ),
              AnimatedSlide(
                duration: const Duration(milliseconds: 150),
                offset: isRightFABExpanded ? Offset.zero : const Offset(0, 1),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: isRightFABExpanded ? 1.0 : 0.0,
                  child: FloatingActionButton.extended(
                    onPressed: () async {
                      // Jump animation for Model 1
                      final jumpAnimationName = await widget.controller1
                          ?.getAvailableAnimations()
                          .then((onValue) {
                        for (var value in onValue) {
                          if (value.toLowerCase().contains("jump")) {
                            debugPrint("Jump anim m2 name: $value");
                            return value;
                          }
                        }
                      });
                      widget.controller1
                          ?.playAnimation(animationName: jumpAnimationName);
                    },
                    label: Text("Jump"),
                    icon: Icon(Icons.arrow_upward),
                  ),
                ),
              ),
              FloatingActionButton.extended(
                onPressed: () {
                  setState(() {
                    isRightFABExpanded = !isRightFABExpanded;
                  });
                },
                label: Text("Model 2"),
                icon: Icon(Icons.android),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
