import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:only_dev_app/model/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  final ValueNotifier<int> unreadCount = ValueNotifier<int>(0);
  bool notificationsEnabled = true;
  final bool _hasMoreNotifications = false;
  bool _isLoading = false;
  final List<NotificationModel> _notifications = [];
  final Set<String> _notificationIds = {};
  static const String _storageKey = 'local_notifications';

  NotificationProvider() {
    _initializeProvider();
  }

  Future<void> _initializeProvider() async {
    await Future.wait([
      _loadPreferences(),
      _fetchInitialNotifications(),
    ]);
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    notifyListeners();
  }

  Future<void> updateNotificationPreference(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', isEnabled);
    notificationsEnabled = isEnabled;
    notifyListeners();
  }

  Future<void> _fetchInitialNotifications() async {
    await fetchNotifications();
  }

  Future<void> fetchNotifications({bool isLoadMore = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedList = prefs.getStringList(_storageKey) ?? [];
      _notifications.clear();
      _notificationIds.clear();

      for (var str in savedList) {
        try {
          final map = jsonDecode(str) as Map<String, dynamic>;
          final notif = NotificationModel.fromMap(map);
          if (_notificationIds.add(notif.id)) {
            _notifications.add(notif);
          }
        } catch (_) {}
      }
      _recalculateUnread();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _recalculateUnread() {
    unreadCount.value = _notifications.where((n) => !n.isRead).length;
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _notifications.map((n) => jsonEncode(n.toMap())).toList();
    await prefs.setStringList(_storageKey, jsonList);
  }

  Future<void> addNotification(NotificationModel notification) async {
    if (_notificationIds.add(notification.id)) {
      _notifications.insert(0, notification);
      _recalculateUnread();
      await _saveToStorage();
      notifyListeners();
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((notification) => notification.id == notificationId);
    _notificationIds.remove(notificationId);
    _recalculateUnread();
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> markAllAsRead() async {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    unreadCount.value = 0;
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> toggleDetailSeen(
      String notificationId, bool isDetailSeen) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(
        isDetailSeen: isDetailSeen,
      );
      await _saveToStorage();
      notifyListeners();
    }
  }

  List<NotificationModel> getNewNotifications() {
    final DateTime now = DateTime.now();
    final DateTime tenMinutesAgo = now.subtract(const Duration(minutes: 29));

    return _notifications.where((notification) {
      final dt = DateTime.tryParse(notification.createdAt ?? '');
      return dt != null && dt.isAfter(tenMinutesAgo);
    }).toList();
  }

  List<NotificationModel> getTodayNotifications() {
    final DateTime now = DateTime.now();
    final DateTime startOfToday = DateTime(now.year, now.month, now.day);

    return _notifications.where((notification) {
      final dt = DateTime.tryParse(notification.createdAt ?? '');
      return dt != null &&
          dt.isAfter(startOfToday) &&
          dt.isBefore(now.subtract(const Duration(minutes: 10)));
    }).toList();
  }

  List<NotificationModel> getEarlierNotifications() {
    final DateTime now = DateTime.now();
    final DateTime startOfToday = DateTime(now.year, now.month, now.day);

    return _notifications.where((notification) {
      final dt = DateTime.tryParse(notification.createdAt ?? '');
      return dt != null && dt.isBefore(startOfToday);
    }).toList();
  }

  Future<void> onRefresh() async {
    await fetchNotifications();
  }

  Future<void> onLoading() async {
    // Local notifications are loaded all at once
  }

  List<NotificationModel> get notifications => _notifications;
  bool get hasMoreNotifications => _hasMoreNotifications;
  bool get isLoading => _isLoading;
}
