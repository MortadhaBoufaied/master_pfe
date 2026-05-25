class GlobalSearchResult {
  final String entity;
  final int id;
  final String title;
  final String? subtitle;

  GlobalSearchResult({
    required this.entity,
    required this.id,
    required this.title,
    this.subtitle,
  });

  factory GlobalSearchResult.fromJson(Map<String, dynamic> json) {
    return GlobalSearchResult(
      entity: (json['entity'] ?? '').toString(),
      id: (json['id'] as num?)?.toInt() ?? int.tryParse('${json['id']}') ?? 0,
      title: (json['title'] ?? '').toString(),
      subtitle: json['subtitle']?.toString(),
    );
  }
}


