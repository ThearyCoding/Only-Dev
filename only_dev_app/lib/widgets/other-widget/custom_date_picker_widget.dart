import 'package:flutter/material.dart';
import 'package:only_dev_app/widgets/app_widgets/app_textfield_widget.dart';

class CustomDatePicker extends StatelessWidget {
  final String selectedValue;
  final VoidCallback onPressed;
  final TextStyle? labelStyle;
  final Color? labelColor;

  const CustomDatePicker({
    super.key,
    required this.selectedValue,
    required this.onPressed,
    this.labelStyle,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: TextEditingController(text: selectedValue),
      labelText: 'Date of Birth',
      labelStyle: labelStyle,
      labelColor: labelColor,
      isRequired: true,
      readOnly: true,
      onTap: onPressed,
      suffixIcon: IconButton(
        splashRadius: 20,
        icon: const Icon(Icons.calendar_today_rounded, size: 20),
        onPressed: onPressed,
      ),
    );
  }
}
