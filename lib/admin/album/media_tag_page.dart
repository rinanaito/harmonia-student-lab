import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:harmonia_flutter/services/dbService.dart';
import 'package:web/web.dart' as web;

import '../../models/album.dart';
import '../../models/dfile.dart';
import '../../models/media.dart';
import '../../models/student.dart';
import '../../services/google_drive_service.dart';
import 'multi_tag_selector.dart';

class MediaTagPage extends StatefulWidget {
  Album album;
  List<drive.File> files = [];
  int showedIndex = 0;
  MediaTagPage(this.files, this.album, {this.showedIndex = 0, super.key});

  @override
  State<MediaTagPage> createState() => _MediaTagPageState();
}

class _MediaTagPageState extends State<MediaTagPage> {
  drive.File? selectedFile;
  String fileExtension = "";
  @override
  void initState() {
    super.initState();
  }

  void indexChange({increase = true}) {
    setState(() {
      if (increase) {
        widget.showedIndex = widget.showedIndex + 1 < widget.files.length ? widget.showedIndex + 1 : 0;
      } else {
        widget.showedIndex = widget.showedIndex > 0 ? widget.showedIndex - 1 : widget.files.length - 1;
      }
    });
  }

  void openNewTab(String url) {
    web.window.open(url, '_blank', 'noopener,noreferrer');
  }

  @override
  Widget build(BuildContext context) {
    selectedFile = widget.files[widget.showedIndex];
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6EF),
      appBar: AppBar(
        title: GestureDetector(onTap: () => openNewTab("https://drive.google.com/thumbnail?id=${selectedFile?.id ?? ""}&sz=w1000"), child: Text(selectedFile?.name ?? "")),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          border: BoxBorder.all(color: Colors.black12),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  border: BoxBorder.all(color: Colors.black12),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CachedNetworkImage(
                        imageUrl: "https://drive.google.com/thumbnail?id=${selectedFile?.id ?? ""}&sz=w1000",
                        fit: BoxFit.cover,
                        placeholder: (context, _) => const CircularProgressIndicator(strokeWidth: 2),
                        errorWidget: (context, _, __) => Center(
                          child: GestureDetector(
                            onTap: () => openNewTab("https://drive.google.com/thumbnail?id=${selectedFile?.id ?? ""}&sz=w1000"),
                            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.broken_image), SizedBox(height: 5), Text("Couldn't load,\nview to CLICK")]),
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5), bottomRight: Radius.circular(5)),
                            color: Colors.blue,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(selectedFile?.extension ?? "", maxLines: 1, style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: GestureDetector(
                              onTap: () => indexChange(increase: false),
                              child: Container(
                                decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.black45, Colors.black.withAlpha(0)])),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Icon(Icons.keyboard_arrow_left, color: Colors.white, size: 35),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(flex: 3, child: Container()),
                          Expanded(
                            flex: 1,
                            child: GestureDetector(
                              onTap: () => indexChange(increase: true),
                              child: Container(
                                decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.black.withAlpha(0), Colors.black45])),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 35),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: dbService().getStudents(),
                    builder: (context, snapshot) {
                      final tags = dbService.medias.where((m) => m.fileId == selectedFile?.id).toList(growable: true);
                      return MultiTagSelector(
                        initialSelected: tags.map((e) => e.studentId).toList(),
                        onAdd: (studentId) => addStudent(studentId, selectedFile?.id ?? ""),
                        onRemoved: (studentId) => removeStudent(studentId, selectedFile?.id ?? ""),
                        tags: dbService.students,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> addStudent(String id, String file) async {
    var m = Media(studentId: id, fileId: file, folderId: widget.album.key);
    if (dbService.medias.any((m) => widget.files.any((f) => m.fileId == f.id))) {
    } else {
      dbService().addFile(
        DFile()
          ..key = file
          ..name = selectedFile?.name ?? ""
          ..type = selectedFile?.extension ?? "",
      );
      dbService().addAlbum(widget.album);
    }
    dbService().addMedia(m);
  }

  Future<void> removeStudent(String id, String file) async {
    var m = Media(studentId: id, fileId: file, folderId: widget.album.key);
    dbService().removeMedia(m);
    if (dbService.medias.any((m) => widget.files.any((f) => m.fileId == f.id))) {
      dbService().removeAlbum(widget.album);
    }
  }
}
