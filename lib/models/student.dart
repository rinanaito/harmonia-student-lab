class Student {
  String key = "";
  String code = "";
  String name = "";
  String group = "";

  Student();

  factory Student.fromMap(String key, Map<dynamic, dynamic> data) {
    return Student()
      ..key = key
      ..code = data['code'] ?? ''
      ..name = data['name'] ?? ''
      ..group = data['group'] ?? '';
  }

  Map<String, dynamic> toMap() {
    return {'code': code, 'name': name, 'group': group};
  }
}
