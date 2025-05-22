class SurveyQuestion {
  final int id;
  final String text;

  SurveyQuestion({required this.id, required this.text});

  factory SurveyQuestion.fromJson(Map<String, dynamic> json) {
    return SurveyQuestion(
      id: json['id'],
      text: json['text'],
    );
  }
}