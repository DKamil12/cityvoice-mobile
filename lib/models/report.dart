class Report {
  final int id;
  final String name;
  final String description;
  final String status;
  final String? image;
  final double? latitude;
  final double? longitude;
  final String categoryName;
  final String username;
  final String fullName;
  final String createdAt;
  final String? updatedAt;
  final List? comments;

  Report({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.image,
    required this.latitude,
    required this.longitude,
    required this.categoryName,
    required this.username,
    required this.fullName,
    required this.createdAt,
    required this.updatedAt,
    required this.comments,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      status: json['status'],
      image: json['image'],
      latitude: json['latitude'],
      longitude: json['longtitude'], 
      categoryName: json['category']['name'],
      username: json['user']['username'],
      fullName: '${json['user']['first_name']} ${json['user']['last_name']}',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      comments: json['comments'],
    );
  }
}
