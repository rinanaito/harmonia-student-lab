import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/album.dart';
import '../../services/google_drive_service.dart';
import 'package:googleapis/drive/v3.dart' as drive;

class FolderSelector extends StatelessWidget {
  String selected = "";

  FolderSelector(this.selected, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Google Drive Folders"), elevation: 0),
      backgroundColor: const Color(0xFFF8F6EF),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              const SizedBox(height: 20),
              FutureBuilder(
                future: GoogleDriveService().getDriveFolders(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final folders = snapshot.data!;
                  return Expanded(
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
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
