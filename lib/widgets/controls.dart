import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Rotation/Jump Controls
class ModelControls extends StatefulWidget {
  const ModelControls({super.key});

  @override
  State<ModelControls> createState() => _ModelControlsState();
}

class _ModelControlsState extends State<ModelControls> {
  bool isRightFABExpanded = false, isLeftFABExpanded = false;

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
        // ref.read(modelProvider(modelId).notifier).loadModel(path);
      }
    } catch (e) {
      debugPrint("File picker error: $e");
    }
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
              AnimatedSlide(
                duration: const Duration(milliseconds: 150),
                offset: isLeftFABExpanded ? Offset.zero : const Offset(0, 1),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: isLeftFABExpanded ? 1.0 : 0.0,
                  child: FloatingActionButton.extended(
                    onPressed: () {},
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
                    onPressed: () {},
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
                    onPressed: () {},
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
                    onPressed: () {},
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
                    onPressed: () {},
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
                    onPressed: () {},
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
