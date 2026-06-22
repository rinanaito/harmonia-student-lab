import 'dart:ui';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

class GoogleDriveService {
  drive.DriveApi _api(String accessToken) => drive.DriveApi(_BearerClient(accessToken));

  Future<List<drive.File>> getDriveFolders(String accessToken) async {
    final result = await _api(
      accessToken,
    ).files.list(q: "mimeType='application/vnd.google-apps.folder' and trashed = false and visibility = 'anyoneWithLink'", spaces: 'drive', includeItemsFromAllDrives: false, orderBy: 'viewedByMeTime desc');
    return result.files ?? [];
  }

  Future<List<drive.File>> getFilesInFolder(String accessToken, String folderId) async {
    final result = await _api(
      accessToken,
    ).files.list(q: "mimeType != 'application/vnd.google-apps.folder' and '$folderId' in parents and trashed = false and visibility = 'anyoneWithLink'", spaces: 'drive', $fields: 'files(id,name,mimeType,thumbnailLink)');
    return result.files ?? [];
  }
}

class _BearerClient extends http.BaseClient {
  _BearerClient(this._token);
  final String _token;
  final _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer $_token';
    return _inner.send(request);
  }
}

extension DriveFileExtension on drive.File {
  String? get extension {
    const map = {
      'image/jpeg': 'jpg',
      'image/heif': 'heic',
      'image/gif': 'gif',
      'image/png': 'png',
      'image/webp': 'webp',
      'video/mp4': 'mp4',
      'video/quicktime': 'mov',
      'application/pdf': 'pdf',
      'text/plain': 'txt',

      // Google Drive
      'application/vnd.google-apps.document': 'doc',
      'application/vnd.google-apps.spreadsheet': 'sheet',
      'application/vnd.google-apps.presentation': 'slide',
    };

    return map[mimeType];
  }
}
