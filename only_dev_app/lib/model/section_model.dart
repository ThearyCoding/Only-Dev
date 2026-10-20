import 'package:only_dev_app/model/lecture_model.dart';

class Section {
  String id;
  String title;
  String learningObjective;
  List<Lecture> lectures;
  String courseId;
  String? createdAt;
  String? updatedAt;
  String? createdBy;
  String? updatedBy;

  Section({
    required this.id,
    required this.title,
    required this.learningObjective,
    required this.lectures,
    required this.courseId,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  factory Section.empty() {
    return Section(
      id: '',
      title: '',
      learningObjective: '',
      lectures: [],
      courseId: '',
      createdAt: '',
      updatedAt: '',
      createdBy: '',
      updatedBy: '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'learning_objective': learningObjective,
      'lectures': lectures.map((lecture) => lecture.toMap()).toList(),
      'course_id': courseId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'created_by': createdBy,
      'updated_by': updatedBy,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory Section.fromMap(Map<String, dynamic> map) {
    return Section(
      id: (map['id'] ?? map['_id'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      learningObjective: (map['learning_objective'] ?? map['learningObjective'] ?? '').toString(),
      lectures: ((map['lectures'] ?? map['lessons']) as List<dynamic>?)
              ?.map((x) => Lecture.fromMap(x as Map<String, dynamic>))
              .toList() ??
          [],
      courseId: (map['course_id'] ?? map['courseId'] ?? '').toString(),
      createdAt: (map['created_at'] ?? map['createdAt'] ?? map['timestamp'])?.toString(),
      updatedAt: (map['updated_at'] ?? map['updatedAt'])?.toString(),
      createdBy: (map['created_by'] ?? map['createdBy'])?.toString(),
      updatedBy: (map['updated_by'] ?? map['updatedBy'])?.toString(),
    );
  }

  factory Section.fromJson(Map<String, dynamic> json) => Section.fromMap(json);

  factory Section.fromFirestore(dynamic doc) {
    Map<String, dynamic> data = (doc.data() as Map<String, dynamic>?) ?? {};
    return Section.fromMap({'id': doc.id, ...data});
  }
}
