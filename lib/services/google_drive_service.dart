import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

class GoogleDriveService extends ChangeNotifier {
  static const scopes = [drive.DriveApi.driveReadonlyScope];
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Optional clientId
    // clientId: 'your-client_id.apps.googleusercontent.com',
    scopes: scopes,
  );

  bool logged = false;
  static GoogleSignInAccount? account;
  GoogleAuthClient? client;

  GoogleDriveService() {
    initialize();
  }

  Future<void> initialize() async {
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) async {
      GoogleDriveService.account = account;
      logged = account != null;
      if (kIsWeb && account != null) {
        logged = await _googleSignIn.canAccessScopes(scopes);
        if (!logged) {
          logged = await _googleSignIn.requestScopes(scopes);
        }
      }
      notifyListeners();
    });
  }

  Future<GoogleAuthClient?> getClient() async {
    final authHeaders = await account?.authHeaders;
    client = GoogleAuthClient(authHeaders!);
    return client;
  }

  Future<List<drive.File>> getDriveFolders() async {
    if (client == null) await getClient();
    final api = drive.DriveApi(client!);

    final result = await api.files.list(
      q: "mimeType='application/vnd.google-apps.folder' and trashed = false and visibility = 'anyoneWithLink'",
      spaces: 'drive',
      includeItemsFromAllDrives: false,
      orderBy: 'viewedByMeTime desc',
    );

    return result.files ?? [];
  }

  Future<List<drive.File>> getFilesInFolder(String folderId) async {
    if (client == null) await getClient();
    final api = drive.DriveApi(client!);
    final result = await api.files.list(
      q: "mimeType != 'application/vnd.google-apps.folder' and '$folderId' in parents and trashed = false and visibility = 'anyoneWithLink'",
      spaces: 'drive',
      $fields: 'files(id,name,mimeType,thumbnailLink)',
    );
    return result.files ?? [];
  }
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
