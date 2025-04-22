import 'package:flutter/material.dart';

// 在畫面裡顯示網路上的圖片，
// 網址是 https://upload.wikimedia.org/wikipedia/en/4/46/PeterpanRKO.jpg
// 寬高設為 200 * 200，
// 圖片置中
// 圖片維持比例，超出 200 * 200 的部分會被裁切

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Text('hello world'),
      ),
    );
  }
}
