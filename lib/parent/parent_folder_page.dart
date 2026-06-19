import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:harmonia_flutter/admin/album/folder_selector.dart';
import 'package:harmonia_flutter/models/album.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:harmonia_flutter/models/media.dart';
import 'package:harmonia_flutter/services/db_service.dart';
import 'package:harmonia_flutter/services/google_drive_service.dart';
import 'package:web/web.dart' as web;

import '../models/student.dart';

class ParentFolderPage extends StatelessWidget {
  late Student student;
  Album album;
  List<Media> medias;

  ParentFolderPage(this.student, this.album, this.medias, {super.key});

  void openNewTab(String id) {
    web.window.open("https://drive.google.com/file/d/$id/view", '_blank', 'noopener,noreferrer');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6EF),
      appBar: AppBar(title: Text(album.name), elevation: 0, actions: []),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            FutureBuilder(
              future: dbService().getFiles(),
              builder: (context, asyncSnapshot) {
                if (!asyncSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var files = asyncSnapshot.data ?? [];

                var width = MediaQuery.of(context).size.width;

                return Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: width > 600 ? (width / 400).toInt() : 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 1.2, // width / height
                    ),
                    itemCount: medias.length ?? 0,
                    itemBuilder: (context, index) {
                      final media = medias[index];
                      final file = files.firstWhere((e) => e.key == media.fileId);
                      return GestureDetector(
                        onTap: () {
                          openNewTab(media.fileId);
                        },
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 20, 20, 0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: BoxBorder.all(color: Colors.black12),
                                      borderRadius: BorderRadius.all(Radius.circular(10)),
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: CachedNetworkImage(
                                            imageUrl: file.thumbnail.isNotEmpty ? file.thumbnail.replaceAll(RegExp(r'=s\d+$'), '=s1200') : "https://drive.google.com/thumbnail?id=${media.fileId}&sz=w200",
                                            placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                                            fit: BoxFit.contain,
                                            errorWidget: (context, url, error) => Icon(Icons.error),
                                          ),
                                        ),
                                        Positioned(
                                          left: 0,
                                          bottom: 0,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(topRight: Radius.circular(5)),
                                              color: Colors.blue,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(4.0),
                                              child: Text(file.type ?? "", maxLines: 1, style: TextStyle(color: Colors.white)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              Center(child: Text(file.name, maxLines: 1, overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white, // text + icon color
                ),
                child: Text("Буцах"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
