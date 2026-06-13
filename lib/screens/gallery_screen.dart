import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/media_item.dart';
import '../models/student.dart';
import '../services/api_service.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import 'lightbox_screen.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final _api = ApiService();
  List<MediaItem> _media = [];
  List<MediaItem> _filtered = [];
  bool _loading = true;
  String _filter = 'all';
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadMedia();
  }

  Future<void> _loadMedia() async {
    final state = context.read<AppState>();
    final studentId = state.currentStudent!.id;
    try {
      final media = await _api.getMedia(studentId: studentId);
      setState(() {
        _media = media;
        _applyFilter();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _applyFilter() {
    _filtered = _media.where((m) {
      final typeOk = _filter == 'all' || m.type == _filter;
      final searchOk = _search.isEmpty || m.title.toLowerCase().contains(_search.toLowerCase());
      return typeOk && searchOk;
    }).toList();
  }

  void _setFilter(String f) {
    setState(() { _filter = f; _applyFilter(); });
  }

  void _setSearch(String s) {
    setState(() { _search = s; _applyFilter(); });
  }

  @override
  Widget build(BuildContext context) {
    final student = context.read<AppState>().currentStudent!;
    final count = _media.length;

    return Scaffold(
      body: Column(
        children: [
          _buildTopNav(student.name),
          _buildHero(student, count),
          _buildControls(),
          Expanded(
            child: _loading
              ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
              : _filtered.isEmpty
                ? _buildEmpty()
                : _buildGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopNav(String name) {
    return Container(
      height: 64,
      color: AppColors.navy,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Image.asset('assets/images/logo.png', height: 36),
          const SizedBox(width: 10),
          Text(
            'Harmonia',
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
            child: Text(
              name,
              style: const TextStyle(color: AppColors.white, fontSize: 13, fontWeight: FontWeight.w700),
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

  Widget _buildHero(Student student, int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(32, 40, 32, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.navy, AppColors.navyLight],
        ),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  student.id,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                student.name,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontFamily: 'PlayfairDisplay',
                  color: AppColors.white,
                  fontSize: 32,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$count photo${count != 1 ? 's' : ''} & video${count != 1 ? 's' : ''}',
                style: const TextStyle(color: Colors.white70, fontSize: 15),
              ),
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Opacity(
              opacity: 0.06,
              child: Image.asset('assets/images/logo.png', height: 120),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: AppColors.white,
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _filterChip('All', 'all'),
          _filterChip('📷 Photos', 'photo'),
          _filterChip('🎬 Videos', 'video'),
          const SizedBox(width: 12),
          SizedBox(
            width: 200,
            child: TextField(
              onChanged: _setSearch,
              decoration: const InputDecoration(
                hintText: '🔍 Search...',
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final active = _filter == value;
    return GestureDetector(
      onTap: () => _setFilter(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.accent : Colors.transparent,
          border: Border.all(color: active ? AppColors.accent : AppColors.gray, width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: active ? AppColors.white : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('📭', style: TextStyle(fontSize: 64, color: AppColors.textMuted.withOpacity(0.3))),
          const SizedBox(height: 16),
          const Text('No media found for this filter.', style: TextStyle(color: AppColors.textMuted, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 280,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 0.82,
      ),
      itemCount: _filtered.length,
      itemBuilder: (ctx, i) {
        final m = _filtered[i];
        return _PolaroidCard(
          media: m,
          onTap: () => _openLightbox(m),
        );
      },
    );
  }

  void _openLightbox(MediaItem m) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (_) => LightboxDialog(media: m),
    );
  }
}

class _PolaroidCard extends StatelessWidget {
  final MediaItem media;
  final VoidCallback onTap;
  const _PolaroidCard({required this.media, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final rotation = media.hashCode.isEven ? -0.01 : 0.01;
    return Transform.rotate(
      angle: rotation,
      child: GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x1A0a1628),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          media.displayThumb,
                          fit: BoxFit.cover,
                          loadingBuilder: (ctx, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              color: AppColors.gray,
                              child: const Center(child: CircularProgressIndicator(color: AppColors.accent)),
                            );
                          },
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.gray,
                            child: const Center(child: Icon(Icons.broken_image, color: AppColors.textMuted)),
                          ),
                        ),
                        if (media.isVideo)
                          Container(
                            color: const Color(0x591A2744),
                            child: Center(
                              child: Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.play_arrow, color: AppColors.navy, size: 24),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.navy,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '📅 ${DateFormat.yMMMd().format(DateTime.parse(media.date))}',
                            style: const TextStyle(color: AppColors.white, fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          media.title,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.navy),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (media.studentNames != null && media.studentNames!.isNotEmpty)
                          Text(
                            'With: ${media.studentNames!.take(2).join(', ')}${media.studentNames!.length > 2 ? ' +${media.studentNames!.length - 2}' : ''}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: media.isPhoto ? const Color(0xFFe8f5e9) : const Color(0xFFe3f2fd),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            media.isPhoto ? '📷 Photo' : '🎬 Video',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: media.isPhoto ? const Color(0xFF2e7d32) : const Color(0xFF1565c0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
