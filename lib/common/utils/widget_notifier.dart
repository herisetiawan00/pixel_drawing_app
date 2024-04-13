import 'package:flutter/material.dart';

class WidgetNotifier extends ChangeNotifier implements Listenable {
  void notify() => notifyListeners();
}
