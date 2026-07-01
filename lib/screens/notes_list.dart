import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import '../models/note.dart';
import 'note_editor.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});
  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final _db = DatabaseHelper();
  List<Note> _notes = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() { super.initState(); _loadNotes(); }

  Future<void> _loadNotes() async {
    setState(() => _loading = true);
    final notes = _searchQuery.isEmpty ? await _db.getNotes() : await _db.searchNotes(_searchQuery);
    setState(() { _notes = notes; _loading = false; });
  }

  Future<void> _deleteNote(Note note) async {
    await _db.deleteNote(note.id!);
    _loadNotes();
  }

  Color _cardColor(int index) {
    const colors = [Color(0xFF6C5CE7), Color(0xFF00B894), Color(0xFFE17055), Color(0xFF0984E3), Color(0xFFFDCB6E), Color(0xFFE84393)];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) { _searchQuery = v; _loadNotes(); },
              decoration: InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.4),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notes.isEmpty
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.note_add_outlined, size: 64, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text('No notes yet', style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                  const SizedBox(height: 4),
                  Text('Tap + to create one', style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3))),
                ]))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                  itemCount: _notes.length,
                  itemBuilder: (ctx, i) {
                    final note = _notes[i];
                    final dateStr = DateFormat('MMM d, yyyy \u00b7 h:mm a').format(note.updatedAt);
                    return Dismissible(
                      key: Key('note_\${note.id}'),
                      direction: DismissDirection.endToStart,
                      background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), decoration: BoxDecoration(color: Colors.red.withOpacity(0.8), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.delete, color: Colors.white)),
                      onDismissed: (_) => _deleteNote(note),
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: _cardColor(i).withOpacity(0.15),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () async {
                            await Navigator.push(context, MaterialPageRoute(builder: (_) => NoteEditorScreen(note: note)));
                            _loadNotes();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(children: [
                                Container(width: 4, height: 20, decoration: BoxDecoration(color: _cardColor(i), borderRadius: BorderRadius.circular(2))),
                                const SizedBox(width: 10),
                                Expanded(child: Text(note.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
                              ]),
                              if (note.content.isNotEmpty) ...[const SizedBox(height: 8), Text(note.content, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)))],
                              const SizedBox(height: 10),
                              Text(dateStr, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4))),
                            ]),
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => const NoteEditorScreen())); _loadNotes(); },
        icon: const Icon(Icons.add),
        label: const Text('New Note'),
      ),
    );
  }
}
