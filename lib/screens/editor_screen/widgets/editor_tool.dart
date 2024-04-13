import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:pixel_drawing_app/screens/editor_screen/editor_data.dart';
import 'package:pixel_drawing_app/screens/widgets/base_layout_widget.dart';

class EditorTool extends BaseLayoutWidget {
  const EditorTool({super.key});

  @override
  State<EditorTool> createState() => _EditorToolState();

  @override
  String get identifier => 'editor_tool';
}

class _EditorToolState extends State<EditorTool> {
  Future<bool> colorPickerDialog({
    required Color color,
    required void Function(Color) onColorChanged,
  }) async {
    return ColorPicker(
      color: color,
      onColorChanged: onColorChanged,
      width: 40,
      height: 40,
      borderRadius: 4,
      spacing: 5,
      runSpacing: 5,
      wheelDiameter: 155,
      heading: Text(
        'Select color',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subheading: Text(
        'Select color shade',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      wheelSubheading: Text(
        'Selected color and its shades',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      showMaterialName: true,
      showColorName: true,
      showColorCode: true,
      copyPasteBehavior: const ColorPickerCopyPasteBehavior(
        longPressMenu: true,
      ),
      materialNameTextStyle: Theme.of(context).textTheme.bodySmall,
      colorNameTextStyle: Theme.of(context).textTheme.bodySmall,
      colorCodeTextStyle: Theme.of(context).textTheme.bodyMedium,
      colorCodePrefixStyle: Theme.of(context).textTheme.bodySmall,
      selectedPickerTypeColor: Colors.white,
      pickersEnabled: const <ColorPickerType, bool>{
        ColorPickerType.both: false,
        ColorPickerType.primary: true,
        ColorPickerType.accent: true,
        ColorPickerType.bw: false,
        ColorPickerType.custom: true,
        ColorPickerType.wheel: true,
      },
    ).showPickerDialog(
      context,
      actionsPadding: const EdgeInsets.all(16),
      backgroundColor: Colors.white,
      constraints: const BoxConstraints(
        minHeight: 480,
        minWidth: 854,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 2,
            spreadRadius: 2,
            offset: Offset(2, 2),
          ),
        ],
      ),
      width: 52,
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...EditorAction.values.map(
            (action) => ListenableBuilder(
              listenable: EditorData.instance.actionNotifier,
              builder: (context, child) {
                final isSelected = action == EditorData.instance.action;
                return Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.teal : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    color: isSelected ? Colors.white : Colors.black,
                    onPressed: () => EditorData.instance.action = action,
                    icon: child!,
                  ),
                );
              },
              child: Icon(
                action.icon,
                size: 20,
              ),
            ),
          ),
          IconButton(
            onPressed: EditorData.instance.swapColor,
            icon: const Icon(
              Icons.swap_horiz_rounded,
              size: 20,
            ),
          ),
          LayoutBuilder(
            builder: (context, constrants) {
              return SizedBox(
                height: constrants.maxWidth,
                width: constrants.maxWidth,
                child: ListenableBuilder(
                  listenable: EditorData.instance.colorNotifier,
                  builder: (context, child) => Stack(
                    children: [
                      Align(
                        alignment: Alignment.bottomRight,
                        child: GestureDetector(
                          onTap: () => colorPickerDialog(
                            color: EditorData.instance.secondaryColor,
                            onColorChanged: (color) =>
                                EditorData.instance.secondaryColor = color,
                          ),
                          child: Container(
                            height: constrants.maxWidth - 12,
                            width: constrants.maxWidth - 12,
                            decoration: BoxDecoration(
                              border: Border.all(),
                              color: EditorData.instance.secondaryColor,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: GestureDetector(
                          onTap: () => colorPickerDialog(
                            color: EditorData.instance.primaryColor,
                            onColorChanged: (color) =>
                                EditorData.instance.primaryColor = color,
                          ),
                          child: Container(
                            height: constrants.maxWidth - 12,
                            width: constrants.maxWidth - 12,
                            decoration: BoxDecoration(
                              border: Border.all(),
                              color: EditorData.instance.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
