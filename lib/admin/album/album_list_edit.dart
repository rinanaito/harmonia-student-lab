import 'package:flutter/material.dart';
import 'package:harmonia_flutter/admin.dart';
import 'package:harmonia_flutter/admin/album/folder_selector.dart';
import 'package:harmonia_flutter/main.dart';
import 'package:harmonia_flutter/models/album.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:harmonia_flutter/services/dbService.dart';
import 'package:harmonia_flutter/services/google_drive_service.dart';
import 'package:http/http.dart' as http;

class AlbumEditPage extends StatefulWidget {
  Album album;
  drive.File? selectedFolder;

  AlbumEditPage(this.album, {super.key});

  @override
  State<AlbumEditPage> createState() => _AlbumEditPageState();
}

class _AlbumEditPageState extends State<AlbumEditPage> {
  final linkController = TextEditingController();
  final nameController = TextEditingController();

  @override
  void initState() {
    linkController.text = widget.album.key;
    nameController.text = widget.album.name;
    super.initState();
  }

  Future<void> selectFolder() async {
    widget.selectedFolder = await Navigator.push(context, MaterialPageRoute(builder: (_) => FolderSelector(widget.album.key)));
    nameController.text = widget.selectedFolder?.name ?? "";
    // widget.album.name = widget.selectedFolder?.name ?? "";
    // widget.album.key = widget.selectedFolder?.id ?? "";
    // dbService().updateAlbum(widget.album);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6EF),

      appBar: AppBar(title: Text("${widget.album.key.isEmpty ? "Add" : "Edit"} Album"), elevation: 0),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),

              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(labelText: "folder name", border: OutlineInputBorder()),
                          controller: nameController,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          selectFolder();
                        },
                        child: Text("Folder сонгох"),
                      ),
                    ],
                  ),
                  if (widget.selectedFolder != null)
                    Expanded(
                      child: FutureBuilder(
                        future: GoogleDriveService().getFilesInFolder(widget.selectedFolder?.id ?? ""),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final files = snapshot.data!;
                          return GridView.builder(
                            padding: const EdgeInsets.all(8),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
                            itemCount: files.length ?? 0,
                            itemBuilder: (context, index) {
                              final file = files[index];
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: file.hasThumbnail ?? false ? Image.network(file.thumbnailLink ?? "", fit: BoxFit.cover) : null,
                              );
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> save() async {
    var album = super.widget.album;
    album.name = nameController.text;
    album.key = linkController.text;

    try {
      await db.updateAlbum(album);

      if (!context.mounted) return;

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.green, content: Text("Updated")));
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text("Can't update: $e")));
    }
  }
}
