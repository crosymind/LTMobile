import 'package:flutter/material.dart';
import 'package:notesapp/notesApp/model/Note.dart'; // Import lớp Note đã tạo trước đó
import 'package:notesapp/notesApp/db/UserDatabaseHelpers.dart';
import 'package:notesapp/notesApp/view/NoteDetailScreen.dart';
import 'package:notesapp/notesApp/view/NoteItem.dart';

class NoteListScreen extends StatefulWidget {
  @override
  _NoteListScreenState createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  final NoteDatabaseHelper dbHelper = NoteDatabaseHelper.instance;
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
    try {
      final notes = await dbHelper.getAllNotes();
      print('Dữ liệu nhận được từ DB: $notes'); // Debug
      setState(() {
        _notes = notes;
      });
    } catch (e) {
      print('Lỗi khi lấy ghi chú: $e'); // Bắt lỗi
    }
  }

  Future<void> _searchNotes() async {
    final notes = await dbHelper.searchNotes(_searchQuery);
    setState(() => _notes = notes);
  }

  Future<void> _filterByPriority(int? priority) async {
    final notes = priority != null
        ? await dbHelper.getNotesByPriority(priority)
        : await dbHelper.getAllNotes();
    setState(() {
      _notes = notes;
      _priorityFilter = priority;
    });
  }

  void _toggleViewMode() {
    setState(() => _isGridView = !_isGridView);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ghi chú của tôi'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => showSearch(
              context: context,
              delegate: NoteSearchDelegate(dbHelper),
            ),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text('Làm mới'),
                value: 'refresh',
              ),
              PopupMenuItem(
                child: Text('Lọc theo ưu tiên'),
                value: 'filter',
              ),
              PopupMenuItem(
                child: Text(_isGridView ? 'Xem danh sách' : 'Xem lưới'),
                value: 'view_mode',
              ),
            ],
            onSelected: (value) {
              if (value == 'refresh') _refreshNotes();
              if (value == 'filter') _showPriorityFilterDialog();
              if (value == 'view_mode') _toggleViewMode();
            },
          ),
        ],
      ),
      body: _notes.isEmpty
          ? Center(child: Text('Không có ghi chú nào'))
          : _isGridView
          ? GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
        ),
        itemCount: _notes.length,
        itemBuilder: (context, index) => NoteItem(
          note: _notes[index],
          onDelete: _deleteNote,
          onTap: _navigateToDetail,
        ),
      )
          : ListView.builder(
        itemCount: _notes.length,
        itemBuilder: (context, index) => NoteItem(
          note: _notes[index],
          onDelete: _deleteNote,
          onTap: _navigateToDetail,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _navigateToDetail(Note(
          title: '',
          content: '',
          priority: 2,
          createdAt: DateTime.now(),
          modifiedAt: DateTime.now(),
        )),
      ),
    );
  }

  void _showPriorityFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Lọc theo ưu tiên'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<int?>(
              title: Text('Tất cả'),
              value: null,
              groupValue: _priorityFilter,
              onChanged: (value) => _filterByPriority(value),
            ),
            RadioListTile<int>(
              title: Text('Ưu tiên cao'),
              value: 3,
              groupValue: _priorityFilter,
              onChanged: (value) => _filterByPriority(value),
            ),
            RadioListTile<int>(
              title: Text('Ưu tiên trung bình'),
              value: 2,
              groupValue: _priorityFilter,
              onChanged: (value) => _filterByPriority(value),
            ),
            RadioListTile<int>(
              title: Text('Ưu tiên thấp'),
              value: 1,
              groupValue: _priorityFilter,
              onChanged: (value) => _filterByPriority(value),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteNote(int id) async {
    final shouldDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xóa ghi chú'),
        content: Text('Bạn có chắc chắn muốn xóa ghi chú này?'),
        actions: [
          TextButton(
            child: Text('Hủy'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text('Xóa'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await dbHelper.deleteNote(id);
      _refreshNotes();
    }
  }

  void _navigateToDetail(Note note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteDetailScreen(note: note),
      ),
    );

    if (result == true) _refreshNotes();
  }
}

class NoteSearchDelegate extends SearchDelegate {
  final NoteDatabaseHelper dbHelper;

  NoteSearchDelegate(this.dbHelper);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<Note>>(
      future: dbHelper.searchNotes(query),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
        final notes = snapshot.data!;
        return ListView.builder(
          itemCount: notes.length,
          itemBuilder: (context, index) => NoteItem(
            note: notes[index],
            onTap: (note) => close(context, note),
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}