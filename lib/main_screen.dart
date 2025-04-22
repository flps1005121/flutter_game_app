import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int highScore = 0;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      highScore = prefs.getInt('highScore') ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/gameboy.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print('Game Boy 圖片載入失敗: assets/images/gameboy.jpg');
                return Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Text(
                      '圖片載入失敗',
                      style: TextStyle(
                        fontFamily: 'NotoSerifTC',
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ).animate().fadeIn(duration: 500.ms),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '讓子彈飛 X 甄嬛傳 台詞接龍王',
                  style: TextStyle(
                    fontFamily: 'NotoSerifTC',
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2),
                const SizedBox(height: 10),
                Text(
                  '最高分: $highScore',
                  style: const TextStyle(
                    fontFamily: 'NotoSerifTC',
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
                const SizedBox(height: 220), // 調整間距以對齊按鈕
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const GameScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    '開始遊戲',
                    style: TextStyle(
                      fontFamily: 'NotoSerifTC',
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ).animate().scale(duration: 300.ms, delay: 400.ms),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    // Flutter 不支援直接退出應用，改為回到系統主畫面
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    backgroundColor: Colors.grey[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    '退出遊戲',
                    style: TextStyle(
                      fontFamily: 'NotoSerifTC',
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ).animate().scale(duration: 300.ms, delay: 600.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
