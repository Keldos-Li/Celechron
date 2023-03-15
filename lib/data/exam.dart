import '../utils/timehelper.dart';

class Exam {
  String id;
  String name;
  ExamType type;

  // 第一个元素是开始时间，第二个元素是结束时间
  late List<DateTime> time;
  String? location;
  String? seat;

  Exam._fromExam(this.id, this.name, Map<String, dynamic> examList, this.type)
  {
    switch (type) {
      case ExamType.midterm:
        time = TimeHelper.parseExamDateTime(examList['qzkssj']);
        location = examList['qzksdd'];
        seat = examList['qzzwxh'];
        break;
      case ExamType.finalExam:
        time = TimeHelper.parseExamDateTime(examList['qmkssj']);
        location = examList['qmksdd'];
        seat = examList['zwxh'];
        break;
    }
  }

  static List<Exam> parseExams(String id, String name, Map<String, dynamic> json) {
    var exams = <Exam>[];
    if (json.containsKey("qzkssj")) exams.add(Exam._fromExam(id, name, json, ExamType.midterm));
    if (json.containsKey("qmkssj")) exams.add(Exam._fromExam(id, name, json, ExamType.finalExam));
    return exams;
  }
}

enum ExamType { midterm, finalExam }