import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:only_dev_app/core/app_style.dart';
import 'package:only_dev_app/widgets/textfield/ios_style_text_form_field.dart';

/// Single, unified, highly reusable text field widget for the entire Only Dev application.
///
/// Features:
/// - iOS 17+/18 native magnifying loupe integration ([AppTextLoupe])
/// - Single-line or multi-line (textarea/bio/content) support
/// - Automatic password visibility toggle for password fields
/// - Theme-aware light & dark styling with [AppStyle.primaryColor] focus indicators
/// - Clean label above the field with optional red required asterisk ([isRequired])
/// - Flexible prefix & suffix (supports both [IconData] and custom [Widget])
/// - Form validation and input formatting support
class AppTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final String? labelText;
  final TextStyle? labelStyle;
  final Color? labelColor;
  final bool isRequired;
  final String? hintText;
  final TextStyle? hintStyle;
  final String? helperText;
  final String? errorText;

  final Widget? prefix;
  final dynamic prefixIcon;
  final IconData? prefixIconData;

  final Widget? suffix;
  final dynamic suffixIcon;
  final IconData? suffixIconData;

  final bool isPassword;
  final bool obscureText;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool readOnly;
  final bool enabled;

  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final MaxLengthEnforcement? maxLengthEnforcement;

  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final void Function(String)? onFieldSubmitted;
  final void Function()? onTap;

  final EdgeInsetsGeometry? contentPadding;
  final double? borderRadius;
  final Color? fillColor;
  final bool? filled;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final bool borderless;
  final TextStyle? style;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;

  const AppTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.labelText,
    this.labelStyle,
    this.labelColor,
    this.isRequired = false,
    this.hintText,
    this.hintStyle,
    this.helperText,
    this.errorText,
    this.prefix,
    this.prefixIcon,
    this.prefixIconData,
    this.suffix,
    this.suffixIcon,
    this.suffixIconData,
    this.isPassword = false,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.focusNode,
    this.autofocus = false,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.maxLengthEnforcement,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.onFieldSubmitted,
    this.onTap,
    this.contentPadding,
    this.borderRadius,
    this.fillColor,
    this.filled,
    this.borderColor,
    this.focusedBorderColor,
    this.borderless = false,
    this.style,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured;

  bool get _isPasswordMode => widget.isPassword || widget.obscureText;

  @override
  void initState() {
    super.initState();
    _obscured = _isPasswordMode;
  }

  @override
  void didUpdateWidget(covariant AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPassword != widget.isPassword ||
        oldWidget.obscureText != widget.obscureText) {
      _obscured = _isPasswordMode;
    }
  }

  Widget? _buildPrefixIcon(bool isDark) {
    if (widget.prefixIcon is Widget) {
      return widget.prefixIcon as Widget;
    }
    if (widget.prefixIcon is IconData) {
      return Icon(
        widget.prefixIcon as IconData,
        size: 20,
        color: isDark ? Colors.white54 : const Color(0xFF64748B),
      );
    }
    if (widget.prefixIconData != null) {
      return Icon(
        widget.prefixIconData,
        size: 20,
        color: isDark ? Colors.white54 : const Color(0xFF64748B),
      );
    }
    return null;
  }

  Widget? _buildSuffixIcon(bool isDark) {
    if (widget.suffixIcon is Widget) {
      return widget.suffixIcon as Widget;
    }
    if (widget.suffixIcon is IconData) {
      return Icon(
        widget.suffixIcon as IconData,
        size: 20,
        color: isDark ? Colors.white54 : const Color(0xFF64748B),
      );
    }
    if (widget.suffixIconData != null) {
      return Icon(
        widget.suffixIconData,
        size: 20,
        color: isDark ? Colors.white54 : const Color(0xFF64748B),
      );
    }
    if (_isPasswordMode) {
      return IconButton(
        tooltip: _obscured ? 'Show password' : 'Hide password',
        icon: Icon(
          _obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 20,
          color: isDark ? Colors.white54 : const Color(0xFF64748B),
        ),
        onPressed: () {
          setState(() {
            _obscured = !_obscured;
          });
        },
      );
    }
    return null;
  }

  InputBorder _buildBorder(Color color, double radius, {double width = 1.0}) {
    if (widget.borderless) {
      return InputBorder.none;
    }
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = widget.borderRadius ?? AppStyle.radiusMd;

    final defaultBorderColor = widget.borderColor ??
        (isDark
            ? Colors.white.withValues(alpha: 0.12)
            : const Color(0xFFE2E8F0));

    final effectiveFillColor = widget.fillColor ??
        (isDark
            ? Colors.white.withValues(alpha: 0.05)
            : const Color(0xFFF8FAFC));

    final effectiveMaxLines = _isPasswordMode ? 1 : widget.maxLines;

    final hasAsterisk =
        widget.labelText != null && widget.labelText!.trim().endsWith('*');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.labelText != null && widget.labelText!.isNotEmpty) ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  widget.labelText!,
                  style: widget.labelStyle ??
                      TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: widget.labelColor ??
                            (isDark
                                ? Colors.white.withValues(alpha: 0.85)
                                : const Color(0xFF334155)),
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.isRequired && !hasAsterisk) ...[
                const SizedBox(width: 4),
                const Text(
                  '*',
                  style: TextStyle(
                    color: AppStyle.error,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
        ],
        // iOS-style editing on every platform (look, gestures, loupe).
        IosStyleTextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          focusNode: widget.focusNode,
          autofocus: widget.autofocus,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          obscureText: _isPasswordMode ? _obscured : false,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          maxLines: effectiveMaxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          maxLengthEnforcement: widget.maxLengthEnforcement,
          inputFormatters: widget.inputFormatters,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onSaved: widget.onSaved,
          onFieldSubmitted: widget.onFieldSubmitted,
          onTap: widget.onTap,
          textAlign: widget.textAlign,
          textAlignVertical: widget.textAlignVertical,
          style: widget.style ??
              TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: widget.hintStyle ??
                TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                ),
            helperText: widget.helperText,
            errorText: widget.errorText,
            filled: widget.filled ?? true,
            fillColor: effectiveFillColor,
            prefix: widget.prefix,
            prefixIcon: _buildPrefixIcon(isDark),
            suffix: widget.suffix,
            suffixIcon: _buildSuffixIcon(isDark),
            contentPadding: widget.contentPadding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: _buildBorder(defaultBorderColor, radius),
            enabledBorder: _buildBorder(defaultBorderColor, radius),
            focusedBorder: _buildBorder(
              widget.focusedBorderColor ?? AppStyle.primaryColor,
              radius,
              width: 1.5,
            ),
            errorBorder: _buildBorder(AppStyle.error, radius, width: 1.0),
            focusedErrorBorder:
                _buildBorder(AppStyle.error, radius, width: 1.5),
            disabledBorder: _buildBorder(
              isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : const Color(0xFFF1F5F9),
              radius,
            ),
          ),
        ),
      ],
    );
  }
}

/// Convenience aliases ensuring backward compatibility and flexible naming across the app
typedef AppTextFieldWidget = AppTextField;
typedef CustomTextField = AppTextField;
typedef CustomTextFieldWidget02 = AppTextField;
typedef AuthTextField = AppTextField;
