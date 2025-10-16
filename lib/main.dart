import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const TaskProApp());
}

class TaskProApp extends StatelessWidget {
  const TaskProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskPro',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}


