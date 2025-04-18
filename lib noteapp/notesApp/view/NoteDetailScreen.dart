import 'package:flutter/material.dart';
import 'package:notesapp/notesApp/model/Note.dart'; // Import lớp Note đã tạo trước đó
import 'package:notesapp/notesApp/db/UserDatabaseHelpers.dart';
import 'package:notesapp/notesApp/view/NoteDetailScreen.dart';
import 'package:notesapp/notesApp/view/NoteForm.dart';
import 'package:intl/intl.dart';

class NoteDetailScreen extends StatelessWidget {
  final Note note;

  const NoteDetailScreen({required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết ghi chú'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NoteForm(note: note),
                fullscreenDialog: true,
              ),
            ).then((_) => Navigator.pop(context, true)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              note.content,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            if (note.tags != null && note.tags!.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                children: note.tags!
                    .map((tag) => Chip(label: Text(tag)))
                    .toList(),
              ),
              SizedBox(height: 16),
            ],
            Text(
              'Tạo lúc: ${DateFormat('dd/MM/yyyy HH:mm').format(note.createdAt)}',
              style: TextStyle(color: Colors.grey),
            ),
            Text(
              'Cập nhật: ${DateFormat('dd/MM/yyyy HH:mm').format(note.modifiedAt)}',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}