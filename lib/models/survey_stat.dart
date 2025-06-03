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
