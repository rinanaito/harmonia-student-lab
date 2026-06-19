class Media {
  String key = "";

  String studentId = "";
  String fileId = "";

  String folderId = "";
  String type = "";

  Media({this.studentId = "", this.fileId = "", this.folderId = ""}) {
    key = "$studentId++++++$fileId";
  }

  factory Media.fromKey(String key, String folderId) {
    var s = key.toString().split("++++++").first;
    var f = key.toString().split("++++++").last;
    return Media()
      ..key = key
      ..studentId = s
      ..fileId = f
      ..folderId = folderId;
  }

  @override
  String toString() {
    return folderId;
  }
}
