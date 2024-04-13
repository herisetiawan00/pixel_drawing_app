import 'package:flutter/material.dart';
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
                    SizedBox(
                      height: 36,
                      child: TextField(
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          hintText: 'File name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Save location',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        MaterialButton(
                          color: Colors.teal,
                          height: 56,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          onPressed: () {
                            EditorData.instance.initialize(const Size(32, 32));
                            Navigator.of(context).pushNamed(RouteList.editor);
                          },
                          child: const Text('Choose...'),
                        ),
                      ],
                    ),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'File name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
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
