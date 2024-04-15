import 'package:flutter/material.dart';
import 'package:pixel_drawing_app/screens/editor_screen/editor_data.dart';
import 'package:pixel_drawing_app/screens/widgets/base_layout_widget.dart';

class DrawingCanvas extends BaseLayoutWidget {
  const DrawingCanvas({super.key});

  @override
  State<DrawingCanvas> createState() => _DrawingAreaState();

  @override
  String get identifier => 'drawing_canvas';
}

class _DrawingAreaState extends State<DrawingCanvas> {
  final ValueNotifier<double> sliderValue = ValueNotifier<double>(1);
  final ValueNotifier<bool> showZoom = ValueNotifier<bool>(false);
  final ValueNotifier<Offset> boxPosition = ValueNotifier(Offset.zero);

  bool _isDragging = false;
  bool _initialized = false;

  int _coordinateToIndex(num x, num y) =>
      (y * EditorData.instance.size.width + x).toInt();

  void _fillColor(int index) {
    final targetColor = EditorData.instance.getIndex(index);
    EditorData.instance.setIndex(index);

    final updatedColor = EditorData.instance.getIndex(index);

    if (targetColor == updatedColor) return;

    final row = index % EditorData.instance.size.width == 0
        ? EditorData.instance.size.width
        : index % EditorData.instance.size.width;
    final column = ((index - row) / EditorData.instance.size.width);

    final fillAreas = [
      _coordinateToIndex(row, column - 1),
      _coordinateToIndex(row - 1, column),
      _coordinateToIndex(row + 1, column),
      _coordinateToIndex(row, column + 1),
    ];
    for (var area in fillAreas) {
      if (area.isNegative) {
        continue;
      }
      final areaColor = EditorData.instance.getIndex(area);
      if (areaColor == targetColor) {
        _fillColor(area);
      }
    }
  }

  void _triggerBoxAction(int index) {
    final color = EditorData.instance.getIndex(index);
    switch (EditorData.instance.action) {
      case EditorAction.draw:
        EditorData.instance.setIndex(index);
        break;

      case EditorAction.eyedrop:
        EditorData.instance.primaryColor = color!;
        break;
      case EditorAction.delete:
        EditorData.instance.setIndex(index, color: Colors.transparent);
        break;
      case EditorAction.bucket:
        if (!_isDragging) {
          _fillColor(index);
        }
        break;
      default:
    }
  }

  int get countCollumn => EditorData.instance.size.height.toInt();
  int get countRow => EditorData.instance.size.width.toInt();
  double get boxSize => 20.0;
  Size get canvasSize => Size(countRow * boxSize, countCollumn * boxSize);

  Widget _buildLayerCanvas([String? layerName]) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        countCollumn,
        (colNum) => Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            countRow,
            (rowNum) {
              final index = colNum * countRow + rowNum;
              return ListenableBuilder(
                listenable: Listenable.merge([
                  EditorData.instance.canvasNotifier,
                ]),
                builder: (context, _) {
                  if (layerName != null) {
                    final color = EditorData.instance.getIndex(
                      index.toInt(),
                      layer: layerName,
                    );
                    return Container(
                      height: boxSize,
                      width: boxSize,
                      decoration: BoxDecoration(
                        color: color,
                        border: Border.all(
                          width: 1,
                          color: color!,
                          strokeAlign: BorderSide.strokeAlignInside,
                        ),
                      ),
                    );
                  }

                  return MouseRegion(
                    onEnter: (_) {
                      if (_isDragging) {
                        _triggerBoxAction(index);
                      }
                    },
                    child: GestureDetector(
                      onTap: () => _triggerBoxAction(index),
                      child: Container(
                        height: boxSize,
                        width: boxSize,
                        decoration: BoxDecoration(
                          border: EditorData.instance.grid
                              ? Border(
                                  top: BorderSide(
                                    color: Colors.black45,
                                    style: colNum == 0
                                        ? BorderStyle.none
                                        : BorderStyle.solid,
                                  ),
                                  left: BorderSide(
                                    color: Colors.black45,
                                    style: rowNum == 0
                                        ? BorderStyle.none
                                        : BorderStyle.solid,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (_) => _isDragging = true,
      onPanEnd: (_) => _isDragging = false,
      onPanUpdate: (details) {
        if (EditorData.instance.action == EditorAction.pan) {
          final newOffset = Offset(
            boxPosition.value.dx + details.delta.dx,
            boxPosition.value.dy + details.delta.dy,
          );
          boxPosition.value = newOffset;
        }
      },
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (!_initialized) {
            final offset = Offset(
              (constraints.maxWidth - canvasSize.width) / 2,
              (constraints.maxHeight - canvasSize.height) / 2,
            );
            boxPosition.value = offset;
            _initialized = true;
          }
          return Stack(
            children: [
              ValueListenableBuilder<Offset>(
                valueListenable: boxPosition,
                builder: (context, offset, child) => Positioned(
                  left: offset.dx,
                  top: offset.dy,
                  child: child!,
                ),
                child: ValueListenableBuilder<double>(
                  valueListenable: sliderValue,
                  builder: (context, scale, child) => Transform.scale(
                    scale: scale,
                    child: child,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(),
                    ),
                    child: ListenableBuilder(
                      listenable: EditorData.instance.globalNotifier,
                      builder: (BuildContext context, Widget? _) => Stack(
                        children: [
                          ...EditorData.instance.layers
                              .where((layer) => !layer.hidden)
                              .map(
                                (layer) => _buildLayerCanvas(layer.name),
                              ),
                          _buildLayerCanvas(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 16,
                          spreadRadius: 2,
                          color: Colors.black45,
                          offset: Offset(2, 2),
                        )
                      ]),
                  width: 40,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ValueListenableBuilder<bool>(
                        valueListenable: showZoom,
                        builder: (context, isVisible, child) => Visibility(
                          visible: isVisible,
                          child: child!,
                        ),
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: SizedBox(
                            width: 200,
                            child: ValueListenableBuilder<double>(
                              valueListenable: sliderValue,
                              builder: (context, value, _) => Slider(
                                label: '${(value * 100).round()}%',
                                divisions: 390,
                                value: value,
                                onChanged: (double value) =>
                                    sliderValue.value = value,
                                min: 0.1,
                                max: 4,
                                onChangeEnd: (double value) {
                                  if (value > 0.75 && value < 1.25) {
                                    sliderValue.value = 1;
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => showZoom.value = !showZoom.value,
                        icon: const Icon(Icons.zoom_in),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
