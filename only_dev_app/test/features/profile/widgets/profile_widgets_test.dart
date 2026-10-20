import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:only_dev_app/features/profile/widgets/profile_header_card.dart';
import 'package:only_dev_app/features/profile/widgets/profile_menu_group.dart';
import 'package:only_dev_app/features/profile/widgets/profile_menu_item.dart';
import 'package:only_dev_app/features/profile/widgets/profile_stats_card.dart';
import 'package:only_dev_app/model/user_model.dart';

void main() {
  final sampleUser = UserModel(
    uid: 'usr-123',
    firstName: 'Theary',
    lastName: 'Chorn',
    fullName: 'Theary Chorn',
    photoURL: '',
    email: 'student@onlydev.com',
    gender: 1,
    dob: '2000-01-01',
    bgColor: 'FFFFFFFF',
    backgroundColor: '#3B82F6',
    role: 'STUDENT',
    headline: 'Senior Flutter Developer',
    bio: 'Coding high performance mobile applications',
    createdAt: '2026-01-15T10:00:00.000Z',
  );

  group('ProfileHeaderCard Tests', () {
    testWidgets('renders user fullName, role pill, email, and headline', (tester) async {
      bool cameraTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileHeaderCard(
              user: sampleUser,
              onCameraTap: () => cameraTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Theary Chorn'), findsOneWidget);
      expect(find.text('STUDENT'), findsOneWidget);
      expect(find.text('student@onlydev.com'), findsOneWidget);
      expect(find.text('Senior Flutter Developer'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.camera_alt_rounded));
      await tester.pumpAndSettle();
      expect(cameraTapped, isTrue);
    });
  });

  group('ProfileStatsCard Tests', () {
    testWidgets('renders enrolled courses count, role, and joined year', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileStatsCard(
              user: sampleUser,
              enrolledCoursesCount: 5,
            ),
          ),
        ),
      );

      expect(find.text('5'), findsOneWidget);
      expect(find.text('Courses'), findsOneWidget);
      expect(find.text('STUDENT'), findsOneWidget);
      expect(find.text('Role'), findsOneWidget);
      expect(find.text('2026'), findsOneWidget);
      expect(find.text('Joined'), findsOneWidget);
    });
  });

  group('ProfileMenuItem and ProfileMenuGroup Tests', () {
    testWidgets('renders menu group with items and executes onTap', (tester) async {
      bool itemTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileMenuGroup(
              title: 'Account',
              items: [
                ProfileMenuItem(
                  icon: Icons.person_outline,
                  iconColor: Colors.blue,
                  title: 'Edit Profile',
                  subtitle: 'Change name and bio',
                  onTap: () => itemTapped = true,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('ACCOUNT'), findsOneWidget);
      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Change name and bio'), findsOneWidget);

      await tester.tap(find.text('Edit Profile'));
      await tester.pumpAndSettle();
      expect(itemTapped, isTrue);
    });
  });
}

