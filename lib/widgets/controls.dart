import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:three_d_avatar_you/providers/model_provider.dart';

/// Rotation/Jump Controls
class AnimationControl extends ConsumerStatefulWidget {
  final WebViewController? controller0;
  final WebViewController? controller1;

  const AnimationControl({
    super.key,
    this.controller0,
    this.controller1,
  });

  @override
  ConsumerState<AnimationControl> createState() => _ControlFABsState();
}

class _ControlFABsState extends ConsumerState<AnimationControl> {
  bool _isTalking = true; // Track which model is talking
  bool isRightFABExpanded = false,
      isLeftFABExpanded = false,
      isMixamoModel = false;
  int duration = 1000;

  // Injects JavaScript to start animations
  /// Model stops previous animation, becomes idle or talks if they're facing the other model.
  /// animations:  Standing_Idle_003, Walk_Jump_002, Talking_001, and Talking_010
  void _playAnimation(WebViewController controller, String animation,
      {String? statement}) {
    if (widget.controller0 == null || widget.controller1 == null) return;
    String theAnimation = parseAnimationStatement(
      animation: animation,
      controller: controller,
    );

    if (statement != null && statement.isNotEmpty) {
      if (!isMixamoModel) controller.runJavaScript(statement);
    }

    const repetitions = 1;

    // TODO: `setTimeout` not running in js below to reset model; use `Future.delayed(duration);` instead
    controller.runJavaScript('''
      // Ensure modelViewer is defined
      if (typeof modelViewer === "undefined") {
        modelViewer = document.querySelector("model-viewer");
      }

      console.log(modelViewer.getCameraTarget().toString());
      console.log(modelViewer.getCameraOrbit().toString());


      // Stop the previous animation
      modelViewer.pause();
      modelViewer.currentTime = 0;

      // Select the passed animation and play it
      modelViewer.animationName = "$theAnimation";
      modelViewer.play({repetitions: $repetitions});
      console.log("Playing '$theAnimation' animation with '$repetitions' repetition.");
      
      if (typeof duration === "undefined") {
        duration = modelViewer.duration;
        console.log("Animation duration: ", duration);
      }

      // setTimeout(() => {
      //   if ("$theAnimation" !== "crouch") {
      //   console.log("not crouch);
      //     modelViewer.pause();
      //     modelViewer.currentTime = 0;
      //   } else {
      //     console.log("crouch");
      //     modelViewer.pause();
      //     // modelViewer.play("stand_up"); also an infinite animation. TODO: see if I can make model stand up before jumping
      //   }
      //   // modelViewer.cameraTarget = "auto"; // Re-center camera
      //   // modelViewer.cameraOrbit = "auto";  // Ensure camera follows
      // }, duration);
    ''');

    // Reset model animation for retargeted & Mixamoed models.
    Future.delayed(
      Duration(milliseconds: duration),
      () {
        if (animation == "jump") {
          controller.runJavaScript('''
            if (typeof modelViewer === "undefined") {
              modelViewer = document.querySelector("model-viewer");
            }
            console.log("Resetting/Stopping animation");
            // modelViewer.animationName = "$parseAnimationStatement(animation: "stand", controller: $controller)";
            modelViewer.pause();
            modelViewer.currentTime = 0;
            console.log("animation reset");
        ''');
        } else {
          // play idle -- let model rest
          controller.runJavaScript('''
            if (typeof modelViewer === "undefined") {
              modelViewer = document.querySelector("model-viewer");
            }
            console.log("idling");
            modelViewer.currentTime = duration;
            modelViewer.pause();
            console.log("idle");
          ''');
        }
      },
    ).then(
      (value) {
        // End of retargeted animation rest algorithm and continuation of Mixamoed rest;
        // (if in crouch postion, stand up)
        if (animation == "crouch") {
          controller.runJavaScript('''
        if (typeof modelViewer === "undefined") {
          modelViewer = document.querySelector("model-viewer");
        }
        console.log("standing up");
        modelViewer.animationName = "stand_up";
        modelViewer.play();
      ''').then(
            (value) {
              Future.delayed(
                Duration(milliseconds: 2590),
                () {
                  controller.runJavaScript('''
                    if (typeof modelViewer === "undefined") {
                      modelViewer = document.querySelector("model-viewer");
                    }
                    console.log("stood up");
                    modelViewer.currentTime = 2590;
                    modelViewer.pause();
                    // Added this to prevent model from getting to crouch
                    // position when next animation is played, which looks...
                    // very jarring!
                    modelViewer.animationName = "crouch"; 
                    console.log("nothing further");
                  ''');
                },
              );
            },
          );
        }
      },
    );
  }
  // TODO: consider using `flutter_3d_controller` as it may have easier controls
  //  or use a better, approriate, suitable framework/tool

  String parseAnimationStatement({
    required String animation,
    required WebViewController controller,
  }) {
    final String theAnimation;

    if (isMixamoModel) {
      theAnimation = switch (animation) {
        "crouch" => "crouch",
        "idle" => (controller == widget.controller0)
            ? "right_turn" // TODO: fix animation name for model in glasses
            : "turn_left",
        "jump" => "jump_up",
        "stand" => "stand_up",
        "talk" => (controller == widget.controller0)
            ? "left_turn" // TODO: fix animation name for model in glasses
            : "turn_right",
        _ => "jump_up"
      };
      duration = switch (animation) {
        "crouch" => 4090,
        "idle" => 960,
        "jump" => 2400,
        "stand" => 2590,
        "talk" => 960,
        _ => 1000
      };
    } else {
      theAnimation = switch (animation) {
        "idle" => "Standing_Idle_003",
        "jump" => (controller == widget.controller0)
            ? "Walk_Jump_002"
            : "Walk_Jump_001",
        "talk" =>
          (controller == widget.controller0) ? "Talking_010" : "Talking_001",
        _ => "Standing_Idle_003"
      };
      duration = switch (animation) {
        "idle" => 6090,
        "jump" => 1930,
        "talk" => 10000,
        _ => 1000
      };
    }
    return theAnimation;
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
    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 8,
            children: [
              IconButton(
                onPressed: () {
                  // Jump animation for Model 1
                  _playAnimation(widget.controller0!, "jump", statement: '''
                    document.querySelector("model-viewer").cameraOrbit = "-90deg 90deg 1m";
                    document.querySelector("model-viewer").cameraTarget = ("-4.5m 1.6m 1m");
                  ''');
                  // widget.controller0?.resetCameraOrbit();
                  // widget.controller0?.resetCameraTarget();
                  // widget.controller0?.stopAnimation();
                },
                icon: Icon(Icons.swipe_up),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      // Rotate Model 1 left
                      // widget.controller0?.setCameraTarget(-.1, 45.0, 5.0);
                      _playAnimation(widget.controller0!, "idle", statement: '''
                            document.querySelector("model-viewer").cameraOrbit = ("90deg 90deg 5m");
                            document.querySelector("model-viewer").cameraTarget = ("4.5m 1.5m 0m");
                          ''');
                    },
                    icon: Icon(Icons.swipe_left),
                  ),
                  IconButton(
                    onPressed: () {
                      // Crouch animation for Model 1
                      _playAnimation(
                        widget.controller0!,
                        isMixamoModel ? "crouch" : "idle",
                        statement:
                            '''document.querySelector("model-viewer").cameraOrbit = "-90deg 90deg 1m";
                            document.querySelector("model-viewer").cameraTarget = ("-4.5m 1.6m 1m");''',
                      );
                    },
                    icon: Icon(Icons.swipe_down),
                  ),
                  IconButton(
                    onPressed: () {
                      // Rotate Model 1 right, then make 'im start talking
                      //     widget.controller0?.runJavaScript(
                      //     '''document.querySelector("model-viewer").cameraOrbit = "-90deg 90deg 1m";''');
                      // widget.controller0?.runJavaScript(
                      //     '''document.querySelector("model-viewer").cameraTarget = ("-4.5m 1.6m 0m");''');
                      _playAnimation(widget.controller0!, "talk",
                          statement:
                              'document.querySelector("model-viewer").cameraOrbit = "-90deg 120deg 1.5m";' +
                                  'document.querySelector("model-viewer").cameraTarget = ("-3m -1m 0m");');
                      // widget.controller0?.setCameraOrbit(.1, 45.0, 5.0);
                    },
                    icon: Icon(Icons.swipe_right),
                  ),
                ],
              ),
            ],
          ),
          TextButton.icon(
            onPressed: () {
              late final model0State = ref.read(modelProvider(0).notifier);
              late final model1State = ref.watch(modelProvider(1).notifier);
              debugPrint("Switching... Is Mixamo? $isMixamoModel");
              // if (isMixamoModel) {
              //   setState(() {
              //     model0State
              //         .loadModel("assets/models/first_model_retargeted.glb");
              //     model1State
              //         .loadModel("assets/models/second_model_retargeted.glb");
              //   });
              //   // isMixamoModel = false;
              // } else {
              //   setState(() {
              //     model0State
              //         .loadModel("assets/models/first_model_mixamoed.glb");
              //     model1State
              //         .loadModel("assets/models/second_model_mixamoed.glb");
              //   });
              // }
              // isMixamoModel = !isMixamoModel;
              if (isMixamoModel) {
                model0State
                    .loadModel("assets/models/first_model_retargeted.glb");
                model1State
                    .loadModel("assets/models/second_model_retargeted.glb");
              } else {
                model0State.loadModel("assets/models/first_model_mixamoed.glb");
                model1State
                    .loadModel("assets/models/second_model_mixamoed.glb");
              }
              setState(() {
                isMixamoModel = !isMixamoModel;
              });
              debugPrint("Switched. Is Mixamo? $isMixamoModel");
            },
            label: Text("Switch model"),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 8,
            children: [
              IconButton(
                onPressed: () async {
                  _playAnimation(widget.controller1!, "jump",
                      statement:
                          'document.querySelector("model-viewer").cameraOrbit = "-90deg 90deg 1m";' +
                              'document.querySelector("model-viewer").cameraTarget = ("-4.5m 1.6m 1m");');
                },
                icon: Icon(Icons.swipe_up),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      // Rotate Model 2 left
                      // widget.controller1?.runJavaScript(
                      //     '''document.querySelector("model-viewer").cameraTarget = ("4.5m 1.5m 0m");''');
                      _playAnimation(widget.controller1!, "talk",
                          statement:
                              'document.querySelector("model-viewer").cameraOrbit = ("90deg 90deg 3m");' +
                                  'document.querySelector("model-viewer").cameraTarget = ("4m 1.5m 0m");');
                      // widget.controller1?.setCameraOrbit(-.1, 45.0, 2.0);
                    },
                    icon: Icon(Icons.swipe_left),
                  ),
                  IconButton(
                    onPressed: () async {
                      _playAnimation(widget.controller1!,
                          isMixamoModel ? "crouch" : "idle",
                          statement:
                              'document.querySelector("model-viewer").cameraOrbit = "-90deg 90deg 1m";' +
                                  'document.querySelector("model-viewer").cameraTarget = ("-4.5m 1.6m 1m");');
                    },
                    icon: Icon(Icons.swipe_down),
                  ),
                  IconButton(
                    onPressed: () {
                      // Rotate Model 2 right
                      _playAnimation(widget.controller1!, "idle",
                          statement:
                              'document.querySelector("model-viewer").cameraOrbit = "-90deg 90deg 1m";' +
                                  'document.querySelector("model-viewer").cameraTarget = ("-4.5m 1.4m 0m");');
                      // widget.controller1?.setCameraOrbit(10.0, 45.0, 2.0);
                    },
                    icon: Icon(Icons.swipe_right),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
