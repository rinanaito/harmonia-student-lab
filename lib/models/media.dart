class Media {
  String key = "";
  String hash = "";

  String studentId = "";
  String fileId = "";

  Media();

  factory Media.fromMap(String key, Map<dynamic, dynamic> data) {
    var h = data['hash'] ?? '';
    var s = h.toString().split("#").first;
    var f = h.toString().split("#").last;
    return Media()
      ..key = key
      ..hash = h
      ..studentId = s
      ..fileId = f;
  }

  Map<String, dynamic> toMap() {
    return {'hash': "$studentId#$fileId"};
  }
}
