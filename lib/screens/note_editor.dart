import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/note.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note;
  const NoteEditorScreen({super.key, this.note});
  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;
  final _db = DatabaseHelper();
  bool _saving = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.note?.title ?? '');
    _contentCtrl = TextEditingController(text: widget.note?.content ?? '');
    _titleCtrl.addListener(_onChanged);
    _contentCtrl.addListener(_onChanged);
  }

  void _onChanged() { if (!_hasChanges) setState(() => _hasChanges = true); }
  bool get _isEditing => widget.note != null;

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title is required'), behavior: SnackBarBehavior.floating));
      return;
    }
    setState(() => _saving = true);
    try {
      if (_isEditing) {
        await _db.updateNote(widget.note!.copyWith(title: title, content: _contentCtrl.text.trim()));
      } else {
        final now = DateTime.now();
        await _db.insertNote(Note(title: title, content: _contentCtrl.text.trim(), createdAt: now, updatedAt: now));
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: \$e'), behavior: SnackBarBehavior.floating));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() { _titleCtrl.dispose(); _contentCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
          title: const Text('Discard changes?'), content: const Text('You have unsaved changes.'),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep')), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Discard'))],
        ));
        if (leave == true && mounted) Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Edit Note' : 'New Note'), centerTitle: false,
          actions: [TextButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.check),
            label: const Text('Save'),
          )],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            TextField(controller: _titleCtrl, autofocus: !_isEditing, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), decoration: const InputDecoration(hintText: 'Note title', border: InputBorder.none)),
            const SizedBox(height: 16),
            TextField(controller: _contentCtrl, maxLines: null, minLines: 10, style: const TextStyle(fontSize: 15, height: 1.6), decoration: InputDecoration(hintText: 'Write something...', border: InputBorder.none, hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)))),
          ]),
        ),
      ),
    );
  }
}
