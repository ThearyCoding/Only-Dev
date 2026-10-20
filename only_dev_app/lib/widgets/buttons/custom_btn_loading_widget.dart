import 'package:flutter/material.dart';
import 'package:loading_btn/loading_btn.dart';

class CustomBtnLoadingWidget extends StatefulWidget {
  final String btnText;
  final dynamic Function(Function, Function, ButtonState)? onTap;
  final Color? backgroundColor;
  final double borderRadius;
  final bool? isInput;
  final TextStyle? textStyle;

  const CustomBtnLoadingWidget({
    super.key,
    this.onTap,
    required this.btnText,
    this.backgroundColor,
    this.borderRadius = 8.0,
    this.isInput = false,
    this.textStyle,
  });

  @override
  CustomBtnLoadingWidgetState createState() => CustomBtnLoadingWidgetState();
}

class CustomBtnLoadingWidgetState extends State<CustomBtnLoadingWidget> {
  ButtonState btnState = ButtonState.idle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = widget.backgroundColor ?? theme.primaryColor;

    return LayoutBuilder(
      builder: (context, constraints) {
        final btnWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;

        return AbsorbPointer(
          absorbing: btnState == ButtonState.busy,
          child: SizedBox(
            width: btnWidth,
            height: 50,
            child: LoadingBtn(
              height: 50,
              borderRadius: widget.borderRadius,
              roundLoadingShape: false,
              animate: true,
              color: buttonColor,
              elevation: 0,
              borderSide: BorderSide.none,
              width: btnWidth,
              loader: Container(
                padding: const EdgeInsets.all(10),
                width: 36,
                height: 36,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              onTap: btnState == ButtonState.idle
                  ? (startLoading, stopLoading, btnState) async {
                      if (mounted) {
                        setState(() {
                          this.btnState = ButtonState.busy;
                        });
                      }

                      startLoading();

                      if (widget.onTap != null) {
                        await widget.onTap!(
                            startLoading, stopLoading, btnState);
                      }

                      if (mounted) {
                        stopLoading();
                        setState(() {
                          this.btnState = ButtonState.idle;
                        });
                      }
                    }
                  : null,
              child: Text(
                widget.btnText,
                style: widget.textStyle ??
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
              ),
            ),
          ),
        );
      },
    );
  }
}

