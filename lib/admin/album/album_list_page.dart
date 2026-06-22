import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../models/album.dart';
import '../../models/media.dart';
import '../../models/student.dart';
import '../../services/db_service.dart';
import '../student_album_adder.dart';
import 'open_folder_page.dart';
import '../student_edit_page.dart';

class AlbumListPage extends StatefulWidget {
  AlbumListPage({super.key});

  @override
  State<AlbumListPage> createState() => _AlbumListPageState();
}

class _AlbumListPageState extends State<AlbumListPage> {
  List<Media> filteredMedia = [];
  var filteredStudentId = "";

  addGallery(BuildContext context, Album album) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => OpenFolderPage(album)));
  }

  void filterByStudent(String studentId) async {
    filteredStudentId = studentId;
    if (studentId.isNotEmpty) {
      var medias = await dbService().dbMedia(byStudent: true, filter: studentId);
      setState(() {
        filteredMedia = medias;
      });
    } else {
      setState(() {
        filteredMedia = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Albums"),
        elevation: 0,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.blue),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => StudentAlbumAdder(Album())));
            },
            child: Text("Album-Student"),
          ),
          SizedBox(width: 10),
        ],
      ),

      floatingActionButton: FloatingActionButton.large(
        onPressed: () {
          addGallery(context, Album());
        },
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.add),
      ),
      backgroundColor: const Color(0xFFF8F6EF),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              StreamBuilder(
                stream: dbService().getStudents(),
                builder: (context, asyncSnapshot) {
                  var students = asyncSnapshot.data ?? [];
                  return DropdownButtonFormField(
                    items: [
                      DropdownMenuItem(
                        value: "",
                        enabled: true,
                        child: Text("All", style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis, maxLines: 1),
                      ),
                      for (var student in students)
                        DropdownMenuItem(
                          value: student.key,
                          enabled: true,
                          child: Row(
                            children: [
                              Text(student.code, style: const TextStyle(fontSize: 10, color: Colors.black38)),
                              SizedBox(width: 5),
                              Text(student.name, style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis, maxLines: 1),
                            ],
                          ),
                        ),
                    ],
                    onChanged: (v) {
                      filterByStudent(v ?? "");
                    },
                    decoration: const InputDecoration(labelText: "Student", border: OutlineInputBorder()),
                  );
                },
              ),

              Expanded(
                child: StreamBuilder<List<Album>>(
                  stream: dbService().getAlbums(),

                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    var albums = snapshot.data!;
                    if (filteredMedia.isNotEmpty) {
                      albums = albums.where((a) => filteredMedia.any((m) => m.folderId == a.key)).toList();
                    }
                    var width = MediaQuery.of(context).size.width;
                    return GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: width > 600 ? (width / 300).toInt() : 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.2, // width / height
                      ),
                      itemCount: albums.length,
                      itemBuilder: (context, index) {
                        final a = albums[index];

                        return GestureDetector(
                          onTap: () {
                            addGallery(context, a);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(10),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: Colors.black.withAlpha(20)),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.folder_rounded, size: 30),
                                SizedBox(height: 10),
                                Text(
                                  a.name,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
