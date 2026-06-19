import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:harmonia_flutter/admin/album/folder_selector.dart';
import 'package:harmonia_flutter/models/album.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:harmonia_flutter/services/dbService.dart';
import 'package:harmonia_flutter/services/google_drive_service.dart';

import 'mediaTag.dart';

class AddGalleryPage extends StatefulWidget {
  Album album;
  drive.File? selectedFolder;

  AddGalleryPage(this.album, {super.key});

  @override
  State<AddGalleryPage> createState() => _AddGalleryPageState();
}

class _AddGalleryPageState extends State<AddGalleryPage> {
  @override
  void initState() {
    dbService().studentList4Info;
    super.initState();
  }

  Future<void> selectFolder() async {
    var folder = await Navigator.push(context, MaterialPageRoute(builder: (_) => FolderSelector(widget.album.key)));
    if (folder != null) {
      setState(() {
        widget.selectedFolder = folder;
        widget.album.name = widget.selectedFolder?.name ?? "";
        widget.album.key = widget.selectedFolder?.id ?? "";
      });
    }
    // dbService().updateAlbum(widget.album);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6EF),
      appBar: AppBar(
        title: Text(widget.album.name),
        elevation: 0,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white, // text + icon color
            ),
            child: Text("Folder сонгох"),
            onPressed: () {
              selectFolder();
            },
          ),
          SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (widget.album.key.isNotEmpty)
              Expanded(
                child: FutureBuilder<List<drive.File>>(
                  future: GoogleDriveService().getFilesInFolder(widget.album.key),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final files = snapshot.data!;
                    return GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.2, // width / height
                      ),
                      itemCount: files.length ?? 0,
                      itemBuilder: (context, index) {
                        final file = files[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => MediaTagPage(files, showedIndex: index)));
                          },
                          child: Column(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: BoxBorder.all(color: Colors.black12),
                                            borderRadius: BorderRadius.all(Radius.circular(10)),
                                          ),
                                          child: Stack(
                                            children: [
                                              Positioned.fill(
                                                child: CachedNetworkImage(
                                                  imageUrl: file.thumbnailLink ?? "",
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
                                                    child: Text(file.extension ?? "", maxLines: 1, style: TextStyle(color: Colors.white)),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 50,
                                        child: FutureBuilder(
                                          future: dbService().dbMedia(false, filter: file.id ?? "", limit: 4),
                                          builder: (context, snapshot) {
                                            if (!snapshot.hasData) {
                                              return const SizedBox(width: 20);
                                            }
                                            final medias = snapshot.data!;
                                            return Column(
                                              children: [
                                                for (var s in dbService.students)
                                                  if (medias.any((element) => element.studentId == s.key))
                                                    CircleAvatar(
                                                      radius: 24,
                                                      backgroundColor: Colors.blue.shade50,
                                                      child: Text(
                                                        s.name.isEmpty ? "*" : s.name.substring(0, 1),
                                                        style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Center(child: Text(file.name ?? "", maxLines: 1, overflow: TextOverflow.ellipsis)),
                            ],
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
    );
  }

  // Future<void> save() async {
  //   var album = super.widget.album;
  //
  //   try {
  //     await db.updateAlbum(album);
  //
  //     if (!context.mounted) return;
  //
  //     Navigator.pop(context);
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.green, content: Text("Updated")));
  //   } catch (e) {
  //     if (!context.mounted) return;
  //
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text("Can't update: $e")));
  //   }
  // }
}
