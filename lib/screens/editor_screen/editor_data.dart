import 'dart:convert';
import 'dart:typed_data';
import 'package:file_selector/file_selector.dart';
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

typedef Canvas = List<Color>;

class CanvasLayer {
  late int order;
  late Canvas canvas;

  late String name;
  bool hidden = false;

  CanvasLayer({
    required this.order,
    required this.name,
    required this.canvas,
  });

  CanvasLayer.fromJson(Map<String, dynamic> json)
      : order = json['order'],
        name = json['name'],
        hidden = json['hidden'],
        canvas = [] {
    final splittedCanvas = (json['canvas'] as String).split(',');
    final colors = json['colors'] as List;
    for (final rawData in splittedCanvas) {
      if (rawData.startsWith('~')) {
        canvas.addAll(
          List.generate(
            int.parse(rawData.substring(1)),
            (index) => Colors.transparent,
          ),
        );
      } else {
        canvas.add(
          Color(
            colors[int.parse(rawData)],
          ),
        );
      }
    }
  }

  Map<String, dynamic> toJson() {
    final colors = [];
    final minifiedCanvasV2 = [];
    int zeroCounter = 0;

    for (int i = 0; i < canvas.length; i++) {
      final color = canvas[i];

      final isLastIndex = i == canvas.length - 1;

      if (color.value == 0) {
        zeroCounter++;
        if (isLastIndex) {
          minifiedCanvasV2.add('~$zeroCounter');
          zeroCounter = 0;
        }
        continue;
      }

      if (zeroCounter > 0) {
        minifiedCanvasV2.add('~$zeroCounter');
        zeroCounter = 0;
      }

      if (color.value != 0 && !colors.contains(color.value)) {
        colors.add(color.value);
      }

      minifiedCanvasV2.add(colors.indexOf(color.value).toString());
    }

    final json = {
      'order': order,
      'name': name,
      'canvas': minifiedCanvasV2.join(','),
      'colors': colors,
      'hidden': hidden,
    };

    return json;
  }
}

class EditorData {
  static EditorData? _instance;

  late String _fileName;
  late String _directory;
  late Size _size;
  late Canvas _emptyCanvas;
  late List<CanvasLayer> _layers;
  late String _currentLayer;

  Color _primaryColor = Colors.black;
  Color _secondaryColor = Colors.white;

  bool _grid = true;
  bool _initialized = false;

  final WidgetNotifier _canvasNotifier = WidgetNotifier();
  final WidgetNotifier _colorNotifier = WidgetNotifier();
  final WidgetNotifier _actionNotifier = WidgetNotifier();
  final WidgetNotifier _globalNotifier = WidgetNotifier();

  EditorAction _action = EditorAction.pan;

  factory EditorData([bool reset = false]) {
    if (reset) _instance = EditorData._();
    _instance ??= EditorData._();

    return _instance!;
  }

  EditorData initialize(
    Size size,
    String directory, {
    List<CanvasLayer>? layers,
  }) {
    _size = size;
    _fileName = directory.split('/').last;
    _directory = directory.replaceFirst(_fileName, '');
    final drawingLength = (_size.width * _size.height).toInt();
    _emptyCanvas = List<Color>.generate(
      drawingLength,
      (index) => Colors.transparent,
    );

    if (layers != null) {
      _layers = layers;
      _currentLayer = _layers.last.name;
    } else {
      _currentLayer = 'default';
      _emptyCanvas = List<Color>.generate(
        drawingLength,
        (index) => Colors.transparent,
      );

      _layers = [
        CanvasLayer(
          order: 0,
          name: _currentLayer,
          canvas: List.from(_emptyCanvas),
        ),
      ];
    }

    _initialized = true;

    return EditorData();
  }

  EditorData._();

  Size get size => _size;

  WidgetNotifier get canvasNotifier => _canvasNotifier;

  WidgetNotifier get colorNotifier => _colorNotifier;

  WidgetNotifier get actionNotifier => _actionNotifier;

  WidgetNotifier get globalNotifier => _globalNotifier;

  bool get initialized => _initialized;

  List<CanvasLayer> get layers => _layers;

  String get currentLayer => _currentLayer;

  CanvasLayer getLayer(String name) => _layers.firstWhere(
        (layer) => layer.name == name,
      );

  Color? getIndex(int index, {String? layer}) {
    if (index < _size.width * _size.height) {
      return getLayer(layer ?? _currentLayer).canvas[index];
    }
    return null;
  }

  void setIndex(int index, {String? layer, Color? color}) {
    getLayer(layer ?? _currentLayer).canvas[index] = color ?? _primaryColor;
    _canvasNotifier.notify();
  }

  static EditorData get instance => EditorData();

  void dispose() {
    canvasNotifier.dispose();
    colorNotifier.dispose();
    actionNotifier.dispose();
    globalNotifier.dispose();
    _instance = EditorData._();
  }

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

  void renameLayer(String oldName, String newName) {
    if (oldName == newName) return;
    _layers.firstWhere((layer) => layer.name == oldName).name = newName;
    if (oldName == _currentLayer) {
      _currentLayer = newName;
    }
    _globalNotifier.notify();
  }

  void focusLayer(String name) {
    _currentLayer = name;
    _globalNotifier.notify();
  }

  void createLayer(String name) {
    _orderLayers();

    _layers.add(
      CanvasLayer(
        order: _layers.last.order + 1,
        name: name,
        canvas: List.from(_emptyCanvas),
      ),
    );
    _currentLayer = name;

    _globalNotifier.notify();
  }

  void _orderLayers() => _layers.sort((a, b) => a.order.compareTo(b.order));

  void changeLayerVisibility(String name) {
    getLayer(name).hidden = !getLayer(name).hidden;

    _globalNotifier.notify();
  }

  void moveLayerUp() {
    _orderLayers();
    final currentIndex = getLayer(currentLayer).order;
    final largestIndex = layers.last.order;

    if (currentIndex < largestIndex) {
      layers.firstWhere((layer) => layer.order == currentIndex + 1).order =
          currentIndex;

      getLayer(currentLayer).order = currentIndex + 1;
    }
    _orderLayers();
    _globalNotifier.notify();
  }

  void moveLayerDown() {
    final currentIndex = getLayer(currentLayer).order;
    final largestIndex = layers.first.order;

    if (currentIndex > largestIndex) {
      layers.firstWhere((layer) => layer.order == currentIndex - 1).order =
          currentIndex;

      getLayer(currentLayer).order = currentIndex - 1;
    }
    _orderLayers();
    _globalNotifier.notify();
  }

  Future<bool> initializeFile(XFile? file) async {
    if (file == null) {
      return false;
    }

    final contents = await file.readAsString();
    final decrypted = utf8.fuse(base64).decode(contents);
    final json = jsonDecode(decrypted);

    final sizeJson = json['size'];

    final size = Size(
      sizeJson['width'],
      sizeJson['height'],
    );

    final List<CanvasLayer> layers = [];

    json['layers'].forEach(
      (layer) => layers.add(
        CanvasLayer.fromJson(layer),
      ),
    );
    instance.initialize(size, file.path, layers: layers);

    return true;
  }

  Future<bool> openProject() async {
    const XTypeGroup typeGroup = XTypeGroup(
      label: 'Pixel Draw',
      extensions: <String>['hpd'],
    );
    final XFile? file = await openFile(
      acceptedTypeGroups: <XTypeGroup>[typeGroup],
    );

    return initializeFile(file);
  }

  void saveProject() async {
    final rawData = {
      'size': {
        'width': _size.width,
        'height': _size.height,
      },
      'layers': _layers.map((layer) => layer.toJson()).toList(),
    };

    final contents = utf8.fuse(base64).encode(jsonEncode(rawData));

    final FileSaveLocation? result = await getSaveLocation(
      suggestedName: _fileName,
      initialDirectory: _directory,
    );
    if (result == null) {
      return;
    }

    final Uint8List fileData = Uint8List.fromList(contents.codeUnits);
    const String mimeType = 'text/plain';
    final XFile textFile = XFile.fromData(
      fileData,
      mimeType: mimeType,
      name: _fileName,
    );
    await textFile.saveTo(result.path);
  }
}
