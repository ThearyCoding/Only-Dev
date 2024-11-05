import 'package:flutter/material.dart';

class CustomCheckbox extends StatelessWidget {
  final bool isSelected;
  final bool isCorrectOption;

  const CustomCheckbox({
    Key? key,
    required this.isSelected,
    required this.isCorrectOption,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    // Determine colors based on isSelected and isCorrectOption
    Color fillColor = isSelected
        ? isCorrectOption ? Colors.green : Colors.red
        : Colors.transparent;

    Color borderColor = isSelected
        ? isCorrectOption ? Colors.green : Colors.red
        : Colors.blue;

    return Checkbox(
      value: isSelected || isCorrectOption,
      onChanged: (_) {},
      fillColor: WidgetStateColor.resolveWith((states) {
        return fillColor.withOpacity(states.contains(WidgetState.disabled) ? 0.5 : 1.0);
      }),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
        side: BorderSide(
          color: borderColor,
          width: 2.0,
        ),
      ),
      checkColor: Colors.white,
    );
  }
}
