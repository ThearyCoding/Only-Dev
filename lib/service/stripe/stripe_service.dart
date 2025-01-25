import 'dart:convert';
import 'dart:developer';
import 'package:e_leaningapp/core/constants.dart';
import 'package:e_leaningapp/utils/show_error_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

import '../../di/dependency_injection.dart';
import '../../providers/registration_provider.dart';

class StripeService {
  StripeService._();
  final User? user = locator<FirebaseAuth>().currentUser;
  static final StripeService instance = StripeService._();

  Future<void> createPaymentIntent(
    String amount,
    String currency,
    String courseId,
    String categoryId,
    String courseTitle,
    RegistrationProvider registrationProvider,
  ) async {
    try {
      // Step 1: Create Payment Intent
      final response = await http.post(
        Uri.parse('$baseUrl/api/payment/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(
            {'amount': amount, 'currency': currency, 'userId': user!.uid}),
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);

        // Step 2: Initialize Payment Sheet
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: body['clientSecret'],
            merchantDisplayName: 'Only Learning',
          ),
        );

        // Step 3: Present Payment Sheet
        await Stripe.instance.presentPaymentSheet();

        // Step 4: Register the User After Successful Payment
        await registrationProvider.registerUser(
          user!.uid,
          courseId,
          categoryId,
          courseTitle,
        );

        // Step 5: Confirm Registration and Show Success
        if (registrationProvider.isUserRegisteredForCourse(courseId)) {
          showSnackbar('Payment successful! You are now enrolled.');
        } else {
          throw Exception('Payment succeeded but registration failed.');
        }
      } else {
        throw Exception('Failed to create payment intent');
      }
    } catch (e) {
      if (e is StripeException) {
        switch (e.error.code) {
          case FailureCode.Canceled:
            log('Payment flow canceled by user');
            showSnackbar('Payment was canceled by you.');
            break;
          case FailureCode.Timeout:
            log('Payment flow timed out');
            showSnackbar('Payment timed out. Please try again.');
            break;
          case FailureCode.Failed:
            log('Payment failed');
            showSnackbar(
                'Payment failed. Please check your details and try again.');
            break;
          case FailureCode.Unknown:
            log('An unknown error occurred during payment');
            showSnackbar('An unexpected error occurred. Please try again.');
            break;
        }
      } else {
        log('Error during payment or registration: $e');
        showSnackbar('Payment Failed. Please try again.');
      }
    }
  }
}
