import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:three_d_avatar_you/widgets/extended_fab.dart';
import 'package:webview_flutter/webview_flutter.dart';
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
  final WebViewController? controller0;
  final WebViewController? controller1;

  const ControlFABs({
    super.key,
    this.controller0,
    this.controller1,
  });

  @override
  State<ControlFABs> createState() => _ControlFABsState();
}

class _ControlFABsState extends State<ControlFABs> {
  bool _isTalking = true; // Track which model is talking
  bool isRightFABExpanded = false, isLeftFABExpanded = false;

  // Injects JavaScript to start animations
  /// Model stops previous animation, becomes idle or talks if they're facing the other model.
  /// animations:  Standing_Idle_003, Walk_Jump_002, Talking_001, and Talking_010
  void _playAnimation(WebViewController controller, String animation) {
    if (widget.controller0 == null || widget.controller1 == null) return;

    final theAnimation = switch (animation) {
      "idle" => "Standing_Idle_003",
      "jump" =>
        (controller == widget.controller0) ? "Walk_Jump_002" : "Walk_Jump_001",
      "talk" =>
        (controller == widget.controller0) ? "Talking_010" : "Talking_001",
      _ => throw Exception("Unexpected animation value: $animation")
    };

    final repetitions = animation == "jump" ? 1 : "Infinity";

    controller.runJavaScript('''
      // let modelViewer;
      if (typeof modelViewer === "undefined" /*modelViewer == null*/) {
        modelViewer = document.querySelector("model-viewer");
      }

      console.log(modelViewer.getCameraTarget().toString());
      console.log(modelViewer.getCameraOrbit().toString());


      // Stop the previous animation
      modelViewer.pause();
      modelViewer.currentTime = 0;

      // Select the passed animation and play it
      modelViewer.animationName = "$theAnimation";
      if ("$animation" == "jump") {
        modelViewer.play({repetitions: $repetitions});
          console.log("Playing jump animation with 1 repetition.");
      } else {
        modelViewer.play();
          console.log("Playing animation with default repetitions.");
      }
      // modelViewer.play({repetitions: $repetitions});
      setTimeout(() => {
    // modelViewer.cameraTarget = "auto"; // Re-center camera
    // modelViewer.cameraOrbit = "auto";  // Ensure camera follows
  }, 500);
    ''');
  }

  /// Switches animation & resumes talking after interaction
  /// animations:  Standing_Idle_003, Walk_Jump_002, Talking_001/Talking_010
  void _initializeAnimation(String action) {
    final actingController =
        _isTalking ? widget.controller0 : widget.controller1;
    final idleController = _isTalking ? widget.controller1 : widget.controller0;

    // Pause talking animation & play action
    actingController?.runJavaScript(
        '''const modelViewer = document.querySelector('model-viewer');
           modelViewer.animationName = "$action";
           setTimeout(() => {
             modelViewer.cameraTarget = "auto"; // Re-center camera
           }, 500);
        ''');

    Future.delayed(Duration(seconds: 2), () {
      // Resume talking after action completes
      actingController?.runJavaScript(
          'document.querySelector("model-viewer").animationName = "Talking_001";');
      idleController?.runJavaScript(
          'document.querySelector("model-viewer").animationName = " Standing_Idle_003";');

      // Swap turns
      setState(() {
        _isTalking = !_isTalking;
      });
    });
  }

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
              ExtendedFab(
                isExpanded: isLeftFABExpanded,
                onPressed: () {
                  // Rotate Model 1 left
                  // widget.controller0?.setCameraTarget(-.1, 45.0, 5.0);
                  widget.controller0?.runJavaScript(
                      '''document.querySelector("model-viewer").cameraOrbit = ("90deg 90deg 5m");''');
                  widget.controller0?.runJavaScript(
                      '''document.querySelector("model-viewer").cameraTarget = ("4.5m 1.5m 0m");''');
                  _playAnimation(widget.controller0!, "idle");
                },
                label: "Turn Left",
                icon: Icons.swipe_left,
              ),
              ExtendedFab(
                isExpanded: isLeftFABExpanded,
                onPressed: () {
                  // Rotate Model 1 right, then make 'im start talking
                  widget.controller0?.runJavaScript(
                      '''document.querySelector("model-viewer").cameraOrbit = "-90deg 120deg 1.5m";''');
                  widget.controller0?.runJavaScript(
                      '''document.querySelector("model-viewer").cameraTarget = ("-3m -1m 0m");''');
                  //     widget.controller0?.runJavaScript(
                  //     '''document.querySelector("model-viewer").cameraOrbit = "-90deg 90deg 1m";''');
                  // widget.controller0?.runJavaScript(
                  //     '''document.querySelector("model-viewer").cameraTarget = ("-4.5m 1.6m 0m");''');
                  _playAnimation(widget.controller0!, "talk");
                  // widget.controller0?.setCameraOrbit(.1, 45.0, 5.0);
                },
                label: "Turn Right",
                icon: Icons.swipe_right,
              ),
              ExtendedFab(
                isExpanded: isLeftFABExpanded,
                onPressed: () async {
                  // Jump animation for Model 1
                  widget.controller0?.runJavaScript(
                      '''document.querySelector("model-viewer").cameraOrbit = "-90deg 90deg 1m";''');
                  widget.controller0?.runJavaScript(
                      '''document.querySelector("model-viewer").cameraTarget = ("-4.5m 1.6m 1m");''');
                  _playAnimation(widget.controller0!, "jump");
                  // widget.controller0?.resetCameraOrbit();
                  // widget.controller0?.resetCameraTarget();
                  // widget.controller0?.stopAnimation();
                },
                label: "Jump",
                icon: Icons.swipe_up,
              ),
              FloatingActionButton.extended(
                onPressed: () {
                  setState(() {
                    isLeftFABExpanded = !isLeftFABExpanded;
                  });
                },
                label: Text("Model 1"),
                icon: Icon(Icons.person_4_outlined),
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
              ExtendedFab(
                isExpanded: isRightFABExpanded,
                onPressed: () {
                  // Rotate Model 2 left
                  widget.controller1?.runJavaScript(
                      '''document.querySelector("model-viewer").cameraOrbit = ("90deg 90deg 3m");''');
                  // widget.controller1?.runJavaScript(
                  //     '''document.querySelector("model-viewer").cameraTarget = ("4.5m 1.5m 0m");''');
                  widget.controller1?.runJavaScript(
                      '''document.querySelector("model-viewer").cameraTarget = ("4m 1.5m 0m");''');
                  _playAnimation(widget.controller1!, "talk");
                  // widget.controller1?.setCameraOrbit(-.1, 45.0, 2.0);
                },
                label: "Turn Left",
                icon: Icons.swipe_left,
              ),
              ExtendedFab(
                isExpanded: isRightFABExpanded,
                onPressed: () {
                  // Rotate Model 2 right
                  widget.controller1?.runJavaScript(
                      '''document.querySelector("model-viewer").cameraOrbit = "-90deg 90deg 1m";''');
                  widget.controller1?.runJavaScript(
                      '''document.querySelector("model-viewer").cameraTarget = ("-4.5m 1.4m 0m");''');
                  _playAnimation(widget.controller1!, "idle");
                  // widget.controller1?.setCameraOrbit(10.0, 45.0, 2.0);
                },
                label: "Turn Right",
                icon: Icons.swipe_right,
              ),
              ExtendedFab(
                isExpanded: isRightFABExpanded,
                onPressed: () async {
                  widget.controller1?.runJavaScript(
                      '''document.querySelector("model-viewer").cameraOrbit = "-90deg 90deg 1m";''');
                  widget.controller1?.runJavaScript(
                      '''document.querySelector("model-viewer").cameraTarget = ("-4.5m 1.6m 1m");''');
                  _playAnimation(widget.controller1!, "jump");
                },
                label: "Jump",
                icon: Icons.swipe_up,
              ),
              FloatingActionButton.extended(
                onPressed: () {
                  setState(() {
                    isRightFABExpanded = !isRightFABExpanded;
                  });
                },
                label: Text("Model 2"),
                icon: Icon(Icons.person_outline),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
