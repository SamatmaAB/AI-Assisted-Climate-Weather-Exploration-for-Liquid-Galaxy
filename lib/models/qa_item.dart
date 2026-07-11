import 'package:hive/hive.dart';

part 'qa_item.g.dart';

@HiveType(typeId: 0)
class QAItem extends HiveObject {
  @HiveField(0)
  String question;

  @HiveField(1)
  String? answer;

  @HiveField(2)
  bool isAnswered;

  QAItem({
    required this.question,
    this.answer,
    this.isAnswered = false,
  });
}