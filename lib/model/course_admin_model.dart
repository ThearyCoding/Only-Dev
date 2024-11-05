import 'package:e_leaningapp/model/courses_model.dart';
import 'package:e_leaningapp/model/admin_model.dart';

class CourseWithAdmin {
  final CourseModel course;
  final AdminModel admin;

  CourseWithAdmin({
    required this.course,
    required this.admin,
  });
}