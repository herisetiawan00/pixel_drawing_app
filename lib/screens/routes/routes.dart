import 'package:flutter/material.dart';
import 'package:pixel_drawing_app/screens/editor_screen/editor_screen.dart';
import 'package:pixel_drawing_app/screens/landing_screen/landing_screen.dart';
import 'package:pixel_drawing_app/screens/routes/routes_constants.dart';

class Routes {
  static Map<String, WidgetBuilder> getAll() => {
        RouteList.root: (context) => const LandingScreen(),
        RouteList.editor: (context) => const EditorScreen(),
      };
}
