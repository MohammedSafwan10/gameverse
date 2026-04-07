import '../models/quiz_question.dart';

abstract class QuizQuestionLoader {
  Future<List<QuizQuestion>> getQuestions({
    required String categoryId,
    required int count,
  });
}
