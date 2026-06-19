import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:harmonia_flutter/main.dart';
import 'package:harmonia_flutter/parent/parent_folder.dart';
import 'package:harmonia_flutter/services/dbService.dart';

import '../models/album.dart';
import 'models/media.dart';
import 'models/student.dart';

class ParentAlbumPage extends StatelessWidget {
  late Student student;
  ParentAlbumPage({required this.student, super.key});

  void openFolder(BuildContext context, Album album, List<Media> medias) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ParentFolderPage(student, album, medias)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(student.name), elevation: 0),
      backgroundColor: const Color(0xFFF8F6EF),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              const SizedBox(height: 20),

              Expanded(
                child: FutureBuilder(
                  future: dbService().dbMedia(byStudent: true, filter: student.key),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    var studentMedia = snapshot.data ?? [];

                    return StreamBuilder<List<Album>>(
                      stream: db.getAlbums(),

                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final albums = snapshot.data!.where((e) => studentMedia.any((s) => s.folderId == e.key)).toList();

                        return GridView.count(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          padding: EdgeInsets.all(10),
                          children: List.generate(albums.length, (index) {
                            final album = albums[index];
                            var medias = studentMedia.where((e) => e.folderId == album.key).toList();
                            return GestureDetector(
                              onTap: () {
                                openFolder(context, album, medias);
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 14),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(album.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                                    ),

                                    // IconButton(
                                    //   icon: const Icon(Icons.edit_outlined),
                                    //   onPressed: () {
                                    //     Navigator.push(
                                    //       context,
                                    //       MaterialPageRoute(
                                    //         builder: (_) => AlbumEditPage(a),
                                    //       ),
                                    //     );
                                    //   },
                                    // ),
                                  ],
                                ),
                              ),
                            );
                          }),
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
