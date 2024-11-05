import 'dart:convert';
import 'dart:developer';
import 'package:e_leaningapp/core/constants.dart';
import 'package:e_leaningapp/utils/show_error_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

import '../../di/dependency_injection.dart';

class StripeService {
  StripeService._();
   final User? user = locator<FirebaseAuth>().currentUser;
  static final StripeService instance = StripeService._();
  Future<void> createPaymentIntent(String amount, String currency) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/payment/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(
            {'amount': amount, 'currency': currency, 'userId': user!.uid}),
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);

        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            style: ThemeMode.dark,
            paymentIntentClientSecret: body['clientSecret'],
            merchantDisplayName: 'Only Learning',
          ),
        );

        await Stripe.instance.presentPaymentSheet();

        showSnackbar('Payment Successful');
      } else {
        throw Exception('Failed to create payment intent');
      }
    } catch (e) {
      log('payment error : $e');
      showSnackbar('Payment Failed');
    }
  }
}
