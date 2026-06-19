import 'package:flutter/material.dart';

import '../../models/student.dart';

class MultiTagSelector extends StatefulWidget {
  final List<Student> tags;
  final List<String> initialSelected;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemoved;
  final String hint;

  const MultiTagSelector({super.key, required this.tags, this.initialSelected = const [], required this.onAdd, required this.onRemoved, this.hint = 'Search students...'});

  @override
  State<MultiTagSelector> createState() => _MultiTagSelectorState();
}

class _MultiTagSelectorState extends State<MultiTagSelector> {
  late List<String> _selected;
  final TextEditingController _ctrl = TextEditingController();
  final FocusNode _focus = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlay;
  List<Student> _filtered = [];

  final List<Color> _palette = [Colors.purple.shade100, Colors.teal.shade100, Colors.pink.shade100, Colors.blue.shade100, Colors.orange.shade100, Colors.green.shade100];

  Color _colorFor() {
    _palette.shuffle();
    return _palette.first;
  }

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.initialSelected);
    _filtered = widget.tags;
    _focus.addListener(() {
      if (_focus.hasFocus) {
        _showOverlay();
      } else {
        Future.delayed(const Duration(milliseconds: 200), _hideOverlay);
      }
    });
  }

  void _filter(String query) {
    setState(() {
      _filtered = widget.tags.where((t) => t.name.toLowerCase().contains(query.toLowerCase()) || t.code.toLowerCase().contains(query.toLowerCase())).toList();
    });
    _overlay?.markNeedsBuild();
  }

  void _addTag(Student tag) {
    final t = tag.key;
    if (t.isEmpty || _selected.contains(t)) return;
    setState(() => _selected.add(t));
    widget.onAdd(t);
    _ctrl.clear();
    _filtered = widget.tags;
    _overlay?.markNeedsBuild();
  }

  void _removeTag(Student tag) {
    setState(() => _selected.remove(tag.key));
    widget.onRemoved(tag.key);
  }

  void _toggleTag(Student tag) {
    if (_selected.contains(tag.key)) {
      _removeTag(tag);
    } else {
      _addTag(tag);
    }
  }

  void _showOverlay() {
    _overlay = OverlayEntry(
      builder: (context) {
        return Positioned(
          width: 300,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: const Offset(0, 52),
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: StatefulBuilder(
                builder: (ctx, setSt) {
                  return ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 220),
                    child: ListView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      children: _filtered.isEmpty
                          ? [
                              ListTile(
                                dense: true,
                                title: Text('search not found', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                              ),
                            ]
                          : _filtered.map((tag) {
                              final isSel = _selected.contains(tag.key);
                              return ListTile(
                                dense: true,
                                title: Text(tag.name, style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis, maxLines: 1),
                                trailing: isSel ? const Icon(Icons.check, size: 16) : null,
                                leading: Text(tag.code, style: const TextStyle(fontSize: 10, color: Colors.black38)),
                                onTap: () {
                                  _toggleTag(tag);
                                  _overlay?.markNeedsBuild();
                                },
                              );
                            }).toList(),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
    Overlay.of(context).insert(_overlay!);
  }

  void _hideOverlay() {
    _overlay?.remove();
    _overlay = null;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    _hideOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(_focus),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ..._selected.map((tag) {
                final t = widget.tags.firstWhere((s) => s.key == tag);
                return Chip(
                  label: Text(t.name, style: const TextStyle(fontSize: 13)),
                  backgroundColor: _colorFor(),
                  deleteIcon: const Icon(Icons.close, size: 14),
                  onDeleted: () => _removeTag(t),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                );
              }),
              IntrinsicWidth(
                child: TextField(
                  controller: _ctrl,
                  focusNode: _focus,
                  decoration: InputDecoration(hintText: _selected.isEmpty ? widget.hint : '', border: InputBorder.none, isDense: true, contentPadding: const EdgeInsets.symmetric(vertical: 6)),
                  style: const TextStyle(fontSize: 14),
                  onChanged: _filter,
                  onSubmitted: (_) {
                    if (_filtered.isNotEmpty) {
                      _addTag(_filtered.first);
                    }
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
