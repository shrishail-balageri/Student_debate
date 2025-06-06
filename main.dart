import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Debate App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(),);
}
}

// screens/login_screen.dart


// screens/debate_list_screen.dart

