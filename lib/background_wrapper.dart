import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BackgroundWrapper extends StatelessWidget {
  final Widget child;

  const BackgroundWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/gameboy.jpg',
            fit: BoxFit.cover,
            opacity: const AlwaysStoppedAnimation(0.7),
            errorBuilder: (context, error, stackTrace) {
              print('背景圖片載入失敗: assets/images/gameboy.jpg');
              return Container(
                color: Colors.black87,
                child: const Center(
                  child: Text(
                    '背景圖片載入失敗',
                    style: TextStyle(
                      fontFamily: 'NotoSerifTC',
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ).animate().fadeIn(duration: 1000.ms),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: child,
        ),
      ],
    );
  }
}
