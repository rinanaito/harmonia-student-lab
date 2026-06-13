import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/student.dart';
import '../models/media_item.dart';
import '../services/api_service.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  String _activePanel = 'dashboard';
  final _api = ApiService();

  void _navigate(String panel) {
    setState(() => _activePanel = panel);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildTopNav(),
          Expanded(
            child: Row(
              children: [
                _buildSidebar(),
                Expanded(
                  child: Container(
                    color: AppColors.cream,
                    padding: const EdgeInsets.all(32),
                    child: _buildPanel(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopNav() {
    return Container(
      height: 64,
      color: AppColors.navy,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Image.asset('assets/images/logo.png', height: 36),
          const SizedBox(width: 10),
          Text(
            'Harmonia Admin',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontFamily: 'PlayfairDisplay',
              color: AppColors.white,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Administrator',
              style: TextStyle(color: AppColors.white, fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () => context.read<AppState>().logout(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Log out', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    final items = [
      ('dashboard', '📊 Dashboard'),
      ('upload', '📤 Upload Media'),
      ('students', '👦 Students'),
      ('media', '🖼️ All Media'),
    ];
    return Container(
      width: 220,
      color: AppColors.navy,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text(
              'NAVIGATION',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 11,
                letterSpacing: 1,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 4),
          ...items.map((item) {
            final active = _activePanel == item.$1;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Material(
                color: active ? AppColors.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () => _navigate(item.$1),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: Text(
                      item.$2,
                      style: TextStyle(
                        color: active ? AppColors.white : Colors.white.withOpacity(0.75),
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPanel() {
    switch (_activePanel) {
      case 'dashboard':
        return const DashboardPanel();
      case 'upload':
        return const UploadPanel();
      case 'students':
        return const StudentsPanel();
      case 'media':
        return const AllMediaPanel();
      default:
        return const DashboardPanel();
    }
  }
}

// ═══════════════════════════════════════════════
//  DASHBOARD
// ═══════════════════════════════════════════════
class DashboardPanel extends StatefulWidget {
  const DashboardPanel({super.key});

  @override
  State<DashboardPanel> createState() => _DashboardPanelState();
}

class _DashboardPanelState extends State<DashboardPanel> {
  final _api = ApiService();
  Map<String, int> _stats = {};
  List<MediaItem> _recent = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final stats = await _api.getStats();
      final media = await _api.getMedia();
      setState(() {
        _stats = stats;
        _recent = media.take(6).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: AppColors.accent));
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dashboard', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontFamily: 'PlayfairDisplay')),
          const SizedBox(height: 6),
          const Text('Overview of all students and media', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
          const SizedBox(height: 28),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _statCard('👦', _stats['students'] ?? 0, 'Students'),
              _statCard('📷', _stats['photos'] ?? 0, 'Photos'),
              _statCard('🎬', _stats['videos'] ?? 0, 'Videos'),
              _statCard('🗂️', _stats['total'] ?? 0, 'Total Media'),
            ],
          ),
          const SizedBox(height: 32),
          _buildCard(
            title: '📋 Recent Uploads',
            child: _recent.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: Text('No uploads yet', style: TextStyle(color: AppColors.textMuted))),
                )
              : _buildRecentTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTable() {
    return Table(
      columnWidths: const {
        0: FixedColumnWidth(64),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(2),
        3: FixedColumnWidth(80),
        4: FixedColumnWidth(120),
      },
      children: [
        TableRow(
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.gray, width: 2))),
          children: ['Preview', 'Title', 'Students', 'Type', 'Date'].map((h) =>
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(h, style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
            ),
          ).toList(),
        ),
        ..._recent.map((m) => TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  m.displayThumb,
                  width: 48,
                  height: 36,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(width: 48, height: 36, color: AppColors.gray),
                ),
              ),
            ),
            Padding(padding: const EdgeInsets.all(12), child: Text(m.title)),
            Padding(padding: const EdgeInsets.all(12), child: Text(m.taggedStudentsText)),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: m.isPhoto ? const Color(0xFFe8f5e9) : const Color(0xFFe3f2fd),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  m.type,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: m.isPhoto ? const Color(0xFF2e7d32) : const Color(0xFF1565c0),
                  ),
                ),
              ),
            ),
            Padding(padding: const EdgeInsets.all(12), child: Text(DateFormat.yMMMd().format(DateTime.parse(m.date)))),
          ],
        )),
      ],
    );
  }

  Widget _statCard(String emoji, int value, String label) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x1A0a1628), blurRadius: 20, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text('$value', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.navy)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  UPLOAD (with multi-student tagging)
// ═══════════════════════════════════════════════
class UploadPanel extends StatefulWidget {
  const UploadPanel({super.key});

  @override
  State<UploadPanel> createState() => _UploadPanelState();
}

class _UploadPanelState extends State<UploadPanel> {
  final _api = ApiService();
  List<Student> _students = [];
  final Set<String> _selectedStudentIds = {};
  DateTime _selectedDate = DateTime.now();
  final _titleCtrl = TextEditingController();
  List<({String name, Uint8List bytes, String mime})> _pendingFiles = [];
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    try {
      final s = await _api.getStudents();
      setState(() => _students = s);
    } catch (_) {}
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'mp4', 'mov'],
      allowMultiple: true,
      withData: true,
    );
    if (result == null) return;
    setState(() {
      for (final f in result.files) {
        if (f.bytes == null) continue;
        final mime = f.extension?.toLowerCase() == 'mp4' || f.extension?.toLowerCase() == 'mov'
          ? 'video/mp4'
          : 'image/jpeg';
        _pendingFiles.add((name: f.name, bytes: f.bytes!, mime: mime));
      }
    });
  }

  Future<void> _submit() async {
    if (_selectedStudentIds.isEmpty) {
      _toast('Please select at least one student', isError: true);
      return;
    }
    if (_titleCtrl.text.trim().isEmpty) {
      _toast('Please add a title', isError: true);
      return;
    }
    if (_pendingFiles.isEmpty) {
      _toast('Please choose at least one file', isError: true);
      return;
    }
    setState(() => _uploading = true);
    try {
      await _api.uploadMedia(
        studentIds: _selectedStudentIds.toList(),
        date: _selectedDate.toIso8601String().split('T').first,
        title: _titleCtrl.text.trim(),
        files: _pendingFiles,
      );
      _toast('${_pendingFiles.length} item(s) uploaded!', isError: false);
      setState(() {
        _pendingFiles = [];
        _titleCtrl.clear();
        _selectedStudentIds.clear();
      });
    } catch (e) {
      _toast('Upload failed: $e', isError: true);
    } finally {
      setState(() => _uploading = false);
    }
  }

  void _toast(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${isError ? "❌" : "✅"} $msg'),
        backgroundColor: isError ? AppColors.error : AppColors.navy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(24),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Upload Media', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontFamily: 'PlayfairDisplay')),
          const SizedBox(height: 6),
          const Text('Attach photos or videos and tag related students', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
          const SizedBox(height: 28),
          _buildCard(
            title: '📤 New Upload',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date picker
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final d = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (d != null) setState(() => _selectedDate = d);
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Date Taken'),
                          child: Text(DateFormat.yMMMd().format(_selectedDate)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(labelText: 'Title / Caption', hintText: 'e.g. Science Fair Project'),
                ),
                const SizedBox(height: 20),
                // Multi-student tagging
                const Text('TAG STUDENTS', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.navy, letterSpacing: 1)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.gray),
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _students.map((s) {
                      final selected = _selectedStudentIds.contains(s.id);
                      return FilterChip(
                        label: Text('${s.name} (${s.id})'),
                        selected: selected,
                        onSelected: (v) {
                          setState(() {
                            if (v) {
                              _selectedStudentIds.add(s.id);
                            } else {
                              _selectedStudentIds.remove(s.id);
                            }
                          });
                        },
                        selectedColor: AppColors.accent.withOpacity(0.2),
                        checkmarkColor: AppColors.accent,
                        labelStyle: TextStyle(
                          color: selected ? AppColors.accent : AppColors.text,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('MEDIA FILES', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.navy, letterSpacing: 1)),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: _pickFiles,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.cream,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.grayDark, width: 3, style: BorderStyle.solid),
                    ),
                    child: Column(
                      children: [
                        const Text('📁', style: TextStyle(fontSize: 36)),
                        const SizedBox(height: 8),
                        Text('Click to choose photos or videos', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                        const Text('JPG, PNG, GIF, MP4, MOV supported', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                if (_pendingFiles.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _pendingFiles.asMap().entries.map((e) {
                      final i = e.key;
                      final f = e.value;
                      final isVideo = f.mime.startsWith('video');
                      return Stack(
                        children: [
                          Container(
                            width: 80,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.gray, width: 2),
                              color: AppColors.gray,
                            ),
                            child: isVideo
                              ? const Center(child: Icon(Icons.videocam, color: AppColors.textMuted))
                              : Image.memory(f.bytes, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: -6,
                            right: -6,
                            child: GestureDetector(
                              onTap: () => setState(() => _pendingFiles.removeAt(i)),
                              child: Container(
                                width: 18,
                                height: 18,
                                decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                                child: const Center(
                                  child: Text('✕', style: TextStyle(color: AppColors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _uploading ? null : _submit,
                    child: _uploading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                      : const Text('Upload Media ✓'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  STUDENTS (FULL CRUD: Create, Read, Update, Delete)
// ═══════════════════════════════════════════════
class StudentsPanel extends StatefulWidget {
  const StudentsPanel({super.key});

  @override
  State<StudentsPanel> createState() => _StudentsPanelState();
}

class _StudentsPanelState extends State<StudentsPanel> {
  final _api = ApiService();
  List<Student> _students = [];
  List<MediaItem> _media = [];
  bool _loading = true;

  final _nameCtrl = TextEditingController();
  final _idCtrl = TextEditingController();
  final _classCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final students = await _api.getStudents();
      final media = await _api.getMedia();
      setState(() {
        _students = students;
        _media = media;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _addStudent() async {
    final name = _nameCtrl.text.trim();
    final id = _idCtrl.text.trim();
    if (name.isEmpty || id.isEmpty) {
      _toast('Please fill in name and ID', isError: true);
      return;
    }
    try {
      await _api.addStudent(id, name, _classCtrl.text.trim());
      _nameCtrl.clear(); _idCtrl.clear(); _classCtrl.clear();
      await _load();
      _toast('Student added successfully', isError: false);
    } catch (e) {
      _toast('Failed to add student: $e', isError: true);
    }
  }

  Future<void> _editStudent(Student student) async {
    final nameCtrl = TextEditingController(text: student.name);
    final classCtrl = TextEditingController(text: student.cls ?? '');
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Student'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name')),
            const SizedBox(height: 12),
            TextField(controller: classCtrl, decoration: const InputDecoration(labelText: 'Class / Grade')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, {'name': nameCtrl.text, 'class': classCtrl.text}),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result == null) return;
    try {
      await _api.updateStudent(student.id, name: result['name'], cls: result['class']);
      await _load();
      _toast('Student updated', isError: false);
    } catch (e) {
      _toast('Failed to update: $e', isError: true);
    }
  }

  Future<void> _removeStudent(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove Student?'),
        content: const Text('This will remove the student from all media tags. If a media item has no students left, it will be deleted entirely.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: AppColors.white),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _api.deleteStudent(id);
      await _load();
      _toast('Student removed', isError: false);
    } catch (e) {
      _toast('Failed to remove: $e', isError: true);
    }
  }

  void _toast(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${isError ? "❌" : "✅"} $msg'),
        backgroundColor: isError ? AppColors.error : AppColors.navy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(24),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: AppColors.accent));
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Students', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontFamily: 'PlayfairDisplay')),
          const SizedBox(height: 6),
          const Text('Manage student records', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
          const SizedBox(height: 28),
          _buildCard(
            title: '➕ Add New Student',
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(labelText: 'Full Name', hintText: 'e.g. Emma Johnson'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _idCtrl,
                        decoration: const InputDecoration(labelText: 'Student ID', hintText: 'e.g. S-1001'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _classCtrl,
                  decoration: const InputDecoration(labelText: 'Class / Grade', hintText: 'e.g. Grade 3-A'),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(onPressed: _addStudent, child: const Text('Add Student')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildCard(
            title: '👦 All Students',
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(1.5),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(1.5),
                3: FlexColumnWidth(1),
                4: FixedColumnWidth(160),
              },
              children: [
                TableRow(
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.gray, width: 2))),
                  children: ['ID', 'Name', 'Class', 'Media', 'Actions'].map((h) =>
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(h, style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                    ),
                  ).toList(),
                ),
                ..._students.map((s) {
                  final count = _media.where((m) => m.studentIds.contains(s.id)).length;
                  return TableRow(
                    children: [
                      Padding(padding: const EdgeInsets.all(14), child: Text(s.id, style: const TextStyle(fontFamily: 'monospace'))),
                      Padding(padding: const EdgeInsets.all(14), child: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w700))),
                      Padding(padding: const EdgeInsets.all(14), child: Text(s.cls ?? '—')),
                      Padding(padding: const EdgeInsets.all(14), child: Text('$count files')),
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            OutlinedButton(
                              onPressed: () => _editStudent(s),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.accent,
                                side: const BorderSide(color: AppColors.accent),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text('Edit', style: TextStyle(fontSize: 13)),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: () => _removeStudent(s.id),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.error,
                                side: const BorderSide(color: AppColors.error),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text('Remove', style: TextStyle(fontSize: 13)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  ALL MEDIA (with edit tags)
// ═══════════════════════════════════════════════
class AllMediaPanel extends StatefulWidget {
  const AllMediaPanel({super.key});

  @override
  State<AllMediaPanel> createState() => _AllMediaPanelState();
}

class _AllMediaPanelState extends State<AllMediaPanel> {
  final _api = ApiService();
  List<MediaItem> _media = [];
  List<Student> _students = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final media = await _api.getMedia();
      final students = await _api.getStudents();
      setState(() { _media = media; _students = students; _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _editTags(MediaItem item) async {
    final selectedIds = Set<String>.from(item.studentIds);
    final result = await showDialog<Set<String>>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Tagged Students'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _students.map((s) {
                return CheckboxListTile(
                  title: Text('${s.name} (${s.id})'),
                  value: selectedIds.contains(s.id),
                  onChanged: (v) {
                    setState(() {
                      if (v == true) {
                        selectedIds.add(s.id);
                      } else {
                        selectedIds.remove(s.id);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, selectedIds),
            child: const Text('Save Tags'),
          ),
        ],
      ),
    );
    if (result == null || result.isEmpty) {
      _toast('Media must have at least one student tagged', isError: true);
      return;
    }
    try {
      await _api.updateMedia(item.id, studentIds: result.toList());
      await _load();
      _toast('Tags updated', isError: false);
    } catch (e) {
      _toast('Failed to update tags: $e', isError: true);
    }
  }

  Future<void> _delete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Media?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: AppColors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _api.deleteMedia(id);
      await _load();
      _toast('Media deleted', isError: false);
    } catch (e) {
      _toast('Failed to delete', isError: true);
    }
  }

  void _toast(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${isError ? "❌" : "✅"} $msg'),
        backgroundColor: isError ? AppColors.error : AppColors.navy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(24),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: AppColors.accent));
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('All Media', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontFamily: 'PlayfairDisplay')),
          const SizedBox(height: 6),
          const Text('Browse and manage all uploaded content', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
          const SizedBox(height: 28),
          _buildCard(
            title: '',
            child: Table(
              columnWidths: const {
                0: FixedColumnWidth(64),
                1: FlexColumnWidth(2.5),
                2: FlexColumnWidth(2),
                3: FixedColumnWidth(80),
                4: FixedColumnWidth(120),
                5: FixedColumnWidth(160),
              },
              children: [
                TableRow(
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.gray, width: 2))),
                  children: ['Preview', 'Title', 'Students', 'Type', 'Date', 'Actions'].map((h) =>
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(h, style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                    ),
                  ).toList(),
                ),
                ..._media.map((m) => TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          m.displayThumb,
                          width: 48,
                          height: 36,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(width: 48, height: 36, color: AppColors.gray),
                        ),
                      ),
                    ),
                    Padding(padding: const EdgeInsets.all(14), child: Text(m.title)),
                    Padding(padding: const EdgeInsets.all(14), child: Text(m.taggedStudentsText)),
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: m.isPhoto ? const Color(0xFFe8f5e9) : const Color(0xFFe3f2fd),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          m.type,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: m.isPhoto ? const Color(0xFF2e7d32) : const Color(0xFF1565c0),
                          ),
                        ),
                      ),
                    ),
                    Padding(padding: const EdgeInsets.all(14), child: Text(DateFormat.yMMMd().format(DateTime.parse(m.date)))),
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          OutlinedButton(
                            onPressed: () => _editTags(m),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.accent,
                              side: const BorderSide(color: AppColors.accent),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('Edit Tags', style: TextStyle(fontSize: 13)),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () => _delete(m.id),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: const BorderSide(color: AppColors.error),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('Delete', style: TextStyle(fontSize: 13)),
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  SHARED
// ═══════════════════════════════════════════════
Widget _buildCard({required String title, required Widget child}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [BoxShadow(color: Color(0x1A0a1628), blurRadius: 20, offset: Offset(0, 4))],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: AppColors.navy)),
          const SizedBox(height: 20),
        ],
        child,
      ],
    ),
  );
}
