// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `E-Learning`
  String get appTitle {
    return Intl.message(
      'E-Learning',
      name: 'appTitle',
      desc: '',
      args: [],
    );
  }

  /// `Search Courses`
  String get searchCourses {
    return Intl.message(
      'Search Courses',
      name: 'searchCourses',
      desc: '',
      args: [],
    );
  }

  /// `Lessons`
  String get lessons {
    return Intl.message(
      'Lessons',
      name: 'lessons',
      desc: '',
      args: [],
    );
  }

  /// `Recent Lessons`
  String get recentLessons {
    return Intl.message(
      'Recent Lessons',
      name: 'recentLessons',
      desc: '',
      args: [],
    );
  }

  /// `Popular Lessons`
  String get popularLessons {
    return Intl.message(
      'Popular Lessons',
      name: 'popularLessons',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settingsTitle {
    return Intl.message(
      'Settings',
      name: 'settingsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get languageOption {
    return Intl.message(
      'Language',
      name: 'languageOption',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get english {
    return Intl.message(
      'English',
      name: 'english',
      desc: '',
      args: [],
    );
  }

  /// `Khmer`
  String get khmer {
    return Intl.message(
      'Khmer',
      name: 'khmer',
      desc: '',
      args: [],
    );
  }

  /// `Edit Profile`
  String get editProfile {
    return Intl.message(
      'Edit Profile',
      name: 'editProfile',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get notifications {
    return Intl.message(
      'Notifications',
      name: 'notifications',
      desc: '',
      args: [],
    );
  }

  /// `My Courses`
  String get myCourses {
    return Intl.message(
      'My Courses',
      name: 'myCourses',
      desc: '',
      args: [],
    );
  }

  /// `Log Out`
  String get logOut {
    return Intl.message(
      'Log Out',
      name: 'logOut',
      desc: '',
      args: [],
    );
  }

  /// `Error loading user data. Please try again.`
  String get errorLoadingUserData {
    return Intl.message(
      'Error loading user data. Please try again.',
      name: 'errorLoadingUserData',
      desc: '',
      args: [],
    );
  }

  /// `Your Account`
  String get yourAccount {
    return Intl.message(
      'Your Account',
      name: 'yourAccount',
      desc: '',
      args: [],
    );
  }

  /// `App Settings`
  String get appSettings {
    return Intl.message(
      'App Settings',
      name: 'appSettings',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get notificationsTitle {
    return Intl.message(
      'Notifications',
      name: 'notificationsTitle',
      desc: '',
      args: [],
    );
  }

  /// `My Courses`
  String get myCoursesTitle {
    return Intl.message(
      'My Courses',
      name: 'myCoursesTitle',
      desc: '',
      args: [],
    );
  }

  /// `Ongoing`
  String get ongoing {
    return Intl.message(
      'Ongoing',
      name: 'ongoing',
      desc: '',
      args: [],
    );
  }

  /// `Downloaded`
  String get downloaded {
    return Intl.message(
      'Downloaded',
      name: 'downloaded',
      desc: '',
      args: [],
    );
  }

  /// `Completed`
  String get completed {
    return Intl.message(
      'Completed',
      name: 'completed',
      desc: '',
      args: [],
    );
  }

  /// `No registered courses found.`
  String get noRegisteredCoursesFound {
    return Intl.message(
      'No registered courses found.',
      name: 'noRegisteredCoursesFound',
      desc: '',
      args: [],
    );
  }

  /// `No completed courses found.`
  String get noCompletedCoursesFound {
    return Intl.message(
      'No completed courses found.',
      name: 'noCompletedCoursesFound',
      desc: '',
      args: [],
    );
  }

  /// `Video removed: {videoTitle}`
  String videoRemoved(Object videoTitle) {
    return Intl.message(
      'Video removed: $videoTitle',
      name: 'videoRemoved',
      desc: '',
      args: [videoTitle],
    );
  }

  /// `Video not found: {videoTitle}`
  String videoNotFound(Object videoTitle) {
    return Intl.message(
      'Video not found: $videoTitle',
      name: 'videoNotFound',
      desc: '',
      args: [videoTitle],
    );
  }

  /// `Failed to remove video: {error}`
  String failedToRemoveVideo(Object error) {
    return Intl.message(
      'Failed to remove video: $error',
      name: 'failedToRemoveVideo',
      desc: '',
      args: [error],
    );
  }

  /// `All Courses`
  String get allCourses {
    return Intl.message(
      'All Courses',
      name: 'allCourses',
      desc: '',
      args: [],
    );
  }

  /// `No more courses available to load.`
  String get noMoreCoursesToLoad {
    return Intl.message(
      'No more courses available to load.',
      name: 'noMoreCoursesToLoad',
      desc: '',
      args: [],
    );
  }

  /// `No Courses available at this time! Pull down to refresh.`
  String get noCoursesAvailable {
    return Intl.message(
      'No Courses available at this time! Pull down to refresh.',
      name: 'noCoursesAvailable',
      desc: '',
      args: [],
    );
  }

  /// `courses`
  String get courses {
    return Intl.message(
      'courses',
      name: 'courses',
      desc: '',
      args: [],
    );
  }

  /// `Pull down to refresh`
  String get pullDownToRefresh {
    return Intl.message(
      'Pull down to refresh',
      name: 'pullDownToRefresh',
      desc: '',
      args: [],
    );
  }

  /// `Refresh complete`
  String get refreshComplete {
    return Intl.message(
      'Refresh complete',
      name: 'refreshComplete',
      desc: '',
      args: [],
    );
  }

  /// `Refresh failed`
  String get refreshFailed {
    return Intl.message(
      'Refresh failed',
      name: 'refreshFailed',
      desc: '',
      args: [],
    );
  }

  /// `Loading more...`
  String get loadingMore {
    return Intl.message(
      'Loading more...',
      name: 'loadingMore',
      desc: '',
      args: [],
    );
  }

  /// `No more {noDataText}`
  String noMoreData(Object noDataText) {
    return Intl.message(
      'No more $noDataText',
      name: 'noMoreData',
      desc: '',
      args: [noDataText],
    );
  }

  /// `Pull up to load more`
  String get pullUpToLoadMore {
    return Intl.message(
      'Pull up to load more',
      name: 'pullUpToLoadMore',
      desc: '',
      args: [],
    );
  }

  /// `Load failed, try again`
  String get loadFailedTryAgain {
    return Intl.message(
      'Load failed, try again',
      name: 'loadFailedTryAgain',
      desc: '',
      args: [],
    );
  }

  /// `Release to refresh`
  String get releaseToRefresh {
    return Intl.message(
      'Release to refresh',
      name: 'releaseToRefresh',
      desc: '',
      args: [],
    );
  }

  /// `Back`
  String get back {
    return Intl.message(
      'Back',
      name: 'back',
      desc: '',
      args: [],
    );
  }

  /// `No courses found for this category.`
  String get noCoursesFoundForThisCategory {
    return Intl.message(
      'No courses found for this category.',
      name: 'noCoursesFoundForThisCategory',
      desc: '',
      args: [],
    );
  }

  /// `Release to load more`
  String get canLoadingText {
    return Intl.message(
      'Release to load more',
      name: 'canLoadingText',
      desc: '',
      args: [],
    );
  }

  /// `Lecture by {name}`
  String lectureBy(Object name) {
    return Intl.message(
      'Lecture by $name',
      name: 'lectureBy',
      desc: '',
      args: [name],
    );
  }

  /// `Lectures`
  String get lectures {
    return Intl.message(
      'Lectures',
      name: 'lectures',
      desc: '',
      args: [],
    );
  }

  /// `students`
  String get students {
    return Intl.message(
      'students',
      name: 'students',
      desc: '',
      args: [],
    );
  }

  /// `Free`
  String get Free {
    return Intl.message(
      'Free',
      name: 'Free',
      desc: '',
      args: [],
    );
  }

  /// `Enroll Now`
  String get enrollnow {
    return Intl.message(
      'Enroll Now',
      name: 'enrollnow',
      desc: '',
      args: [],
    );
  }

  /// `Coming soon`
  String get Comingsoon {
    return Intl.message(
      'Coming soon',
      name: 'Comingsoon',
      desc: '',
      args: [],
    );
  }

  /// `This course will be available shortly.`
  String get Thiscoursewillbeavailableshortly {
    return Intl.message(
      'This course will be available shortly.',
      name: 'Thiscoursewillbeavailableshortly',
      desc: '',
      args: [],
    );
  }

  /// `NEW`
  String get NEW {
    return Intl.message(
      'NEW',
      name: 'NEW',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get Continue {
    return Intl.message(
      'Continue',
      name: 'Continue',
      desc: '',
      args: [],
    );
  }

  /// `quizzes`
  String get quiz {
    return Intl.message(
      'quizzes',
      name: 'quiz',
      desc: '',
      args: [],
    );
  }

  /// `No bio available`
  String get noBioAvailable {
    return Intl.message(
      'No bio available',
      name: 'noBioAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Internet connection is back!`
  String get internetConnectionRestored {
    return Intl.message(
      'Internet connection is back!',
      name: 'internetConnectionRestored',
      desc: '',
      args: [],
    );
  }

  /// `Please check your internet connection!`
  String get internetConnectionLost {
    return Intl.message(
      'Please check your internet connection!',
      name: 'internetConnectionLost',
      desc: '',
      args: [],
    );
  }

  /// `Log Out ?`
  String get logout_title {
    return Intl.message(
      'Log Out ?',
      name: 'logout_title',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to log out ?`
  String get logout_message {
    return Intl.message(
      'Are you sure you want to log out ?',
      name: 'logout_message',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get yes_button {
    return Intl.message(
      'Yes',
      name: 'yes_button',
      desc: '',
      args: [],
    );
  }

  /// `No Thanks!`
  String get no_button {
    return Intl.message(
      'No Thanks!',
      name: 'no_button',
      desc: '',
      args: [],
    );
  }

  /// `No notifications`
  String get no_notifications {
    return Intl.message(
      'No notifications',
      name: 'no_notifications',
      desc: '',
      args: [],
    );
  }

  /// `No more notification available to load.`
  String get no_more_notifications {
    return Intl.message(
      'No more notification available to load.',
      name: 'no_more_notifications',
      desc: '',
      args: [],
    );
  }

  /// `Today`
  String get today {
    return Intl.message(
      'Today',
      name: 'today',
      desc: '',
      args: [],
    );
  }

  /// `Earlier`
  String get earlier {
    return Intl.message(
      'Earlier',
      name: 'earlier',
      desc: '',
      args: [],
    );
  }

  /// `Choose Your Language`
  String get chooseLanguage {
    return Intl.message(
      'Choose Your Language',
      name: 'chooseLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Select Images`
  String get selectAssetsTitle {
    return Intl.message(
      'Select Images',
      name: 'selectAssetsTitle',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'km'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
