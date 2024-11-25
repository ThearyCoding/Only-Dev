import '../../routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

enum PaymentMethod { khqr, mastercard, stripe }

class PaymentOptionsPage extends StatefulWidget {
  const PaymentOptionsPage({super.key});

  @override
  State<PaymentOptionsPage> createState() => _PaymentOptionsPageState();
}

class _PaymentOptionsPageState extends State<PaymentOptionsPage> {
  final List<String> _logos = [
    'assets/KHQR-available-here-logo-with-bg-1024x422.webp',
    "assets/Stripe-Logo.webp",
    "assets/Mastercard-Logo.wine.svg",
  ];

  final List<String> _titles = [
    "KHQR Payment",
    "Stripe Payment",
    "Mastercard Payment"
  ];

  PaymentMethod? _selectedMethod;

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xffF0F2F5);
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: backgroundColor,
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 18,
            color: Colors.black,
          ),
          splashRadius: 20,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Payment Method",
                style: TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            ListView.builder(
                shrinkWrap: true,
                itemCount: _logos.length,
                itemBuilder: (ctx, index) {
                  return Card(
                      shape: ContinuousRectangleBorder(
                          borderRadius: BorderRadius.circular(40)),
                      child: _buildCard(index));
                })
          ],
        ),
      ),
      bottomSheet: _buildConfirm(),
    );
  }

  Widget _buildCard(int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          !_logos[index].contains('.svg')
              ? Image.asset(
                  _logos[index],
                  width: 50,
                )
              : SvgPicture.asset(
                  _logos[index],
                  width: 50,
                ),
          const SizedBox(width: 20),
          Text(_titles[index]),
          const Spacer(),
          Radio<PaymentMethod>(
            value: PaymentMethod.values[index],
            groupValue: _selectedMethod,
            onChanged: (value) {
              setState(() {
                _selectedMethod = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildConfirm() {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 10),
      width: double.infinity,
      height: 70,
      child: ElevatedButton(
        onPressed: _selectedMethod == null
            ? null
            : () {
                context.push(RoutesPath.khqrpaymentScreen);
              },
        child: const Text("Confirm"),
      ),
    );
  }
}
