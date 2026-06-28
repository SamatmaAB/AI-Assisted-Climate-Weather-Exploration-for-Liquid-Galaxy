import 'package:hive/hive.dart';
import '../models/qa_item.dart';

class QACacheService {
  static final Box<QAItem> _box =
  Hive.box<QAItem>('qaBox');

  static List<QAItem> getQuestions() {
    return _box.values.toList();
  }

  static bool hasQuestions() {
    return _box.isNotEmpty;
  }

  static Future<void> saveQuestions(
      List<QAItem> questions,
      ) async {
    await _box.clear();

    for (var item in questions) {
      await _box.add(item);
    }
  }

  static QAItem? getQuestion(
      String question,
      ) {
    try {
      return _box.values.firstWhere(
            (e) => e.question == question,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> updateAnswer(
      String question,
      String answer,
      ) async {
    final item = getQuestion(question);

    if (item == null) return;

    item.answer = answer;
    item.isAnswered = true;

    await item.save();
  }
}