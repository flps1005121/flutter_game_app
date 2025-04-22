import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:audioplayers/audioplayers.dart';

extension CustomColorExtension on Color {
  Color darken([double amount = 0.2]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}

class AnswerButton extends StatelessWidget {
  final String option;
  final Function(String) onAnswer;
  final bool isLocked;

  const AnswerButton({
    super.key,
    required this.option,
    required this.onAnswer,
    required this.isLocked,
  });

  void _playClickSound() async {
    final player = AudioPlayer();
    await player.play(AssetSource('audio/click.mp3'));
  }

  @override
  Widget build(BuildContext context) {
    final buttonChild = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLocked
              ? [Colors.grey.shade400, Colors.grey.shade500]
              : [Colors.redAccent, Colors.orangeAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLocked
              ? CustomColorExtension(Colors.grey.shade400).darken()
              : CustomColorExtension(Colors.redAccent).darken(),
          width: 2,
        ),
        boxShadow: isLocked
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 6,
                  offset: const Offset(2, 4),
                ),
              ],
      ),
      child: Center(
        child: Text(
          option,
          style: TextStyle(
            fontFamily: 'NotoSerifTC',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isLocked ? Colors.black54 : Colors.white,
          ),
        ),
      ),
    );

    final animated = buttonChild
        .animate(
          onPlay: (controller) =>
              isLocked ? controller.stop() : controller.repeat(reverse: true),
        )
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.05, 1.05),
          duration: 500.ms,
          curve: Curves.easeInOut,
        );

    return GestureDetector(
      onTap: isLocked
          ? null
          : () {
              _playClickSound();
              onAnswer(option);
            },
      child: animated,
    );
  }
}
