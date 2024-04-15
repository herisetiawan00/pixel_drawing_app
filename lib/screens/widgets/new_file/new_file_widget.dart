import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pixel_drawing_app/screens/editor_screen/editor_data.dart';
import 'package:pixel_drawing_app/screens/routes/routes_constants.dart';

class NewFileWidget extends StatefulWidget {
  const NewFileWidget({super.key});

  @override
  State<NewFileWidget> createState() => _NewFileWidgetState();

  static Future<void> createDialog(BuildContext context) => showDialog(
        context: context,
        builder: (context) => const NewFileWidget(),
      );
}

class _NewFileWidgetState extends State<NewFileWidget> {
  final TextEditingController _fileNameController = TextEditingController();
  final TextEditingController _saveLocationController = TextEditingController();
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  final ValueNotifier<bool> lockRatioNotifier = ValueNotifier(true);

  double lockedRatio = 1;

  @override
  void initState() {
    lockRatioNotifier.addListener(() {
      if (lockRatioNotifier.value) {
        final width = int.tryParse(_widthController.text) ?? 1;
        final height = int.tryParse(_heightController.text) ?? 1;
        lockedRatio = width / height;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(32),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: Navigator.of(context).pop,
                  icon: const Icon(
                    Icons.close,
                    size: 16,
                  ),
                ),
              ],
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _fileNameController,
                      decoration: InputDecoration(
                        hintText: 'File name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    TextField(
                      controller: _saveLocationController,
                      decoration: InputDecoration(
                        hintText: 'Save location',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        suffix: MaterialButton(
                          color: Colors.teal,
                          // height: 56,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          onPressed: () async {
                            final fileName = _fileNameController.text;
                            final directory = await getSaveLocation(
                              suggestedName:
                                  '${fileName.isEmpty ? 'Untitled' : fileName}'
                                  '.hpd',
                            );
                            _saveLocationController.text =
                                directory?.path ?? '';
                          },
                          child: const Text(
                            'Choose...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Width',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            controller: _widthController,
                            onChanged: (text) {
                              if (lockRatioNotifier.value) {
                                final width = int.tryParse(text) ?? 1;
                                _heightController.text =
                                    (width / lockedRatio).round().toString();
                              }
                            },
                          ),
                        ),
                        ValueListenableBuilder<bool>(
                          valueListenable: lockRatioNotifier,
                          builder: (context, locked, _) => IconButton(
                            onPressed: () {
                              lockRatioNotifier.value = !locked;
                            },
                            icon: Icon(locked ? Icons.link : Icons.link_off),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Height',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            controller: _heightController,
                            onChanged: (text) {
                              if (lockRatioNotifier.value) {
                                final height = int.tryParse(text) ?? 1;
                                _widthController.text =
                                    (height * lockedRatio).round().toString();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        MaterialButton(
                          color: Colors.teal,
                          onPressed: () {
                            EditorData.instance.initialize(
                              const Size(32, 32),
                              '',
                            );
                            Navigator.pushReplacementNamed(
                              context,
                              RouteList.editor,
                            );
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const SizedBox(
                            height: 50,
                            width: 100,
                            child: Center(
                              child: Text(
                                'Create',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
