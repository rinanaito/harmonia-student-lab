import 'package:flutter/material.dart';
import 'package:harmonia_flutter/admin/album/folder_selector.dart';
import 'package:harmonia_flutter/main.dart';
import 'package:harmonia_flutter/models/album.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

final googleSignIn = GoogleSignIn(scopes: [drive.DriveApi.driveReadonlyScope]);

Future<List<drive.File>> getDriveFolders() async {
  final account = await googleSignIn.signIn();

  if (account == null) {
    return [];
  }

  final authHeaders = await account.authHeaders;

  final client = GoogleAuthClient(authHeaders);

  final api = drive.DriveApi(client);

  final result = await api.files.list(
    q: "mimeType='application/vnd.google-apps.folder'",
    spaces: 'drive',
  );

  return result.files ?? [];
}

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> headers;

  GoogleAuthClient(this.headers);

  final _client = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(headers);
    return _client.send(request);
  }
}

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

  Future<void> setupDrive() async {
    final folders = await getDriveFolders();
    widget.selectedFolder = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FolderSelector(folders, widget.album.key),
      ),
    );
    if (widget.selectedFolder != null && nameController.text.isEmpty) {
      nameController.text = widget.selectedFolder?.name ?? "";
    }
  }
  Future<List<drive.File>> getFilesInFolder(
      // drive.DriveApi api,
      String folderId,
      ) async {

    final client = GoogleAuthClient(authHeaders);

    final api = drive.DriveApi(client);
    final result = await api.files.list(
      q: "'$folderId' in parents and trashed = false",
      spaces: 'drive',
      $fields: 'files(id,name,mimeType,thumbnailLink)',
    );

    return result.files ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6EF),

      appBar: AppBar(
        title: Text("${widget.album.key.isEmpty ? "Add" : "Edit"} Album"),
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),

              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setupDrive();
                    },
                    child: Text("Folder сонгох"),
                  ),

                  const SizedBox(height: 18),
                  TextField(
                    decoration: InputDecoration(
                      labelText: "folder name",
                      border: OutlineInputBorder(),
                    ),
                    controller: nameController,
                  ),
                  if (widget.selectedFolder != null )
                  StreamBuilder(stream: getFilesInFolder(widget.selectedFolder.id), builder: ())
                  GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount: widget.selectedFolder?.length ?? 0,
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(images[index], fit: BoxFit.cover),
                      );
                    },
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.green, content: Text("Updated")),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Can't update: $e"),
        ),
      );
    }
  }
}
