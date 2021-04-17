import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/pages/home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firestore.instance.settings(timestampsInSnapshotsEnabled: true).then((_) {
    // print("Timestamps enabled in snapshots\n");
  }, onError: (_) {
    // print("Error enabling timestamps in snapshots\n");
  });
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'STNAD IV',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: MaterialColor(0xFFFF0000, {
          50: Color.fromRGBO(255, 0, 0, 1),
          100: Color.fromRGBO(255, 0, 0, 1),
          200: Color.fromRGBO(255, 0, 0, 1),
          300: Color.fromRGBO(255, 0, 0, 1),
          400: Color.fromRGBO(255, 0, 0, 1),
          500: Color.fromRGBO(255, 0, 0, 1),
          600: Color.fromRGBO(255, 0, 0, 1),
          700: Color.fromRGBO(255, 0, 0, 1),
          800: Color.fromRGBO(255, 0, 0, 1),
          900: Color.fromRGBO(255, 0, 0, 1),
        }),
        accentColor: Color.fromRGBO(255, 0, 0, 1),
      ),
      home: Home(),
    );
  }
}
