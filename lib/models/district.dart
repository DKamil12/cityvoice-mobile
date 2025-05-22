class District {
  final int id;
  final String name;
  final String image;

  District({
    required this.id,
    required this.name,
    required this.image,
  });

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['id'],
      name: json['name'],
      image: json['image'],
    );
  }
}
