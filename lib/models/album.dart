class Album {
  String key = "";
  String name = "";
  String studentId = "";
  Album();

  factory Album.fromMap(String key, Map<dynamic, dynamic> data) {
    return Album()
      ..key = key
      ..name = data['name'] ?? ''
      ..studentId = data['studentId'] ?? '';
  }

  Map<String, dynamic> toMap() {
    if (studentId.isNotEmpty) {
      return {'name': name, "studentId": studentId};
    } else {
      return {'name': name};
    }
  }
}
