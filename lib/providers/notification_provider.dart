import '../../di/dependency_injection.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'dart:developer';
import '../model/notification_model.dart';
import '../service/firebase/firebase_api_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationProvider extends ChangeNotifier {
  final FirebaseApiNotifications _apiNotifications =
      locator<FirebaseApiNotifications>();
  final User? user = locator<FirebaseAuth>().currentUser;
  final FirebaseFirestore _firestore = locator<FirebaseFirestore>();
  final unreadCount = ValueNotifier<int>(0);
  var notificationsEnabled = true;
  final int notificationsLimit = 7;
  DocumentSnapshot? lastDocument;
  bool _hasMoreNotifications = true;
  bool _isLoading = false;
  final List<NotificationModel> _notifications = [];
  final Set<String> _notificationIds = {};
  late StreamSubscription<QuerySnapshot> _notificationSubscription =
      const Stream<QuerySnapshot>.empty().listen((_) {});

  NotificationProvider() {
    _initializeProvider();
  }

  Future<void> _initializeProvider() async {
    await Future.wait([
      _loadPreferences(),
      _fetchInitialNotifications(),
      _listenToUnreadCount(),
    ]);

    setupNotificationListener();
  }

  @override
  void dispose() {
    _notificationSubscription.cancel();
    super.dispose();
  }

  Future<void> _listenToUnreadCount() async {
    _apiNotifications.getUnreadCount().listen((countNoti) {
      unreadCount.value = countNoti;
      log('Unread notifications count: ${unreadCount.value}');
      notifyListeners();
    });
  }

  Future<void> markAllAsRead() async {
    final userId = user?.uid;
    if (userId != null) {
      final snapshots = await _apiNotifications.getUnreadNotifications();
      for (var doc in snapshots.docs) {
        doc.reference.update({'isRead': true});
      }
      unreadCount.value = 0;
      notifyListeners();
    }
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    notifyListeners();
  }

  void updateNotificationPreference(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', isEnabled);
    notificationsEnabled = isEnabled;
    notifyListeners();

    await _firestore.collection('users').doc(user!.uid).update({
      'notificationsEnabled': isEnabled,
    });
  }

  void setupNotificationListener() {
    _notificationSubscription = _firestore
        .collection('users')
        .doc(user!.uid)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docChanges.isNotEmpty) {
        onRefresh();
      }
    });
  }

  Future<void> toggleDetailSeen(
      String notificationId, bool isDetailSeen) async {
    try {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(
          isDetailSeen: isDetailSeen,
        );
        notifyListeners();
      }
      await _firestore
          .collection('users')
          .doc(user!.uid)
          .collection('notifications')
          .doc(notificationId)
          .update({'isDetailSeen': isDetailSeen});

      log('Notification $notificationId detail seen status toggled to $isDetailSeen in Firestore');
    } catch (e) {
      log('Error toggling detail seen status: $e');
    }
  }

  Future<void> _fetchInitialNotifications() async {
    await fetchNotifications();
  }

  Future<void> fetchNotifications({bool isLoadMore = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('users')
          .doc(user!.uid)
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .limit(notificationsLimit);

      if (lastDocument != null && isLoadMore) {
        query = query.startAfterDocument(lastDocument!);
      }

      final snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        final newNotifications =
            await Future.wait(snapshot.docs.map((doc) async {
          final data = doc.data();
          data['id'] = doc.id;

          final String? postId = data['postId'] as String?;
          if (postId != null && postId.isNotEmpty) {
            final postSnapshot =
                await _firestore.collection('posts').doc(postId).get();
            if (postSnapshot.exists) {
              final postData = postSnapshot.data();
              if (postData != null) {
                data['post'] = {
                  'id': postData['id'] ?? '',
                  'title': postData['title'] ?? 'No Title',
                  'contentPreview':
                      postData['contentPreview'] ?? 'No Content Preview',
                  'contentSections': postData['contentSections'] ?? [],
                  'timestamp': postData['timestamp'] ?? Timestamp.now(),
                };
              }
            }
          }

          return NotificationModel.fromMap(data);
        }).toList());

        for (final notification in newNotifications) {
          if (_notificationIds.add(notification.id)) {
            _notifications.add(notification);
          }
        }

        lastDocument = snapshot.docs.last;

        if (newNotifications.length < notificationsLimit) {
          _hasMoreNotifications = false;
        }
      } else {
        _hasMoreNotifications = false;
      }
    } catch (e) {
      log('Error fetching notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Categorize notifications based on timestamp
  List<NotificationModel> getNewNotifications() {
    final DateTime now = DateTime.now();
    final DateTime tenMinutesAgo = now.subtract(const Duration(minutes: 29));

    return _notifications.where((notification) {
      return notification.timestamp.isAfter(tenMinutesAgo);
    }).toList();
  }

  List<NotificationModel> getTodayNotifications() {
    final DateTime now = DateTime.now();
    final DateTime startOfToday = DateTime(now.year, now.month, now.day);

    return _notifications.where((notification) {
      return notification.timestamp.isAfter(startOfToday) &&
          notification.timestamp
              .isBefore(now.subtract(const Duration(minutes: 10)));
    }).toList();
  }

  List<NotificationModel> getEarlierNotifications() {
    final DateTime now = DateTime.now();
    final DateTime startOfToday = DateTime(now.year, now.month, now.day);

    return _notifications.where((notification) {
      return notification.timestamp.isBefore(startOfToday);
    }).toList();
  }

  Future<void> onRefresh() async {
    _notifications.clear();
    _notificationIds.clear();
    lastDocument = null;
    _hasMoreNotifications = true;
    notifyListeners();
    await fetchNotifications();
  }

  Future<void> onLoading() async {
    if (_hasMoreNotifications && !_isLoading) {
      await fetchNotifications(isLoadMore: true);
    }
  }

  List<NotificationModel> get notifications => _notifications;
  bool get hasMoreNotifications => _hasMoreNotifications;
  bool get isLoading => _isLoading;
}
