import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:harmonia_flutter/main.dart';
import 'package:harmonia_flutter/parent/parent_folder_page.dart';
import 'package:harmonia_flutter/services/db_service.dart';

import '../../models/album.dart';
import '../models/media.dart';
import '../models/student.dart';

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
                            final album = albums[index];
                            return GestureDetector(
                              onTap: () {
                                var medias = studentMedia.where((e) => e.folderId == album.key).toList();
                                openFolder(context, album, medias);
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
                                      album.name,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
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
