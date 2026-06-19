import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:harmonia_flutter/main.dart';

import '../../models/album.dart';
import '../../models/student.dart';
import 'open_folder_page.dart';
import '../student_edit_page.dart';

class AlbumListPage extends StatelessWidget {
  AlbumListPage({super.key});

  addGallery(BuildContext context, Album album) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => OpenFolderPage(album)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Albums"), elevation: 0),
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
              const SizedBox(height: 20),

              Expanded(
                child: StreamBuilder<List<Album>>(
                  stream: db.getAlbums(),

                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final albums = snapshot.data!;
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
                                Text(a.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
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
