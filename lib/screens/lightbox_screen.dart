import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/media_item.dart';
import '../theme/app_theme.dart';

class LightboxDialog extends StatelessWidget {
  final MediaItem media;
  const LightboxDialog({super.key, required this.media});

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.black.withOpacity(0.9),
      child: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 900,
                      maxHeight: MediaQuery.of(context).size.height * 0.7,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: media.isPhoto
                        ? Image.network(
                            media.displayUrl,
                            fit: BoxFit.contain,
                            loadingBuilder: (ctx, child, progress) {
                              if (progress == null) return child;
                              return const Center(child: CircularProgressIndicator(color: AppColors.accent));
                            },
                          )
                        : AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Container(
                              color: AppColors.navy,
                              child: const Center(
                                child: Icon(Icons.videocam, color: Colors.white54, size: 64),
                              ),
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    media.title,
                    style: const TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat.yMMMd().format(DateTime.parse(media.date)),
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  if (media.studentNames != null && media.studentNames!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Tagged: ${media.studentNames!.join(', ')}',
                        style: const TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 24,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: AppColors.white, size: 28),
              tooltip: 'Close',
            ),
          ),
        ],
      ),
    );
  }
}
