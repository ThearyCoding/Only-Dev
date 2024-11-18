// stripe api keys
import 'package:e_leaningapp/di/dependency_injection.dart';
import 'package:firebase_auth/firebase_auth.dart';

const String publishablekey =
    "pk_test_51PBHJqRt0f9BAsbbLzuKeLSGOiwHRfQPtaSp0EHVA4ulO8khidCkISzNN3Ca9Zx2jZHbOyaI8DNOPfOjYFqdQvpS00pvZnE0Mg";
const String secretkey =
    "sk_test_51PBHJqRt0f9BAsbbY9tGwO8xLFUsWRHOzIbdLtLxqqelqnumwlQ5CeqHdLynhRn27YSHQWZ5Sbd0JwapjgE9FWU100i9eBxCRQ";

// backend url
const baseUrl = "http://172.20.10.2:3000";
const renderUrl = "https://e-learning-pwbu.onrender.com";

// Customize
const int kPreloadLimit = 3;

// Customize
const int kNextLimit = 5;

// For better UX, latency should be minimum.
// For demo: 2s is taken but something under a second will be better
const int kLatency = 2;

final String userId = locator<FirebaseAuth>().currentUser!.uid;
