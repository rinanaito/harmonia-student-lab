import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/album.dart';
import 'album_list_edit.dart';
import 'package:googleapis/drive/v3.dart' as drive;

class FolderSelector extends StatelessWidget {
  List<drive.File> folders;
  String selected = "";

  FolderSelector(this.folders, this.selected, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Folders"), elevation: 0),
      backgroundColor: const Color(0xFFF8F6EF),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.amber,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AlbumEditPage(Album())),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Album"),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              const SizedBox(height: 20),

              Expanded(
                child: ListView.builder(
                  itemCount: folders.length,
                  itemBuilder: (_, i) {
                    var folder = folders[i];
                    return ListTile(
                      leading: Icon(Icons.folder),
                      title: Text(folder.name ?? ''),
                      selected: selected == folder.id,
                      selectedTileColor: Colors.blue.shade50,
                      onTap: () {
                        Navigator.pop(context, folder);
                      },
                      trailing: selected == folder.id ? Icon(Icons.check) : null,
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
