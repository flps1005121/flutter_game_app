import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'answer_button.dart';
import 'background_wrapper.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  int score = 0;
  int combo = 0;
  int timeLeft = 8;
  int questionIndex = 0;
  int highScore = 0;
  String feedback = '';
  bool showCorrectImage = false;
  bool isAnswerLocked = false;
  Timer? timer;
  List<Map<String, dynamic>> currentQuestions = [];

  // 台詞題庫（包含圖片和無圖片題目）
  final List<Map<String, dynamic>> questions = [
    {
      'prompt': '你帶著 __ ，出了城，吃著火鍋還唱著歌，突然就被麻匪劫了！',
      'correct': '老婆',
      'options': ['弟兄們', '老婆', '家人', '小孩'],
      'source': '讓子彈飛',
      'image_with_text': 'assets/images/吃著火鍋.png',
      'image_no_text': 'assets/new/吃著火鍋.png',
    },
    {
      'prompt': '安陵容面對誤會時說了什麼？',
      'correct': '我不知道這事',
      'options': ['本宮乏了！', '我不知道這事', '這福氣我受不起！', '噁心！'],
      'source': '甄嬛傳',
      'image_with_text': 'assets/images/我不知道這事.jpg',
      'image_no_text': 'assets/new/我不知道這事.jpg',
    },
    {
      'prompt': '我們沒膽子 __',
      'correct': '剿匪',
      'options': ['出軌', '出兵', '剿匪', '這是個什麼玩意兒？'],
      'source': '讓子彈飛',
      'image_with_text': 'assets/images/沒膽子剿匪.png',
      'image_no_text': 'assets/new/沒膽子剿匪.png',
    },
    {
      'prompt': '甄嬛質問安陵容時說了什麼？',
      'correct': '那你是什麼意思呀',
      'options': ['你們休想安寧！', '翠果打爛她的嘴', '那你是什麼意思呀', '意不意外？'],
      'source': '甄嬛傳',
      'image_with_text': 'assets/images/那你是什麼意思呀.jpg',
      'image_no_text': 'assets/new/那你是什麼意思呀.jpg',
    },
    {
      'prompt': '我來鵝城只辦三件事，請問是哪三件？',
      'correct': '公平！公平！還是他媽的公平！',
      'options': [
        '公平！公平！還是他媽的公平！',
        '賺錢！賺錢！還是他媽的賺錢！',
        '正義！正義！還是他媽的正義！',
        '生活！生活！還是他媽的生活！'
      ],
      'source': '讓子彈飛',
      'image_with_text': 'assets/images/公平.png',
      'image_no_text': 'assets/new/公平.png',
    },
    {
      'prompt': '甄嬛為故人祈福時說了什麼？',
      'correct': '祈禱他可以早日通往極樂',
      'options': ['祈禱他可以早日通往地獄', '祈禱他可以早日通往極樂', '祈禱他可以早日通往後宮', '祈禱他可以早日通往天堂'],
      'source': '甄嬛傳',
      'image_with_text': 'assets/images/祈禱他可以早日通往極樂.jpg',
      'image_no_text': 'assets/new/祈禱他可以早日通往極樂.jpg',
    },
    {
      'prompt': '這他媽是幾歲？',
      'correct': '八歲',
      'options': ['九歲', '六歲', '七歲', '八歲'],
      'source': '讓子彈飛',
      'image_with_text': 'assets/images/這是八歲.png',
      'image_no_text': 'assets/new/這是八歲.png',
    },
    {
      'prompt': '華妃對無用之人說了什麼？',
      'correct': '無用的人不必留著',
      'options': ['無用的人不必留著', '翠果打爛她的嘴', '還有臉在本宮面前說這些', '那你是什麼意思呀？'],
      'source': '甄嬛傳',
      'image_with_text': 'assets/images/無用的人不必留著.jpg',
      'image_no_text': 'assets/new/無用的人不必留著.jpg',
    },
    {
      'prompt': '就一句話！ __ ！',
      'correct': '噁心',
      'options': ['噁心', '牛逼', '很厲害呀', '有夠壞'],
      'source': '讓子彈飛',
      'image_with_text': 'assets/images/噁心.png',
      'image_no_text': 'assets/new/噁心.png',
    },
    {
      'prompt': '華妃憤怒質問時說了什麼？',
      'correct': '還有臉在本宮面前說這些',
      'options': ['無用的人不必留著', '翠果打爛她的嘴', '還有臉在本宮面前說這些', '那你是什麼意思呀？'],
      'source': '甄嬛傳',
      'image_with_text': 'assets/images/還有臉在本宮面前說這些.jpg',
      'image_no_text': 'assets/new/還有臉在本宮面前說這些.jpg',
    },
    {
      'prompt': '翻譯出來給我聽，什麼叫驚喜！什麼他媽的叫他媽的驚喜！',
      'correct': '三天之後，給你們一百八十萬出城剿匪，接上我的腿',
      'options': [
        '三天之後，給你們一百八十萬出城剿匪，接上我的腿',
        '四天之後，給你們一百九十萬出城剿匪，接上我的腳',
        '三天之後，給你們一百八十萬出城剿匪，接上我的腳',
        '四天之後，給你們一百九十萬出城剿匪，接上我的腿'
      ],
      'source': '讓子彈飛',
      'image_with_text': 'assets/images/翻譯.png',
      'image_no_text': 'assets/new/翻譯.png',
    },
    {
      'prompt': '讓子彈飛 __ ？',
      'correct': '一會兒',
      'options': ['幾秒', '一會兒', '一下子', '一會'],
      'source': '讓子彈飛',
      'image_with_text': 'assets/images/讓子彈飛一會兒.png',
      'image_no_text': 'assets/new/讓子彈飛一會兒.png',
    },
    {
      'prompt': '張麻子在火車上對夫人說：“夫人，兄弟我此番，只為劫財，不為劫色，同床，但不入身。”接下來是什麼？',
      'correct': '有槍在此。',
      'options': ['有槍在此。', '有刀在此。', '絕不推辭。', '睡覺！'],
      'source': '讓子彈飛',
    },
    {
      'prompt': '馬邦德談到麻匪時說：“你帶著老婆，出了城，吃著火鍋還唱著歌，突然就被 __ 劫了！”',
      'correct': '麻匪',
      'options': ['黃四郎', '麻匪', '張麻子', '土匪'],
      'source': '讓子彈飛',
    },
    {
      'prompt': '張麻子扇動鵝城居民反抗黃四郎時喊道：“槍在手！ __ ！”',
      'correct': '跟我走！',
      'options': ['跟我走！', '去剿匪！', '搶碉樓！', '殺四郎！'],
      'source': '讓子彈飛',
    },
    {
      'prompt': '黃四郎與張麻子在宴會上對話，張麻子問：“像！很像！不過你比他缺了一樣東西。”黃四郎回答什麼？',
      'correct': '你不會裝糊塗。',
      'options': ['你不會裝糊塗。', '臉上的麻子。', '霸氣外露。', '一顆真心。'],
      'source': '讓子彈飛',
    },
    {
      'prompt': '張麻子與湯師爺討論當縣長時說：“我是想站著，還把 __ 掙了！”',
      'correct': '錢',
      'options': ['公平', '名聲', '錢', '權力'],
      'source': '讓子彈飛',
    },
    {
      'prompt': '黃四郎驗屍時震驚喊道：“怎麼會是 __ ？”',
      'correct': '胡萬',
      'options': ['張麻子', '馬邦德', '胡萬', '湯師爺'],
      'source': '讓子彈飛',
    },
    {
      'prompt': '皇后談到人情世故時說：“錦上添花有什麼意思， __ 才讓人記得好處。”',
      'correct': '雪中送炭',
      'options': ['雪中送炭', '錦上添花', '畫龍點睛', '雪上加霜'],
      'source': '甄嬛傳',
    },
    {
      'prompt': '甄嬛拒絕殞地之舉時說：“再冷，也不該 __ 。”',
      'correct': '拿別人的血來暖自己',
      'options': ['拿別人的血來暖自己', '用別人的命來換榮華', '讓別人為你受苦', '自己凍死在宮中'],
      'source': '甄嬛傳',
    },
    {
      'prompt': '齊妃震怒時對下人喊道：“ __ ！”',
      'correct': '翠果打爛他的嘴',
      'options': ['翠果打爛他的嘴', '槿汐教他規矩', '流朱拖他出去', '頌芝給他掌嘴'],
      'source': '甄嬛傳',
    },
    {
      'prompt': '安陵容回宮前感慨：“宮裡的夜，這麼冷，這麼長，每一秒怎麼熬過來的， __ 。”',
      'correct': '我都不敢想',
      'options': ['我都不敢想', '我早已忘卻', '我心如刀絞', '我悔不當初'],
      'source': '甄嬛傳',
    },
    {
      'prompt': '華妃談到權勢傾覆時說：“ __ ！”',
      'correct': '牆倒眾人推',
      'options': ['牆倒眾人推', '樹倒猢猻散', '人走茶涼', '世態炎涼'],
      'source': '甄嬛傳',
    },
    {
      'prompt': '甄嬛教導後宮生存之道時說：“別人幫你，那是情分， __ 。”',
      'correct': '不幫你，那是本分',
      'options': ['不幫你，那是本分', '幫你，那是義務', '不幫你，那是無情', '幫你，那是恩賜'],
      'source': '甄嬛傳',
    },
  ];

  @override
  void initState() {
    super.initState();
    loadHighScore();
    startGame();
  }

  void loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      highScore = prefs.getInt('highScore') ?? 0;
    });
  }

  void updateHighScore() async {
    if (score > highScore) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('highScore', score);
      setState(() {
        highScore = score;
      });
    }
  }

  void startGame() {
    final bulletQuestions = questions
        .where((q) => q['source'] == '讓子彈飛')
        .toList()
      ..shuffle(Random());
    final zhenhuanQuestions = questions
        .where((q) => q['source'] == '甄嬛傳')
        .toList()
      ..shuffle(Random());
    setState(() {
      currentQuestions = [
        ...bulletQuestions.take(5),
        ...zhenhuanQuestions.take(5),
      ]..shuffle(Random());
      questionIndex = 0;
      score = 0;
      combo = 0;
      feedback = '';
      showCorrectImage = false;
      isAnswerLocked = false;
    });
    startTimer();
  }

  void startTimer() {
    timer?.cancel();
    setState(() {
      timeLeft = 8;
      feedback = '';
      showCorrectImage = false;
      isAnswerLocked = false;
    });
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          setState(() {
            combo = 0;
            score -= 5;
            feedback = '時間到！連擊清零，扣5分😢';
            isAnswerLocked = true;
            nextQuestion();
          });
        }
      });
    });
  }

  void handleAnswer(String selected) {
    if (isAnswerLocked) return;
    final AudioPlayer sfxPlayer = AudioPlayer();
    timer?.cancel();
    setState(() {
      isAnswerLocked = true;
    });
    final correct = currentQuestions[questionIndex]['correct'];
    if (selected == correct) {
      sfxPlayer.play(AssetSource('audio/correct.mp3'));
      setState(() {
        combo++;
        score += 10 + (combo >= 3 ? 5 : 0);
        feedback = combo >= 3 ? '鵝城連擊王！+${10 + 5}分' : '台詞之神！+10分';
        showCorrectImage = true;
      });
      Timer(const Duration(seconds: 1), () {
        setState(() {
          showCorrectImage = false;
          nextQuestion();
        });
      });
    } else {
      sfxPlayer.play(AssetSource('audio/wrong.mp3'));
      setState(() {
        combo = 0;
        score -= 5;
        feedback = '這接龍連華妃都看不下去了😤';
        nextQuestion();
      });
    }
  }

  void nextQuestion() {
    setState(() {
      questionIndex++;
      if (questionIndex >= currentQuestions.length) {
        updateHighScore();
        feedback = '遊戲結束！最終分數: $score';
        timer?.cancel();
        isAnswerLocked = true;
      } else {
        startTimer();
      }
    });
  }

  void _playClickSound() async {
    final player = AudioPlayer();
    await player.play(AssetSource('audio/click.mp3'));
  }

  double _getPromptFontSize(String prompt) {
    if (prompt.length > 40) return 14.0;
    if (prompt.length > 30) return 16.0;
    if (prompt.length > 20) return 18.0;
    return 20.0;
  }

  @override
  Widget build(BuildContext context) {
    if (questionIndex >= currentQuestions.length) {
      return BackgroundWrapper(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '遊戲結束',
                  style: TextStyle(
                    fontFamily: 'NotoSerifTC',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                  ),
                ).animate().fadeIn(duration: 500.ms),
                const SizedBox(height: 10),
                Text(
                  '當前分數: $score',
                  style: const TextStyle(
                    fontFamily: 'NotoSerifTC',
                    fontSize: 24,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                  ),
                ).animate().scale(duration: 500.ms, delay: 200.ms),
                Text(
                  '最高分: $highScore',
                  style: const TextStyle(
                    fontFamily: 'NotoSerifTC',
                    fontSize: 20,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                  ),
                ).animate().scale(duration: 500.ms, delay: 400.ms),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    _playClickSound();
                    startGame();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    '重新挑戰',
                    style: TextStyle(
                      fontFamily: 'NotoSerifTC',
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ).animate().scale(duration: 300.ms, delay: 600.ms),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    _playClickSound();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
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
                ).animate().scale(duration: 300.ms, delay: 800.ms),
              ],
            ),
          ),
        ),
      );
    }

    final question = currentQuestions[questionIndex];
    final hasImages = question['image_with_text'] != null &&
        question['image_no_text'] != null;

    return BackgroundWrapper(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '分數: $score  連擊: $combo',
                style: const TextStyle(
                  fontFamily: 'NotoSerifTC',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                ),
              ).animate().fadeIn(duration: 500.ms),
              const SizedBox(height: 8),
              Text(
                '倒數: $timeLeft 秒',
                style: const TextStyle(
                  fontFamily: 'NotoSerifTC',
                  fontSize: 18,
                  color: Colors.redAccent,
                  shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                ),
              ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
              const SizedBox(height: 10),
              Text(
                '來源: ${question['source']}',
                style: const TextStyle(
                  fontFamily: 'NotoSerifTC',
                  fontSize: 16,
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                ),
              ).animate().fadeIn(duration: 500.ms, delay: 400.ms),
              const SizedBox(height: 10),
              Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.9),
                child: Text(
                  question['prompt'],
                  style: TextStyle(
                    fontFamily: 'NotoSerifTC',
                    fontSize: _getPromptFontSize(question['prompt']),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ).animate().fadeIn(duration: 500.ms, delay: 600.ms),
              const SizedBox(height: 10),
              hasImages
                  ? Image.asset(
                      showCorrectImage
                          ? question['image_with_text']
                          : question['image_no_text'],
                      width: 150,
                      height: 150,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        print(
                            '圖片載入失敗: ${showCorrectImage ? question['image_with_text'] : question['image_no_text']}');
                        return Image.asset(
                          showCorrectImage
                              ? 'assets/images/placeholder_with_text.png'
                              : 'assets/images/placeholder_no_text.png',
                          width: 150,
                          height: 150,
                          fit: BoxFit.contain,
                        );
                      },
                    )
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .scale(begin: const Offset(0.8, 0.8))
                  : Text(
                      showCorrectImage ? question['correct'] : '猜猜這句台詞是什麼？',
                      style: const TextStyle(
                        fontFamily: 'NotoSerifTC',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                        shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2),
              const SizedBox(height: 10),
              ...question['options'].map<Widget>((option) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: AnswerButton(
                    option: option,
                    onAnswer: handleAnswer,
                    isLocked: isAnswerLocked,
                  ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.2),
                );
              }).toList(),
              const SizedBox(height: 10),
              Text(
                feedback,
                style: const TextStyle(
                  fontFamily: 'NotoSerifTC',
                  fontSize: 16,
                  color: Colors.redAccent,
                  shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .scale(begin: const Offset(0.8, 0.8)),
            ],
          ),
        ),
      ),
    );
  }
}
