class Student {
  String key = "";
  String oldKey = "";
  String name = "";
  String group = "";

  Student();

  factory Student.fromMap(String key, Map<dynamic, dynamic> data) {
    return Student()
      ..key = key
      ..oldKey = key
      ..name = data['name'] ?? ''
      ..group = data['group'] ?? '';
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'group': group};
  }
}
