class SurveyStat {
  final String question;
  final double average;

  SurveyStat({
    required this.question,
    required this.average,
  });

  factory SurveyStat.fromJson(Map<String, dynamic> json) {
    return SurveyStat(
      question: json['question__text'],
      average: json['average_rating'],
    );
  }
}


class CityWideSurveyStat {
  final String question;
  final double average;

  CityWideSurveyStat({
    required this.question,
    required this.average,
  });

  factory CityWideSurveyStat.fromJson(Map<String, dynamic> json) {
    return CityWideSurveyStat(
      question: json['question'],
      average: json['average'],
    );
  }
}

class CategoryCorrelationStat {
  final int categoryId;
  final String categoryName;
  final double averageRating;
  final int complaintCount;

  CategoryCorrelationStat({
    required this.categoryId,
    required this.categoryName,
    required this.averageRating,
    required this.complaintCount,
  });

  factory CategoryCorrelationStat.fromJson(Map<String, dynamic> json) {
    return CategoryCorrelationStat(
      categoryId: json['category_id'],
      categoryName: json['category_name'],
      averageRating: (json['average_rating'] as num).toDouble(),
      complaintCount: json['complaint_count'],
    );
  }
}
