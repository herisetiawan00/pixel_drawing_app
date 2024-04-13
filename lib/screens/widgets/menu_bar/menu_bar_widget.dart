import 'package:flutter/material.dart';
import 'package:pixel_drawing_app/screens/editor_screen/editor_data.dart';
import 'package:pixel_drawing_app/screens/widgets/menu_bar/menu_bar_data.dart';

class MenuBarWidget extends StatelessWidget {
  const MenuBarWidget({super.key});

  Widget Function(MenuBarData data) _buildMenu(BuildContext context) {
    return (MenuBarData data) {
      if (!data.condition) {
        return Container();
      }
      final label = MenuAcceleratorLabel(data.title);
      if (data.entries.isNotEmpty) {
        return SubmenuButton(
          alignmentOffset: const Offset(0, -10),
          menuChildren: data.entries.map(_buildMenu(context)).toList(),
          child: label,
        );
      }
      return MenuItemButton(
        onPressed: () => data.onClick?.call(context),
        child: label,
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ListenableBuilder(
            listenable: EditorData.instance.globalNotifier,
            builder: (BuildContext context, Widget? child) {
              final menuEntries = MenuBarEntries.getAll();
              return MenuBar(
                style: const MenuStyle(
                  fixedSize: MaterialStatePropertyAll(Size.fromHeight(20)),
                ),
                children: menuEntries
                    .map(
                      _buildMenu(context),
                    )
                    .toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}
