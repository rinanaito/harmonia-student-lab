class Media {
  String key = "";
  String hash = "";

  Media();

  factory Media.fromMap(
      String key,
      Map<dynamic, dynamic> data,
      ) {
    return Media()..key = key..hash = data['hash'] ?? '';
  }

  Map<String, dynamic> toMap() {
    return {
      'hash': hash,
    };
  }
}