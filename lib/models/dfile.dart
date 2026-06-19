class DFile {
  String key = "";
  String name = "";
  String type = "";

  DFile();

  factory DFile.fromMap(String key, Map<dynamic, dynamic> data) {
    return DFile()
      ..key = key
      ..name = data['name'] ?? ''
      ..type = data['type'];
  }
  Map<String, dynamic> toMap() {
    return {'name': name, 'type': type};
  }
}
