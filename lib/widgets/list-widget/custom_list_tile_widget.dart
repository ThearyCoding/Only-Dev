import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomListTile extends StatelessWidget {
  final Widget leadingIcon;
  final String title;
  final Widget? trailingIcon;
  final Function() onTap;
  final bool showSwitch;
  final Rx<ThemeMode>? currentTheme;
  final Function(bool)? onSwitchChanged;

  const CustomListTile({
    Key? key,
    required this.leadingIcon,
    required this.title,
      this.trailingIcon = const Icon(Icons.arrow_forward_ios, size: 14),
    required this.onTap,
    this.showSwitch = false,
    this.currentTheme,
    this.onSwitchChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey[500]!, // Border color
          ),
          borderRadius: BorderRadius.circular(10), // Border radius
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: leadingIcon,
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          trailing: showSwitch
              ? Obx(
                  () => Switch(
                    value: currentTheme?.value == ThemeMode.dark,
                    onChanged: onSwitchChanged,
                  ),
                )
              : (trailingIcon ?? const SizedBox.shrink()), 
        ),
      ),
    );
  }
}
