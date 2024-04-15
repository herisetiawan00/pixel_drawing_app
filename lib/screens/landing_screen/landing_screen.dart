import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:pixel_drawing_app/screens/editor_screen/editor_data.dart';
import 'package:pixel_drawing_app/screens/routes/routes_constants.dart';
import 'package:pixel_drawing_app/screens/widgets/menu_bar/menu_bar_widget.dart';
import 'package:pixel_drawing_app/screens/widgets/new_file/new_file_widget.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const MenuBarWidget(),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: DropTarget(
                    enable: true,
                    onDragDone: (detail) async {
                      final file = detail.files.firstOrNull;
                      final result = await EditorData.instance.initializeFile(
                        XFile(file?.path ?? ''),
                      );
                      if (result && context.mounted) {
                        Navigator.of(context).pushNamed(RouteList.editor);
                      }
                    },
                    child: GestureDetector(
                      onTap: () async {
                        final result = await EditorData.instance.openProject();
                        if (result && context.mounted) {
                          Navigator.of(context).pushNamed(RouteList.editor);
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.all(44),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black12,
                            width: 5,
                          ),
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: const Center(
                          child: Text('Drop file or click to Open'),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 200,
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.teal,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      MaterialButton(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        onPressed: () => NewFileWidget.createDialog(context),
                        child: const Text(
                          'Create new project',
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      MaterialButton(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        onPressed: () async {
                          final result =
                              await EditorData.instance.openProject();
                          if (result && context.mounted) {
                            Navigator.of(context).pushNamed(RouteList.editor);
                          }
                        },
                        child: const Text(
                          'Open project',
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Spacer(),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.settings,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
