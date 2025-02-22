import 'package:flutter/material.dart';
// import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:three_d_avatar_you/providers/model_provider.dart';

class ThreeDModelViewer extends ConsumerStatefulWidget {
  final Function(WebViewController)? onControllerCreated;
  final int modelId;

  const ThreeDModelViewer({
    required this.onControllerCreated,
    required this.modelId,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<ThreeDModelViewer> createState() => _ModelViewerState();
}

class _ModelViewerState extends ConsumerState<ThreeDModelViewer> {
  late final WebViewController _controller; // = Flutter3DController();

  @override
  void initState() {
    super.initState();
    // _controller = Flutter3DController();
    // // Notify the parent widget that the controller is created
    // widget.onControllerCreated?.call(_controller);
  }

  @override
  void dispose() {
    _controller.runJavaScript('window.stop();');
    _controller.clearCache();
    _controller.clearLocalStorage();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    late final modelState = ref.watch(modelProvider(widget.modelId));
    late final modelNotifier = ref.read(modelProvider(widget.modelId).notifier);

    if (modelState.modelPath != null) {
      // modelNotifier.rotate();
      // controller.loadModel(modelPath: modelState.modelPath!);
      // controller.setRotation(y: modelState.rotationY);
    }
    //  else {
    //   modelNotifier.loadModel("assets/models/first_model.glb");
    // }

    return Container(
      // height: MediaQuery.of(context).size.width * 0.9,
      // width: MediaQuery.of(context).size.width * 0.5,
      width: double.maxFinite,
      // decoration: BoxDecoration(
      //   border: Border.symmetric(horizontal: Colors.grey),
      // ),
      child: modelState.modelPath != null
          ? ModelViewer(
              cameraControls: false, // Disable camera controls
              // controller: _controller,
              src: modelState.modelPath!, // Path to the .glb file
              // onError: (error) {
              //   debugPrint("`ModelViewer`: Error loading model");
              // },
              alt: "3D Model", // Alt text for accessibility
              // animationName: 'Standing_Idle_003', // Default animation
              ar: false, // Disable AR mode
              // arModes: ["scene-viewer"],
              autoRotate: false, // Disable auto-rotation
              backgroundColor: Colors.grey, // Background color
              cameraTarget: "auto",
              fieldOfView: "auto",
              // minCameraOrbit:
              //     "auto", // Conservative value to ensure camera never enters the model
              cameraOrbit: "0deg 90deg 15m", // 75deg works too
              scale: "1 1 1",
              // skyboxImage: "assets/images/poly_haven_studio_1k.hdr",
              environmentImage: "legacy",
              onWebViewCreated: (controller) async {
                // Notify the parent widget that the controller is created
                widget.onControllerCreated?.call(controller);
                controller.runJavaScript(
                    '''const modelViewer = document.querySelector('model-viewer');''');
                // controller.runJavaScript(
                //     '''document.querySelector("model-viewer").cameraOrbit = "0deg 75deg 3m";''');

                // debugPrint(
                //     "`Model with address $controller succesfully loaded.");
                // debugPrint("Model rotation: ${modelState.rotationY}");
                // modelNotifier.rotate(10);
                // final anims = await _controller.getAvailableAnimations();

                // debugPrint(
                //     "Available animations for ${widget.modelId}: $anims");
                // debugPrint("Model rotation: ${modelState.rotationY}");
                // modelNotifier.rotate(-10);

                // _controller.playAnimation();
                // if (modelState.isJumping) {
                //   _controller.playAnimation(animationName: "jump");
                // } else {
                //   _controller.playAnimation(animationName: "jump");
                //   // _controller.playAnimation(animationName: "idle");
                // }
              },
            )
          : Center(child: Text("No model loaded")),
    );
  }
}
