import 'package:flutter/material.dart';
import 'package:pixel_drawing_app/screens/widgets/base_layout_widget.dart';

class EditorLayer extends BaseLayoutWidget {
  const EditorLayer({super.key});

  @override
  State<EditorLayer> createState() => _EditorLayerState();

  @override
  String get identifier => 'editor_layer';
}

class _EditorLayerState extends State<EditorLayer> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
