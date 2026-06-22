import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:harmonia_flutter/main.dart';
import 'package:harmonia_flutter/models/album.dart';
import 'package:harmonia_flutter/models/student.dart';
import 'package:harmonia_flutter/services/db_service.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:harmonia_flutter/services/google_drive_service.dart';
import 'package:provider/provider.dart';

import '../models/dfile.dart';
import '../models/media.dart';
import '../services/auth_service.dart';
import 'album/folder_selector.dart';
import 'album/media_tag_page.dart';

class StudentAlbumAdder extends StatefulWidget {
  Album album;
  StudentAlbumAdder(this.album, {super.key});

  @override
  State<StudentAlbumAdder> createState() => _StudentAlbumAdderState();
}

class _StudentAlbumAdderState extends State<StudentAlbumAdder> {
  Student? selectedStudent;
  drive.File? selectedFolder;
  List<drive.File> files = [];
  final ValueNotifier<List<String>> selectedFileNotifier = ValueNotifier<List<String>>([]);
  List<ValueNotifier<bool>> listValueNotif = [];

  @override
  void initState() {
    super.initState();
  }

  Future<void> chooseFolder() async {
    var folder = await Navigator.push(context, MaterialPageRoute(builder: (_) => FolderSelector(widget.album.key)));
    if (folder != null) {
      selectedFileNotifier.value = [];
      setState(() {
        selectedFolder = folder;
        widget.album.name = selectedFolder?.name ?? "";
        widget.album.studentId = selectedStudent?.key ?? "";
        widget.album.key = selectedFolder?.id ?? "";
      });
    }
  }

  Future<List<drive.File>> getFiles() async {
    if (selectedFolder == null) {
      return [];
    }
    final token = await context.read<AuthService>().getAccessToken();
    if (token == null) return [];
    files = await GoogleDriveService().getFilesInFolder(token, selectedFolder!.id!);
    disposeFileNotifier();
    List<String> selectedFileIds = selectedFileNotifier.value;
    for (var file in files) {
      listValueNotif.add(ValueNotifier<bool>(selectedFileIds.contains(file.id ?? "")));
    }
    return files;
  }

  void toggleFile(String fileId, int index) {
    // List<String> selectedFileIds = selectedFileNotifier.value;
    if (selectedFileNotifier.value.contains(fileId)) {
      selectedFileNotifier.value.remove(fileId);
    } else {
      selectedFileNotifier.value.add(fileId);
    }
    listValueNotif[index].value = selectedFileNotifier.value.contains(fileId);
  }

  void selectAll() {
    List<String> selectedFileIds = selectedFileNotifier.value;
    if (selectedFileIds.isEmpty) {
      selectedFileIds = files.map((e) => e.id ?? "").toList();
      for (var n in listValueNotif) {
        n.value = true;
      }
    } else {
      selectedFileIds = [];
      for (var n in listValueNotif) {
        n.value = false;
      }
    }
    selectedFileNotifier.value = selectedFileIds;
  }

  void disposeFileNotifier() {
    for (var n in listValueNotif) {
      n.dispose();
    }
    listValueNotif = [];
  }

  @override
  void dispose() {
    disposeFileNotifier();
    selectedFileNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6EF),

      appBar: AppBar(title: Text(widget.album.name), elevation: 0),

      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
        child: Column(
          children: [
            StreamBuilder(
              stream: dbService().getStudents(),
              builder: (context, asyncSnapshot) {
                var students = asyncSnapshot.data ?? [];

                return DropdownButtonFormField(
                  value: widget.album.studentId.isNotEmpty ? widget.album.studentId : null,
                  items: [
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
                    selectedStudent = students.firstWhere((s) => s.key == v);
                    widget.album.studentId = selectedStudent?.key ?? "";
                    selectedFileNotifier.value = ["#"];
                    selectAll();
                    if (selectedFolder != null) {
                      setState(() {
                        widget.album.name = selectedFolder?.name ?? "";
                      });
                    }
                  },
                  decoration: const InputDecoration(labelText: "Student", border: OutlineInputBorder()),
                );
              },
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.indigoAccent),
                    onPressed: () {
                      chooseFolder();
                    },
                    child: Text(widget.album.name.isEmpty ? "Folder сонгох" : widget.album.name),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            if (selectedFolder != null)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: BoxBorder.all(color: Colors.black54),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: TextButton(
                          onPressed: () {
                            selectAll();
                          },
                          child: ValueListenableBuilder<List<String>>(
                            valueListenable: selectedFileNotifier,
                            builder: (context, value, child) {
                              return Row(children: [Icon(value.isEmpty ? Icons.library_add_check_outlined : Icons.indeterminate_check_box_sharp), SizedBox(height: 5), Text(value.isEmpty ? "Select all" : "Select none")]);
                            },
                          ),
                        ),
                      ),

                      Expanded(
                        child: FutureBuilder(
                          future: getFiles(),
                          builder: (context, asyncSnapshot) {
                            if (!asyncSnapshot.hasData) {
                              return Center(child: CircularProgressIndicator());
                            }
                            var width = MediaQuery.of(context).size.width;
                            var grid = (width > 600 ? (width / 400).toInt() : 2);
                            var cell = ((width - 60 - (grid - 1) * 30) / grid);
                            var folderFiles = asyncSnapshot.data ?? [];
                            return GridView.builder(
                              padding: const EdgeInsets.all(8),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: grid,
                                crossAxisSpacing: 15,
                                mainAxisSpacing: 15,
                                childAspectRatio: 0.7, // width / height
                              ),
                              itemCount: files.length ?? 0,
                              itemBuilder: (context, index) {
                                var file = folderFiles[index];

                                return Column(
                                  children: [
                                    SizedBox(
                                      height: cell / 0.8,
                                      width: cell,
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                            child: GestureDetector(
                                              onLongPress: () {
                                                Navigator.push(context, MaterialPageRoute(builder: (_) => MediaTagPage([file], Album(), showedIndex: 0)));
                                              },
                                              onTap: () {
                                                toggleFile(file.id ?? "", index);
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  border: BoxBorder.all(color: Colors.black12),
                                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                                ),
                                                child: CachedNetworkImage(
                                                  imageUrl: file.thumbnailLink ?? "",
                                                  placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                                                  fit: BoxFit.contain,
                                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            right: 15,
                                            top: 15,
                                            child: ValueListenableBuilder<bool>(
                                              valueListenable: listValueNotif[index],
                                              builder: (context, value, child) {
                                                return Icon(value ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded, color: Colors.blueAccent, size: 30);
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(file.name ?? "", maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ],
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
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ValueListenableBuilder<List<String>>(
                valueListenable: selectedFileNotifier,
                builder: (context, value, child) {
                  return ElevatedButton(
                    onPressed: selectedStudent != null ? save : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      disabledBackgroundColor: Colors.grey,
                      disabledForegroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    child: const Text("Save Changes", style: TextStyle(color: Colors.black)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> save() async {
    try {
      List<String> selectedFileIds = selectedFileNotifier.value;
      if (selectedFileIds.isNotEmpty && selectedStudent != null) {
        for (var file in files) {
          if (selectedFileIds.contains(file.id ?? "")) {
            dbService().addFile(
              DFile()
                ..key = file.id ?? ""
                ..name = file.name ?? ""
                ..thumbnail = file.thumbnailLink ?? ""
                ..type = file.extension ?? "",
            );
            var m = Media(studentId: selectedStudent!.key, fileId: file.id ?? "", folderId: widget.album.key);
            dbService().addMedia(m);
            dbService().addAlbum(widget.album);
          }
        }
        selectAll();
      }

      if (!context.mounted) return;
      // Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.green, content: Text("Updated")));
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text("Can't update: $e")));
    }
  }
}
