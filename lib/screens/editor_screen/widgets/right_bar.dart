import 'package:flutter/material.dart';
import 'package:pixel_drawing_app/screens/editor_screen/editor_data.dart';
import 'package:uuid/uuid.dart';

enum RightBarTab {
  layers(title: 'Layers', builder: _layersBuilder),
  properties(title: 'Properties', builder: _propertiesBuilder);

  final String title;
  final WidgetBuilder builder;

  const RightBarTab({required this.title, required this.builder});

  static Widget _layersBuilder(BuildContext context) {
    final ValueNotifier<String?> currentEdit = ValueNotifier(null);
    final TextEditingController controller = TextEditingController();
    const Uuid uuid = Uuid();

    Widget buildIconButton(
      IconData icon,
      VoidCallback onPressed,
    ) =>
        IconButton(
          color: Colors.white,
          onPressed: onPressed,
          icon: Icon(
            icon,
            size: 16,
          ),
        );

    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.teal.shade600,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListenableBuilder(
          listenable: EditorData.instance.globalNotifier,
          builder: (context, _) {
            final layers = EditorData.instance.layers.reversed;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...layers.map(
                  (layer) {
                    final key = uuid.v4();
                    return ValueListenableBuilder<String?>(
                      valueListenable: currentEdit,
                      builder: (context, value, child) {
                        Widget widget = child!;
                        if (value == key) {
                          widget = Baseline(
                            baseline: 12,
                            baselineType: TextBaseline.alphabetic,
                            // color: Colors.red,
                            child: TextField(
                              controller: controller,
                              textAlignVertical: TextAlignVertical.bottom,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  suffix: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          if (controller.text.isNotEmpty) {
                                            EditorData.instance.renameLayer(
                                              layer.name,
                                              controller.text,
                                            );

                                            controller.text = '';
                                            currentEdit.value = null;
                                          }
                                        },
                                        child: const Icon(
                                          Icons.check,
                                          size: 12,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          controller.text = '';
                                          currentEdit.value = null;
                                        },
                                        child: const Icon(
                                          Icons.close,
                                          size: 12,
                                        ),
                                      ),
                                    ],
                                  )),
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                              onSubmitted: (text) {
                                if (text.isNotEmpty) {
                                  EditorData.instance.renameLayer(
                                    layer.name,
                                    text,
                                  );

                                  controller.text = '';
                                  currentEdit.value = null;
                                }
                              },
                            ),
                          );
                        }
                        return Opacity(
                          opacity: layer.hidden ? 0.5 : 1,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                GestureDetector(
                                  onTap: () => EditorData.instance
                                      .changeLayerVisibility(layer.name),
                                  child: Icon(
                                    layer.hidden
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    size: 12,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 120,
                                  child: widget,
                                )
                                // widget,
                              ],
                            ),
                          ),
                        );
                      },
                      child: GestureDetector(
                        onTap: () => EditorData.instance.focusLayer(layer.name),
                        onDoubleTap: () {
                          currentEdit.value = key;
                          controller.text = layer.name;
                        },
                        child: Text(
                          layer.name,
                          style: TextStyle(
                            color:
                                layer.name == EditorData.instance.currentLayer
                                    ? Colors.teal
                                    : Colors.black,
                            fontWeight:
                                layer.name == EditorData.instance.currentLayer
                                    ? FontWeight.w500
                                    : FontWeight.w400,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const Spacer(),
                Container(
                  color: Colors.teal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      buildIconButton(Icons.add, () {
                        const defaultLayerName = 'new layer';
                        EditorData.instance.createLayer(defaultLayerName);
                        controller.text = defaultLayerName;
                        currentEdit.value = defaultLayerName;
                      }),
                      buildIconButton(
                        Icons.arrow_upward,
                        EditorData.instance.moveLayerUp,
                      ),
                      buildIconButton(
                        Icons.arrow_downward,
                        EditorData.instance.moveLayerDown,
                      ),
                      buildIconButton(Icons.delete, () {}),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  static Widget _propertiesBuilder(BuildContext context) {
    return Container();
  }
}

class RightBar extends StatefulWidget {
  const RightBar({super.key});

  @override
  State<RightBar> createState() => _RightBarState();
}

class _RightBarState extends State<RightBar> {
  final ValueNotifier<RightBarTab?> _currentTab = ValueNotifier(null);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ValueListenableBuilder<RightBarTab?>(
          valueListenable: _currentTab,
          builder: (context, tab, _) => Visibility(
            visible: tab != null,
            child: tab?.builder(context) ?? const SizedBox.shrink(),
          ),
        ),
        RotatedBox(
          quarterTurns: 3,
          child: Container(
            color: Colors.teal.shade800,

            // height: 20,
            child: Row(
              children: RightBarTab.values
                  .map(
                    (tab) => GestureDetector(
                      onTap: () {
                        if (_currentTab.value == tab) {
                          return _currentTab.value = null;
                        }
                        _currentTab.value = tab;
                      },
                      child: ValueListenableBuilder<RightBarTab?>(
                        valueListenable: _currentTab,
                        builder: (context, current, child) => Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 2,
                            horizontal: 8,
                          ),
                          color: current == tab
                              ? Colors.white30
                              : Colors.transparent,
                          child: child,
                        ),
                        child: Text(
                          tab.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w200,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
