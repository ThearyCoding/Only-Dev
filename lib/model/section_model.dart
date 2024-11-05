import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_leaningapp/model/lecture_model.dart';

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'learningObjective': learningObjective,
      'lectures': lectures.map((lecture) => lecture.toJson()).toList(),
      'courseId': courseId,
    };
  }
factory Section.fromMap(Map<String, dynamic> map) {
  return Section(
    id: map['id'] ?? '',
    title: map['title'] ?? '',
    learningObjective: map['learningObjective'] ?? '',
    lectures: (map['lectures'] as List<dynamic>?)
            ?.map((x) => Lecture.fromMap(x as Map<String, dynamic>))
            .toList() ??
        [],
    courseId: map['courseId'] ?? '',
  );
}

  factory Section.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Section(
      id: data['id'],
      title: data['title'],
      learningObjective: data['learningObjective'],
      lectures: List<Lecture>.from(data['lectures']?.map((x) => Lecture.fromMap(x)) ?? []),
      courseId: data['courseId'],
    );
  }
}
