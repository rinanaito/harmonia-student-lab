class Student {
  final String id;
  final String name;
  final String? cls;
  final int? createdAt;

  Student({required this.id, required this.name, this.cls, this.createdAt});

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] as String,
      name: json['name'] as String,
      cls: json['class'] as String?,
      createdAt: json['createdAt'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'class': cls,
    'createdAt': createdAt,
  };
}
