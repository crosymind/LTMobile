import 'dart:io';
import 'package:flutter/material.dart';
import '../model/note.dart';
import '../view/NoteForm.dart';
import "package:intl/intl.dart";

class NoteDetailScreen extends StatelessWidget {
  final Note note;

  const NoteDetailScreen({Key? key, required this.note}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(note.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteFormScreen(note: note),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (note.color != null)
              Container(
                height: 10,
                color: Color(int.parse(note.color!, radix: 16)),
              ),
            const SizedBox(height: 16),
            Text(
              note.title,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Ưu tiên: ${_getPriorityText(note.priority)}',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 16),
            Text(
              note.content,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            if (note.tags != null && note.tags!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: note.tags!
                    .map((tag) => Chip(label: Text(tag)))
                    .toList(),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              'Tạo lúc: ${note.createdAt.toString().substring(0, 16)}',
              style: const TextStyle(color: Colors.grey),
            ),
            Text(
              'Cập nhật lúc: ${note.modifiedAt.toString().substring(0, 16)}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  String _getPriorityText(int priority) {
    switch (priority) {
      case 1:
        return 'Thấp';
      case 2:
        return 'Trung bình';
      case 3:
        return 'Cao';
      default:
        return 'Không xác định';
    }
  }
}