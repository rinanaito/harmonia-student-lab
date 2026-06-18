class Album {
  String key = "";
  String name = "";
  Album();

  factory Album.fromMap(String key, Map<dynamic, dynamic> data) {
    return Album()
      ..key = key
      ..name = data['name'] ?? '';
  }

  Map<String, dynamic> toMap() {
    return {'name': name};
  }
}
