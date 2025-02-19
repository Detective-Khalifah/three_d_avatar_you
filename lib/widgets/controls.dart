import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
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
    return Column(
      children: [
        // ExpansionTile(title: Text("Model Controls")),
        // Controls
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _pickModel(context, 0),
                child: const Text('Load Model 1'),
              ),
              ElevatedButton(
                onPressed: () => _pickModel(context, 1),
                child: const Text('Load Model 2'),
              ),
            ],
          ),
        ),
        // Rotation/Jump Controls
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () =>
                    ref.read(modelProvider(0).notifier).rotate(-0.2),
                label: const Text('← Rotate Left'),
                icon: Icon(Icons.arrow_left),
              ),
              ElevatedButton.icon(
                onPressed: () => ref.read(modelProvider(0).notifier).jump(),
                label: const Text('Jump'),
                icon: Icon(Icons.arrow_upward),
              ),
              ElevatedButton.icon(
                onPressed: () =>
                    ref.read(modelProvider(0).notifier).rotate(0.2),
                label: const Text('Rotate Right'),
                icon: Icon(Icons.arrow_right),
              ),
            ],
          ),
        )
      ],
    );
  }
}
