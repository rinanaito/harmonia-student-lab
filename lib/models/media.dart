class Media {
  String key = "";

  String studentId = "";
  String fileId = "";

  Media({this.studentId = "", this.fileId = ""}) {
    key = "$studentId++++++$fileId";
  }

  factory Media.fromKey(String key) {
    var s = key.toString().split("++++++").first;
    var f = key.toString().split("++++++").last;
    return Media()
      ..key = key
      ..studentId = s
      ..fileId = f;
  }
  @override
  String toString() {
    return "";
  }
}
