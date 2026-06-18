import 'package:firebase_database/firebase_database.dart';
import '../models/album.dart';
import '../models/media.dart';
import '../models/student.dart';

class dbService {
  final DatabaseReference db = FirebaseDatabase.instance.ref();

  DatabaseReference dbStudent({String key = ""}) => db.child('students${key.isEmpty ? '' : '/$key'}');
  DatabaseReference dbAlbum({String key = ""}) => db.child('albums${key.isEmpty ? '' : '/$key'}');

  Stream<List<Student>> getStudents() {
    return dbStudent().onValue.map((event) {
      if (event.snapshot.value == null) {
        return [];
      }
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      return data.entries.map((e) {
        return Student.fromMap(e.key, e.value);
      }).toList();
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

  Future<void> updateAlbum(Album album) async {
    if (album.key.isEmpty) {
      await dbAlbum().push().set(album.toMap());
    } else {
      await dbAlbum(key: album.key).update(album.toMap());
    }
  }

  Future<List<Media>> dbMedia(bool byStudent, {String filter = ""}) async {
    var f = db.child('medias').orderByChild("hash");
    final snapshot = await (byStudent ? f.startAt("$filter#") : f.endAt("#$filter")).get();

    if (snapshot.value == null) {
      return [];
    }
    final data = snapshot.value as Map<dynamic, dynamic>;
    return data.entries.map((e) {
      return Media.fromMap(e.key, e.value);
    }).toList();
  }

  Future<void> removeMedia(Media media) async {
    db.child('medias/${media.key}').remove();
  }

  Future<void> addMedia(Media media) async {
    db.child('medias').push().set(media.toMap());
  }
}
