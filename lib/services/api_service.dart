import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/student.dart';
import '../models/media_item.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String baseUrl = const String.fromEnvironment('API_BASE', defaultValue: '');

  String get _apiBase {
    if (baseUrl.isNotEmpty) return baseUrl;
    final host = Uri.base.host;
    if (host == 'localhost' || host.isEmpty) return 'http://localhost:3000/api';
    return '/api';
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? extraHeaders,
  }) async {
    final uri = Uri.parse('$_apiBase$endpoint');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (extraHeaders != null) ...extraHeaders,
    };

    late final http.Response res;
    if (method == 'GET') {
      res = await http.get(uri, headers: headers);
    } else if (method == 'POST') {
      res = await http.post(uri, headers: headers, body: jsonEncode(body));
    } else if (method == 'PATCH') {
      res = await http.patch(uri, headers: headers, body: jsonEncode(body));
    } else if (method == 'DELETE') {
      res = await http.delete(uri, headers: headers);
    } else {
      throw Exception('Unsupported method: $method');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 400) {
      throw Exception(data['error'] ?? 'HTTP ${res.statusCode}');
    }
    return data;
  }

  // ── Auth ──
  Future<Student> parentLogin(String query) async {
    final data = await _request('POST', '/auth/parent', body: {'query': query});
    return Student.fromJson(data['student'] as Map<String, dynamic>);
  }

  Future<void> adminLogin(String username, String password) async {
    await _request('POST', '/auth/admin', body: {'username': username, 'password': password});
  }

  // ── Students (FULL CRUD) ──
  Future<List<Student>> getStudents() async {
    final data = await _request('GET', '/students');
    return (data as List).map((e) => Student.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Student> addStudent(String id, String name, String? cls) async {
    final data = await _request('POST', '/students', body: {'id': id, 'name': name, 'class': cls});
    return Student.fromJson(data['student'] as Map<String, dynamic>);
  }

  Future<Student> updateStudent(String id, {String? name, String? cls}) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (cls != null) body['class'] = cls;
    final data = await _request('PATCH', '/students/$id', body: body);
    return Student.fromJson(data['student'] as Map<String, dynamic>);
  }

  Future<void> deleteStudent(String id) async {
    await _request('DELETE', '/students/$id');
  }

  // ── Media ──
  Future<List<MediaItem>> getMedia({String? studentId, String? type}) async {
    final params = <String, String>{};
    if (studentId != null) params['studentId'] = studentId;
    if (type != null) params['type'] = type;
    final query = params.isEmpty ? '' : '?${params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&')}';
    final data = await _request('GET', '/media$query');
    return (data as List).map((e) => MediaItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<MediaItem>> uploadMedia({
    required List<String> studentIds,
    required String date,
    required String title,
    required List<({String name, Uint8List bytes, String mime})> files,
  }) async {
    final uri = Uri.parse('$_apiBase/media');
    final request = http.MultipartRequest('POST', uri);
    request.fields['studentIds'] = jsonEncode(studentIds);
    request.fields['date'] = date;
    request.fields['title'] = title;

    for (final f in files) {
      request.files.add(http.MultipartFile.fromBytes(
        'files',
        f.bytes,
        filename: f.name,
        contentType: MediaType.parse(f.mime),
      ));
    }

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 400) {
      throw Exception(data['error'] ?? 'HTTP ${res.statusCode}');
    }
    return (data['media'] as List)
        .map((e) => MediaItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateMedia(String id, {String? title, String? date, List<String>? studentIds}) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (date != null) body['date'] = date;
    if (studentIds != null) body['studentIds'] = studentIds;
    await _request('PATCH', '/media/$id', body: body);
  }

  Future<void> deleteMedia(String id) async {
    await _request('DELETE', '/media/$id');
  }

  // ── Stats ──
  Future<Map<String, int>> getStats() async {
    final data = await _request('GET', '/stats');
    return {
      'students': data['students'] as int,
      'photos': data['photos'] as int,
      'videos': data['videos'] as int,
      'total': data['total'] as int,
    };
  }
}
