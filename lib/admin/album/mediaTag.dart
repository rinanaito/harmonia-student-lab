import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart' as drive;

import '../../services/google_drive_service.dart';

class MediaTagPage extends StatefulWidget {
  List<drive.File> files = [];
  int showedIndex = 0;
  MediaTagPage(this.files, {this.showedIndex = 0, super.key});

  @override
  State<MediaTagPage> createState() => _MediaTagPageState();
}

class _MediaTagPageState extends State<MediaTagPage> {
  @override
  Widget build(BuildContext context) {
    var file = widget.files[widget.showedIndex];
    print("https://drive.google.com/thumbnail?id=${file.id ?? ""}&sz=w1000");
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6EF),
      appBar: AppBar(title: Text(file.name ?? ""), elevation: 0),
      body: Container(
        decoration: BoxDecoration(
          border: BoxBorder.all(color: Colors.black12),
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: Colors.red,
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                placeholder: (context, _) => const CircularProgressIndicator(strokeWidth: 2),
                errorWidget: (context, _, __) => const Icon(Icons.broken_image),
                imageUrl: "https://drive.google.com/thumbnail?id=${file.id ?? ""}&sz=w1000",
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
    );
  }
}
