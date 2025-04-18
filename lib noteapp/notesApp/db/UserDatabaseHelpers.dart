import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:notesapp/notesApp/model/Note.dart'; // Import lớp Note đã tạo trước đó

class NoteDatabaseHelper {
  static final NoteDatabaseHelper instance = NoteDatabaseHelper._init();
  static Database? _database;

  NoteDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        priority INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        modifiedAt TEXT NOT NULL,
        tags TEXT,
        color TEXT
      )
    ''');
  }

  // Thêm ghi chú mới
  Future<Note> insertNote(Note note) async {
    final db = await instance.database;

    final id = await db.insert('notes', note.toMap());
    return note.copyWith(id: id);
  }

  // Lấy tất cả ghi chú (sắp xếp theo thời gian sửa đổi mới nhất)
  Future<List<Note>> getAllNotes() async {
    final db = await instance.database;

    final result = await db.query('notes', orderBy: 'modifiedAt DESC');
    return result.map((json) => Note.fromMap(json)).toList();
  }

  // Lấy ghi chú theo ID
  Future<Note?> getNoteById(int id) async {
    final db = await instance.database;

    final result = await db.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return Note.fromMap(result.first);
    } else {
      return null;
    }
  }

  // Cập nhật ghi chú
  Future<int> updateNote(Note note) async {
    final db = await instance.database;

    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  // Xóa ghi chú
  Future<int> deleteNote(int id) async {
    final db = await instance.database;

    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Lấy ghi chú theo mức độ ưu tiên
  Future<List<Note>> getNotesByPriority(int priority) async {
    final db = await instance.database;

    final result = await db.query(
      'notes',
      where: 'priority = ?',
      whereArgs: [priority],
      orderBy: 'modifiedAt DESC',
    );

    return result.map((json) => Note.fromMap(json)).toList();
  }

  // Tìm kiếm ghi chú theo từ khóa (trong tiêu đề hoặc nội dung)
  Future<List<Note>> searchNotes(String query) async {
    final db = await instance.database;
    final searchQuery = '%$query%';

    final result = await db.query(
      'notes',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: [searchQuery, searchQuery],
      orderBy: 'modifiedAt DESC',
    );

    return result.map((json) => Note.fromMap(json)).toList();
  }

  // Đóng kết nối database khi không cần thiết
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}