import 'package:flutter/material.dart';
import 'package:pixel_drawing_app/screens/editor_screen/editor_data.dart';
import 'package:pixel_drawing_app/screens/editor_screen/widgets/drawing_canvas.dart';
import 'package:pixel_drawing_app/screens/editor_screen/widgets/editor_tool.dart';
import 'package:pixel_drawing_app/screens/editor_screen/widgets/right_bar.dart';
import 'package:pixel_drawing_app/screens/widgets/menu_bar/menu_bar_widget.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  @override
  void dispose() {
    EditorData.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
          MenuBarWidget(),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      DrawingCanvas(),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: EditorTool(),
                      ),
                    ],
                  ),
                ),
                RightBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
