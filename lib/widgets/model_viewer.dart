import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:three_d_avatar_you/providers/model_provider.dart';

class ModelViewer extends ConsumerStatefulWidget {
  final int modelId;
  const ModelViewer({required this.modelId, Key? key}) : super(key: key);

  @override
  ConsumerState<ModelViewer> createState() => _ModelViewerState();
}

class _ModelViewerState extends ConsumerState<ModelViewer> {
  final _controller = Flutter3DController();

  @override
  void initState() {
    super.initState();
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
      height: MediaQuery.of(context).size.width * 0.9,
      // width: MediaQuery.of(context).size.width * 0.5,
      width: double.maxFinite,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
      ),
      child: modelState.modelPath != null
          ? Flutter3DViewer(
              enableTouch: false,
              controller: _controller,
              src: modelState.modelPath!,
              // src: "assets/models/67b371d547fa86b2d94ed8ad.glb",
              // src: "assets/models/first_model.glb",
              onError: (error) {
                debugPrint("`ModelViewer`: Error loading model");
              },
              onLoad: (modelAddress) async {
                debugPrint(
                    "`Model with address $modelAddress succesfully loaded.");
                debugPrint("Model rotation: ${modelState.rotationY}");
                modelNotifier.rotate(10);
                final anims = await _controller.getAvailableAnimations();

                debugPrint("Available animations: $anims");
                debugPrint("Model rotation: ${modelState.rotationY}");
                // modelNotifier.rotate(-10);

                _controller.playAnimation();
                if (modelState.isJumping) {
                  _controller.playAnimation(animationName: "jump");
                } else {
                  _controller.playAnimation(animationName: "jump");
                  // _controller.playAnimation(animationName: "idle");
                }
              },
              onProgress: (progressValue) =>
                  debugPrint("`ModelViewer`: Loading model -- $progressValue"),
            )
          : Center(child: Text("No model loaded")),
    );
  }
}
