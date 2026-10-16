import 'package:only_dev_app/di/dependency_injection.dart';
import 'package:firebase_auth/firebase_auth.dart';

// backend url
const baseUrl = "http://54.252.157.182";
const renderUrl = "https://e-learning-pwbu.onrender.com";

// Customize
const int kPreloadLimit = 3;

// Customize
const int kNextLimit = 5;

// For better UX, latency should be minimum.
// For demo: 2s is taken but something under a second will be better
const int kLatency = 2;

String get currentUserId => locator<FirebaseAuth>().currentUser?.uid ?? '';
