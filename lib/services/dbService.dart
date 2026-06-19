import 'package:firebase_database/firebase_database.dart';
import '../models/album.dart';
import '../models/media.dart';
import '../models/student.dart';

class dbService {
  final DatabaseReference db = FirebaseDatabase.instance.ref();
  static List<Student> students = <Student>[];
  static List<Media> medias = <Media>[];

  DatabaseReference dbStudent({String key = ""}) => db.child('students${key.isEmpty ? '' : '/$key'}');
  DatabaseReference dbAlbum({String key = ""}) => db.child('albums${key.isEmpty ? '' : '/$key'}');

  Future<List<Student>> get studentList4Info async {
    if (students.isEmpty) {
      final snapshot = await db.child('students').get();
      if (snapshot.value == null) {
        return [];
      }
      final data = snapshot.value as Map<dynamic, dynamic>;
      students = data.entries.map((e) {
        return Student.fromMap(e.key, e.value);
      }).toList();
    }
    return students;
  }

  Stream<List<Student>> getStudents() {
    return dbStudent().onValue.map((event) {
      if (event.snapshot.value == null) {
        return [];
      }
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      students = data.entries.map((e) {
        return Student.fromMap(e.key, e.value);
      }).toList();
      return students;
    });
  }

  Future<void> updateStudent(Student student) async {
    if (student.oldKey.isNotEmpty) {
      if (student.oldKey != student.key) {
        await db.child('students').child(student.oldKey).remove();
      }
      await db.child('students').child(student.key).update(student.toMap());
    } else {
      await db.child('students').child(student.key).set(student.toMap());
    }
  }

  Stream<List<Album>> getAlbums() {
    return dbAlbum().onValue.map((event) {
      if (event.snapshot.value == null) {
        return [];
      }
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      return data.entries.map((e) {
        return Album.fromMap(e.key, e.value);
      }).toList();
    });
  }

  Future<void> removeAlbum(Album album) async {
    db.child('albums/${album.key}').remove();
  }

  Future<void> addAlbum(Album album) async {
    await db.child('albums').child(album.key).set(album.toMap());
  }

  Future<List<Media>> dbMedia({bool byStudent = true, String filter = "", int limit = 0}) async {
    if (filter.isEmpty) return [];
    var f = db.child('medias').orderByKey();
    f = byStudent ? f.startAt("$filter++++++") : f.endAt("++++++$filter");
    if (limit > 0) {
      f = f.limitToFirst(limit);
    }
    final snapshot = await f.get();

    if (snapshot.value == null) {
      return [];
    }
    final data = snapshot.value as Map<dynamic, dynamic>;
    return data.entries.map((e) {
      return Media.fromKey(e.key);
    }).toList();
  }

  Stream<List<Media>> getMedia() {
    return db.child('medias').onValue.map((event) {
      if (event.snapshot.value == null) {
        return [];
      }
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      medias = data.entries.map((e) => Media.fromKey(e.key)).toList();
      return medias;
    });
  }

  Future<void> removeMedia(Media media) async {
    db.child('medias/${media.key}').remove();
  }

  Future<void> addMedia(Media media) async {
    db.child('medias').child(media.key).set(media.toString());
  }
}
