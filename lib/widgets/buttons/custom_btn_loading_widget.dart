import 'package:flutter/material.dart';
import 'package:loading_btn/loading_btn.dart';

class CustomBtnLoadingWidget extends StatefulWidget {
  final String btnText;
  final dynamic Function(Function, Function, ButtonState)? onTap;
  final Color? backgroundColor;
  final double borderRadius;

  const CustomBtnLoadingWidget({
    super.key,
    this.onTap,
    required this.btnText,
    this.backgroundColor = Colors.green,
    this.borderRadius = 0.0
  });

  @override
  CustomBtnLoadingWidgetState createState() => CustomBtnLoadingWidgetState();
}

class CustomBtnLoadingWidgetState extends State<CustomBtnLoadingWidget> {
  ButtonState btnState = ButtonState.idle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: AbsorbPointer(
              absorbing: btnState == ButtonState.busy,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: LoadingBtn(
                  height: 50,
                  borderRadius: widget.borderRadius,
                  roundLoadingShape: false,
                  animate: true,
                  // color:
                  //     btnState == ButtonState.busy ? Colors.grey : Colors.green,
                  color: widget.backgroundColor,
                  disabledColor: Colors.grey[500],
                  width: MediaQuery.of(context).size.width * 0.7,
                  loader: Container(
                    padding: const EdgeInsets.all(10),
                    width: 40,
                    height: 40,
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  onTap: btnState == ButtonState.idle
                      ? (startLoading, stopLoading, btnState) async {
                          setState(() {
                            this.btnState = ButtonState.busy;
                          });

                          startLoading();

                          // Check if a custom onTap function is provided
                          if (widget.onTap != null) {
                            await widget.onTap!(
                                startLoading, stopLoading, btnState);
                          }

                          // Stop loading animation
                          stopLoading();

                          // Reset button to idle state
                          setState(() {
                            this.btnState = ButtonState.idle;
                          });
                        }
                      : null,
                  child: Text(
                    widget.btnText,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
