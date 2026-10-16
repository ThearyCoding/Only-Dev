import 'package:flutter/material.dart';

class CustomDatePicker extends StatelessWidget {
  final String selectedValue;
  final Function onPressed;
  final TextStyle? labelStyle;
  final Color? labelColor;
  const CustomDatePicker({
    Key? key,
    required this.selectedValue,
    required this.onPressed,
    this.labelStyle,
    this.labelColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onPressed(),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  label: RichText(
                    text: TextSpan(
                      text: 'Date of Birth | ',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: labelColor ??
                            Theme.of(context).textTheme.bodyMedium!.color,
                      ),
                      children: const <TextSpan>[
                        TextSpan(
                          text: '*',
                          style: TextStyle(color: Colors.red, fontSize: 16.0),
                        ),
                      ],
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                controller: TextEditingController(text: selectedValue),
                readOnly: true,
              ),
            ),
            IconButton(
              splashRadius: 20,
              icon: const Icon(Icons.calendar_today),
              onPressed: () => onPressed(),
            ),
          ],
        ),
      ),
    );
  }
}
