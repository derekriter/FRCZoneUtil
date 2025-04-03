import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  //Set window title
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.setTitle("FRC Zone Utility");

  runApp(const AppRoot());
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: "FRC Zone Utility",
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Color.fromRGBO(0, 118, 40, 1.0),
          ),
        ),
        home: const HomePage(),
      ),
    );
  }
}

class AppState extends ChangeNotifier {}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Text("test"));
  }
}
