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
      appBar: AppBar(
        title: const Text("Albums"),
        elevation: 0,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white, // text + icon color
            ),
            child: Row(children: [const Icon(Icons.add), const Text("Add")]),
            onPressed: () {
              addGallery(context, Album());
            },
          ),
          SizedBox(width: 10),
        ],
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
                    return GridView.count(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      padding: EdgeInsets.all(10),
                      children: List.generate(albums.length, (index) {
                        final a = albums[index];

                        return GestureDetector(
                          onTap: () {
                            addGallery(context, a);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(a.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
