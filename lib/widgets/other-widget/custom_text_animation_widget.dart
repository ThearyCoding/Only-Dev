import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class CustomTextAnimationWidget extends StatelessWidget {
  final List<String> texts;
  final List<TextStyle> textStyles;
  final Duration speed;
  final bool repeatForever;

  const CustomTextAnimationWidget({
    Key? key,
    required this.texts,
    required this.textStyles,
    this.speed = const Duration(milliseconds: 50),
    this.repeatForever = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedTextKit(
      animatedTexts: List<AnimatedText>.generate(
        texts.length,
        (index) => TypewriterAnimatedText(
          texts[index],
          textStyle: textStyles[index],
          speed: speed,
        ),
      ),
      repeatForever: repeatForever,
    );
  }
}
