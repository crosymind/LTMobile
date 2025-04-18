import 'package:flutter/material.dart';
import '../db/UserDatabaseHelpers.dart';
import '../model/note.dart';
import '../view/NoteItem.dart';
import 'NoteForm.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({Key? key}) : super(key: key);

  @override
  _NoteListScreenState createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  final NoteDatabaseHelper _dbHelper = NoteDatabaseHelper.instance;
  List<Note> _notes = [];
  bool _isGridView = false;
  String _searchQuery = '';
  int? _priorityFilter;

  @override
  void initState() {
    super.initState();
    _refreshNotes();
  }

  Future<void> _refreshNotes() async {
    List<Note> notes;
    if (_searchQuery.isNotEmpty) {
      notes = await _dbHelper.searchNotes(_searchQuery);
    } else if (_priorityFilter != null) {
      notes = await _dbHelper.getNotesByPriority(_priorityFilter!);
    } else {
      notes = await _dbHelper.getAllNotes();
    }
    setState(() {
      _notes = notes;
    });
  }

  void _navigateToNoteForm(Note? note) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteFormScreen(note: note),
      ),
    );
    _refreshNotes();
  }

  void _deleteNote(int id) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc chắn muốn xóa ghi chú này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              await _dbHelper.deleteNote(id);
              Navigator.pop(context);
              _refreshNotes();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã xóa ghi chú')),
              );
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Ghi chú'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshNotes,
          ),
          PopupMenuButton(
            onSelected: (value) {
              setState(() {
                _priorityFilter = value == 0 ? null : value;
              });
              _refreshNotes();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 0,
                child: Text('Tất cả ưu tiên'),
              ),
              const PopupMenuItem(
                value: 1,
                child: Text('Ưu tiên thấp'),
              ),
              const PopupMenuItem(
                value: 2,
                child: Text('Ưu tiên trung bình'),
              ),
              const PopupMenuItem(
                value: 3,
                child: Text('Ưu tiên cao'),
              ),
            ],
          ),
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Tìm kiếm',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _refreshNotes();
              },
            ),
          ),
          Expanded(
            child: _notes.isEmpty
                ? const Center(
              child: Text('Không có ghi chú nào'),
            )
                : _isGridView
                ? GridView.builder(
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
              ),
              itemCount: _notes.length,
              itemBuilder: (context, index) => NoteItem(
                note: _notes[index],
                onEdit: () => _navigateToNoteForm(_notes[index]),
                onDelete: () => _deleteNote(_notes[index].id!),
              ),
            )
                : ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (context, index) => NoteItem(
                note: _notes[index],
                onEdit: () => _navigateToNoteForm(_notes[index]),
                onDelete: () => _deleteNote(_notes[index].id!),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToNoteForm(null),
        child: const Icon(Icons.add),
      ),
    );
  }
}