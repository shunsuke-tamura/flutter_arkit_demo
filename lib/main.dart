import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late ARKitController arKitController;
  ARKitNode? hand;

  @override
  void dispose() {
    arKitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ARKitSceneView(
        configuration: ARKitConfiguration.bodyTracking,
        onARKitViewCreated: onARKitViewCreated,
      ),
    );
  }

  void onARKitViewCreated(ARKitController arKitController) {
    this.arKitController = arKitController;
    this.arKitController.onAddNodeForAnchor = _handleAddAnchor;
    this.arKitController.onUpdateNodeForAnchor = _handleUpdateAnchor;
  }

  void _handleAddAnchor(ARKitAnchor anchor) {
    if (anchor is! ARKitBodyAnchor) {
      return;
    }
    final transform =
        anchor.skeleton.modelTransformsFor(ARKitSkeletonJointName.head);
    hand = _createSphere(transform!);
    arKitController.add(hand!, parentNodeName: anchor.nodeName);
  }

  ARKitNode _createSphere(Matrix4 transform) {
    final position = Vector3(
      transform.getColumn(3).x,
      transform.getColumn(3).y,
      transform.getColumn(3).z,
    );
    return ARKitNode(geometry: ARKitSphere(radius: 0.1), position: position);
  }

  void _handleUpdateAnchor(ARKitAnchor anchor) {
    if (anchor is ARKitBodyAnchor && mounted) {
      final transform =
          anchor.skeleton.modelTransformsFor(ARKitSkeletonJointName.head)!;
      final position = Vector3(
        transform.getColumn(3).x,
        transform.getColumn(3).y,
        transform.getColumn(3).z,
      );
      hand?.position = position;
    }
  }
}
