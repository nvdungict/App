import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

void main() => runApp(const NotesApp());

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.grey[100],
        primarySwatch: Colors.amber,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 18),
        ),
      ),
      home: const NotesListPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Note {
  final String id;
  String title;
  String content;
  DateTime createdAt;
  DateTime updatedAt;

  Note({
    String? id,
    required this.title,
    required this.content,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();
}

class NotesListPage extends StatefulWidget {
  const NotesListPage({super.key});

  @override
  State<NotesListPage> createState() => _NotesListPageState();
}

class _NotesListPageState extends State<NotesListPage> {
  final List<Note> _notes = [];

  void _addNote() {
    final newNote = Note(title: 'Untitled', content: '');
    setState(() => _notes.insert(0, newNote));

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteDetailPage(
          note: newNote,
          onUpdate: () => setState(() {}),
        ),
      ),
    );
  }

  void _openNote(Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteDetailPage(
          note: note,
          onUpdate: () => setState(() {}),
        ),
      ),
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Notes')),
    body: ListView.builder(
      itemCount: _notes.length,
      itemBuilder: (context, index) {
        final note = _notes[index];

        return Dismissible(
          key: Key(note.id), // Make sure each note has a unique id
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) {
            setState(() {
              _notes.removeAt(index);
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Note deleted')),
            );
          },
          child: ListTile(
            title: Text(
              note.title.isEmpty ? '(No Title)' : note.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              note.content.isEmpty ? '(No Content)' : note.content.split('\n').first,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              DateFormat('MMM d').format(note.updatedAt),
              style: const TextStyle(color: Colors.grey),
            ),
            onTap: () => _openNote(note),
          ),
        );
      },
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: _addNote,
      child: const Icon(Icons.note_add),
    ),
  );
}
}

class NoteDetailPage extends StatefulWidget {
  final Note note;
  final VoidCallback onUpdate;

  const NoteDetailPage({
    super.key,
    required this.note,
    required this.onUpdate,
  });

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  void _save() {
    setState(() {
      widget.note.title = _titleController.text;
      widget.note.content = _contentController.text;
      widget.note.updatedAt = DateTime.now();
    });
    widget.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
    _titleController.addListener(_save);
    _contentController.addListener(_save);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Note')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  hintText: 'Start typing...',
                  border: InputBorder.none,
                ),
                maxLines: null,
                expands: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
