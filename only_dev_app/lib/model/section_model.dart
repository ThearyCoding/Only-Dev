import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:only_dev_app/model/lecture_model.dart';

class Section {
  String id;
  String title;
  String learningObjective;
  List<Lecture> lectures;
  String courseId;

  Section({
    required this.id,
    required this.title,
    required this.learningObjective,
    required this.lectures,
    required this.courseId,
  });

  factory Section.empty() {
    return Section(
      id: '',
      title: '',
      learningObjective: '',
      lectures: [],
      courseId: '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'learning_objective': learningObjective,
      'lectures': lectures.map((lecture) => lecture.toMap()).toList(),
      'course_id': courseId,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory Section.fromMap(Map<String, dynamic> map) {
    return Section(
      id: (map['id'] ?? map['_id'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      learningObjective: (map['learning_objective'] ?? map['learningObjective'] ?? '').toString(),
      lectures: (map['lectures'] as List<dynamic>?)
              ?.map((x) => Lecture.fromMap(x as Map<String, dynamic>))
              .toList() ??
          [],
      courseId: (map['course_id'] ?? map['courseId'] ?? '').toString(),
    );
  }

  factory Section.fromJson(Map<String, dynamic> json) => Section.fromMap(json);

  factory Section.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = (doc.data() as Map<String, dynamic>?) ?? {};
    return Section.fromMap({'id': doc.id, ...data});
  }
}
