import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/album.dart';
import '../../services/google_drive_service.dart';
import 'album_list_edit.dart';
import 'package:googleapis/drive/v3.dart' as drive;

class FolderSelector extends StatefulWidget {
  String selected = "";

  FolderSelector(this.selected, {super.key});

  @override
  State<FolderSelector> createState() => _FolderSelectorState();
}

class _FolderSelectorState extends State<FolderSelector> {
  List<drive.File> folders = [];
  @override
  void initState() {
    setupDrive();
    super.initState();
  }

  Future<void> setupDrive() async {
    var f = await GoogleDriveService().getDriveFolders();
    setState(() {
      folders = f;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Folders"), elevation: 0),
      backgroundColor: const Color(0xFFF8F6EF),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              const SizedBox(height: 20),
              if (folders.isEmpty) CircularProgressIndicator(),

              Expanded(
                child: ListView.builder(
                  itemCount: folders.length,
                  itemBuilder: (_, i) {
                    var folder = folders[i];
                    return ListTile(
                      leading: Icon(Icons.folder),
                      title: Text(folder.name ?? ''),
                      selected: widget.selected == folder.id,
                      selectedTileColor: Colors.blue.shade50,
                      onTap: () {
                        Navigator.pop(context, folder);
                      },
                      trailing: widget.selected == folder.id ? Icon(Icons.check) : null,
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
