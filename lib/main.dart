import 'package:flutter/material.dart';

void main() {
  runApp(const DevDockApp());
}

class DevDockApp extends StatelessWidget {
  const DevDockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DevDock',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xff6200ee),
        scaffoldBackgroundColor: const Color(0xff121212),
      ),
      home: const ExtensionContainer(),
    );
  }
}

class ExtensionContainer extends StatelessWidget {
  const ExtensionContainer({super.key});

  @override
  Widget build(BuildContext context) {
    // Standard size limits for a comfortable Chrome extension popup window
    return const Scaffold(
      body: SizedBox(
        width: 400,
        height: 550,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.developer_board, size: 48, color: Color(0xff03dac6)),
              SizedBox(height: 16),
              Text(
                'Welcome to DevDock',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Your workspace manager is ready.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}