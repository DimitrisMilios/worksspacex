class Workspace {
  final String id;
  final String name;
  final List<String> urls;
  final String? color; // Hex string

  Workspace({
    required this.id,
    required this.name,
    required this.urls,
    this.color,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'urls': urls,
      'color': color,
    };
  }

  factory Workspace.fromJson(Map<String, dynamic> json) {
    return Workspace(
      id: json['id'] as String,
      name: json['name'] as String,
      urls: List<String>.from(json['urls'] as Iterable),
      color: json['color'] as String?,
    );
  }

  Workspace copyWith({
    String? id,
    String? name,
    List<String>? urls,
    String? color,
  }) {
    return Workspace(
      id: id ?? this.id,
      name: name ?? this.name,
      urls: urls ?? this.urls,
      color: color ?? this.color,
    );
  }
}
