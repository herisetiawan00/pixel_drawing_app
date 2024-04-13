import 'package:flutter/material.dart';
import 'package:pixel_drawing_app/common/utils/widget_notifier.dart';

enum EditorAction {
  pan(Icons.pan_tool),
  draw(Icons.edit),
  delete(Icons.delete),
  eyedrop(Icons.colorize),
  bucket(Icons.format_color_fill);

  final IconData icon;
  const EditorAction(this.icon);
}

class EditorData {
  static EditorData? _instance;

  late Size _size;
  late Map<String, List<Color>> _layers;
  late String _currentLayer;

  Color _primaryColor = Colors.black;
  Color _secondaryColor = Colors.white;

  bool _grid = true;

  final WidgetNotifier _notifier = WidgetNotifier();
  final WidgetNotifier _colorNotifier = WidgetNotifier();
  final WidgetNotifier _actionNotifier = WidgetNotifier();
  final WidgetNotifier _globalNotifier = WidgetNotifier();

  EditorAction _action = EditorAction.pan;

  factory EditorData() {
    _instance ??= EditorData._();
    return _instance!;
  }

  EditorData initialize(
    Size size, {
    List<Color> layer = const [],
  }) {
    final layerBlocks = layer.length;
    final drawingLength = (size.width * size.height).toInt();
    _currentLayer = 'default';
    final defaultLayer = List<Color>.generate(
      drawingLength,
      (index) {
        if (index < layerBlocks) {
          return layer[index];
        }
        return Colors.transparent;
      },
    );
    _layers = {
      _currentLayer: defaultLayer,
    };
    _size = size;

    return EditorData();
  }

  EditorData._();

  Size get size => _size;

  WidgetNotifier get notifier => _notifier;

  WidgetNotifier get colorNotifier => _colorNotifier;

  WidgetNotifier get actionNotifier => _actionNotifier;

  WidgetNotifier get globalNotifier => _globalNotifier;

  Map<String, List<Color>> get layers => _layers;

  List<Color> getLayer(String name) => _layers[name] ?? [];

  Color? getIndex(int index, {String? layer}) {
    if (index < _size.width * _size.height) {
      return getLayer(layer ?? _currentLayer)[index];
    }
    return null;
  }

  void setIndex(int index, { String? layer, Color? color}) {
    getLayer(layer ?? _currentLayer)[index] = color ?? _primaryColor;
    _notifier.notify();
  }

  static EditorData get instance => EditorData();

  Color get primaryColor => _primaryColor;
  set primaryColor(Color color) {
    _primaryColor = color;
    colorNotifier.notify();
  }

  Color get secondaryColor => _secondaryColor;
  set secondaryColor(Color color) {
    _secondaryColor = color;
    colorNotifier.notify();
  }

  void swapColor() {
    final oldPrimaryColor = _primaryColor;
    final oldSecondaryColor = _secondaryColor;

    _primaryColor = oldSecondaryColor;
    _secondaryColor = oldPrimaryColor;

    colorNotifier.notify();
  }

  EditorAction get action => _action;
  set action(EditorAction action) {
    _action = action;
    actionNotifier.notify();
  }

  bool get grid => _grid;

  void showGrid() {
    _grid = true;
    _globalNotifier.notify();
  }

  void hideGrid() {
    _grid = false;
    _globalNotifier.notify();
  }
}
