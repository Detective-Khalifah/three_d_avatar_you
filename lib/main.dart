import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:three_d_avatar_you/models/three_d_obj_model.dart';
import 'package:three_d_avatar_you/providers/model_provider.dart';
import 'package:three_d_avatar_you/widgets/controls.dart';
import 'package:three_d_avatar_you/widgets/model_viewer.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '3D Avatar You Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  Flutter3DController? _controller0;
  Flutter3DController? _controller1;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: Text("3D Avatar You"),
          ),
          body: SizedBox.fromSize(
            size: Size(
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height,
            ),
            // width: MediaQuery.of(context).size.width,
            // height: MediaQuery.of(context).size.height,
            child: Column(
              // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
              // action in the IDE, or press "p" in the console), to see the
              // wireframe for each widget.
              children: <Widget>[
                // Model 1 (Left)
                Row(
                  mainAxisSize: MainAxisSize.max,
                  // crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ModelViewer(
                        modelId: 0,
                        onControllerCreated: (controller) {
                          Future.microtask(() {
                            setState(() {
                              _controller0 = controller;
                            });
                          });
                        },
                      ),
                    ),
                    // Model 2 (Right)
                    Expanded(
                      child: ModelViewer(
                        modelId: 1,
                        onControllerCreated: (controller) {
                          Future.microtask(() {
                            setState(() {
                              _controller1 = controller;
                            });
                          });
                          // setState(() {
                          //   _controller1 = controller;
                          // });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          floatingActionButton:
              // _controller0 != null && _controller1 != null ?
              ControlFABs(controller0: _controller0, controller1: _controller1)
          // : null,
          // This trailing comma makes auto-formatting nicer for build methods.
          ),
    );
  }
}
