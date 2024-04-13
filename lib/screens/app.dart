import 'package:flutter/material.dart';
import 'package:pixel_drawing_app/screens/routes/routes.dart';
import 'package:pixel_drawing_app/screens/routes/routes_constants.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pixel Drawing App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
        ),
        useMaterial3: true,
      ),
      routes: Routes.getAll(),
      initialRoute: RouteList.root,
      // builder: (context, child) => Scaffold(
      //   body: Column(
      //     children: [
      //       const MenuBarWidget(),
      //       Expanded(
      //         child: child ?? Container(),
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}
