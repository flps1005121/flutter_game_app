import 'package:flutter/material.dart';
import 'main_screen.dart';

void main() {
  runApp(const DialogueKingApp());
}

class DialogueKingApp extends StatelessWidget {
  const DialogueKingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '讓子彈飛 X 甄嬛傳 台詞接龍王',
      theme: ThemeData(primarySwatch: Colors.red),
      home: const MainScreen(),
    );
  }
}
