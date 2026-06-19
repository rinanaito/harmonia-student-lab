class DFile {
  String key = "";
  String name = "";
  String thumbnail = "";
  String type = "";

  DFile();

  factory DFile.fromMap(String key, Map<dynamic, dynamic> data) {
    return DFile()
      ..key = key
      ..name = data['name'] ?? ''
      ..thumbnail = data['thumbnail '] ?? ''
      ..type = data['type'];
  }
  Map<String, dynamic> toMap() {
    return {'name': name, 'thumbnail ': thumbnail, 'type': type};
  }
}
