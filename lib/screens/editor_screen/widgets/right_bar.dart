import 'package:flutter/material.dart';
import 'package:pixel_drawing_app/screens/editor_screen/editor_data.dart';

enum RightBarTab {
  layers(title: 'Layers', builder: _layersBuilder),
  properties(title: 'Properties', builder: _propertiesBuilder);

  final String title;
  final WidgetBuilder builder;

  const RightBarTab({required this.title, required this.builder});

  static Widget _layersBuilder(BuildContext context) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(8),
      color: Colors.teal.shade600,
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: EditorData.instance.layers.keys
                    .map(
                      (text) => Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Text(text),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                color: Colors.white,
                style: const ButtonStyle(
                  fixedSize: MaterialStatePropertyAll(
                    Size.square(8),
                  ),
                ),
                onPressed: () {},
                icon: const Icon(Icons.add),
              ),
              IconButton(
                color: Colors.white,
                style: const ButtonStyle(
                  fixedSize: MaterialStatePropertyAll(
                    Size.square(8),
                  ),
                ),
                onPressed: () {},
                icon: const Icon(Icons.arrow_upward),
              ),
              IconButton(
                color: Colors.white,
                style: const ButtonStyle(
                  fixedSize: MaterialStatePropertyAll(
                    Size.square(8),
                  ),
                ),
                onPressed: () {},
                icon: const Icon(Icons.arrow_downward),
              ),
              IconButton(
                color: Colors.white,
                style: const ButtonStyle(
                  fixedSize: MaterialStatePropertyAll(
                    Size.square(8),
                  ),
                ),
                onPressed: () {},
                icon: const Icon(Icons.visibility),
              ),
              IconButton(
                color: Colors.white,
                style: const ButtonStyle(
                  fixedSize: MaterialStatePropertyAll(
                    Size.square(8),
                  ),
                ),
                onPressed: () {},
                icon: const Icon(Icons.delete),
              ),
            ],
          ),
        ],
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
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
            // height: 20,
            child: Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 16,
                    children: RightBarTab.values
                        .map(
                          (tab) => GestureDetector(
                            onTap: () {
                              if (_currentTab.value == tab) {
                                return _currentTab.value = null;
                              }
                              _currentTab.value = tab;
                            },
                            child: Text(
                              tab.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w200,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
