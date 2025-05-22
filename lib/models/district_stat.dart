class DistrictStats {
  final int districtId;
  final String districtName;
  final int total;
  final List<ComplaintStats> categories;

  DistrictStats({
    required this.districtId,
    required this.districtName,
    required this.total,
    required this.categories,
  });

  factory DistrictStats.fromJson(Map<String, dynamic> json) {
    return DistrictStats(
      districtId: json['district_id'],
      districtName: json['district_name'],
      total: json['total'],
      categories: (json['categories'] as List)
          .map((e) => ComplaintStats.fromJson(e))
          .toList(),
    );
  }
}

class ComplaintStats {
  final int id;
  final String name;
  final int count;

  ComplaintStats({required this.id, required this.name, required this.count});

  factory ComplaintStats.fromJson(Map<String, dynamic> json) {
    return ComplaintStats(
      id: json['id'],
      name: json['name'],
      count: json['count'],
    );
  }
}
