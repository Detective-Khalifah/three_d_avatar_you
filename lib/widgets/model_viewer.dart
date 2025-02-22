import 'package:flutter/material.dart';
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
    super.key,
  });

  @override
  ConsumerState<ThreeDModelViewer> createState() => _ModelViewerState();
}

class _ModelViewerState extends ConsumerState<ThreeDModelViewer> {
  late final WebViewController _controller;

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

    return Container(
      // height: MediaQuery.of(context).size.width * 0.9,
      // width: MediaQuery.of(context).size.width * 0.5,
      width: double.maxFinite,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
      ),
      child: modelState.modelPath != null
          ? ModelViewer(
              cameraControls: false, // Disable camera controls
              // controller: _controller,
              src: modelState.modelPath!, // Path to the .glb file
              key: ObjectKey(modelState.modelPath),
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
              // scale: "1 1 1",
              // skyboxImage: "assets/images/poly_haven_studio_1k.hdr",
              // environmentImage: "legacy",
              onWebViewCreated: (controller) async {
                // Notify the parent widget that the controller is created
                widget.onControllerCreated?.call(controller);
                controller.setJavaScriptMode(JavaScriptMode.unrestricted);
                controller.runJavaScript(
                    '''const modelViewer = document.querySelector('model-viewer');''');
                // controller.runJavaScript(
                //     '''document.querySelector("model-viewer").cameraOrbit = "0deg 75deg 3m";''');
              },
            )
          : Center(child: Text("No model loaded")),
    );
  }
}
