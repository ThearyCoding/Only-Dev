import 'package:flutter/material.dart';
import 'package:khqr_widget/khqr_widget.dart';

class KhqrPaymentPage extends StatelessWidget {
  const KhqrPaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return KhqrWidget(
            width: 300,
            receiverName: "Only Dev",
            amount: "25.00",
            currency: "USD",
            qr: "YOUR_QR_DATA",
            duration: const Duration(minutes: 1),
            onRetry: () {
             
            },
            clearAmountIcon: const Icon(
              Icons.clear_rounded,
              color: Colors.black,
            ),
            expiredIcon: Container(
              constraints: const BoxConstraints.expand(),
              color: Colors.green,
              child: const Icon(Icons.clear),
            ),
            onCountingDown: (p0) => Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(p0.inSeconds.toString()),
            ),
          );
  }
}