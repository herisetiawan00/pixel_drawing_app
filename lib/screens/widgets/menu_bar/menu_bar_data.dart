import 'package:flutter/material.dart';
import 'package:pixel_drawing_app/screens/editor_screen/editor_data.dart';
import 'package:pixel_drawing_app/screens/widgets/new_file/new_file_widget.dart';

typedef MenuBarFn = void Function(BuildContext context);

class MenuBarData {
  final String title;
  final List<MenuBarData> entries;
  final MenuBarFn? onClick;
  final bool condition;

  MenuBarData({
    required this.title,
    this.entries = const [],
    this.onClick,
    this.condition = true,
  })  : assert(
          entries.isEmpty || onClick == null,
          'do not define both entries and onClick',
        ),
        assert(
          entries.isNotEmpty || onClick != null,
          'define one of entries or onClick',
        );
}

class MenuBarEntries {
  static List<MenuBarData> getAll() => [
        MenuBarData(
          title: '&File',
          entries: [
            MenuBarData(
              title: '&New...',
              onClick: NewFileWidget.createDialog,
            ),
            MenuBarData(
              title: '&Open Project...',
              onClick: (context) {},
            ),
            MenuBarData(
              title: '&Save Project...',
              onClick: (context) {},
            ),
            MenuBarData(
              title: '&Close...',
              onClick: (context) {},
            ),
            MenuBarData(
              title: '&Export...',
              onClick: (context) {},
            ),
          ],
        ),
        MenuBarData(
          title: '&View',
          entries: [
            MenuBarData(
              title: '&Appearance',
              entries: [
                MenuBarData(
                  title: '&Menu Bar',
                  onClick: (context) {},
                ),
                MenuBarData(
                  title: 'F&ull Screen',
                  onClick: (context) {},
                ),
                MenuBarData(
                  title: 'Show &Grid',
                  onClick: (context) => EditorData.instance.showGrid(),
                  condition: !EditorData.instance.grid
                ),
                MenuBarData(
                  title: 'Hide &Grid',
                  onClick: (context) => EditorData.instance.hideGrid(),
                  condition: EditorData.instance.grid
                )
              ],
            ),
          ],
        ),
      ];
}
