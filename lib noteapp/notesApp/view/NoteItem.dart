import 'package:flutter/material.dart';
import 'package:notesapp/notesApp/model/Note.dart'; // Import lớp Note đã tạo trước đó
import 'package:notesapp/notesApp/db/UserDatabaseHelpers.dart';
import 'package:notesapp/notesApp/view/NoteDetailScreen.dart';
import 'package:intl/intl.dart';
class NoteItem extends StatelessWidget {
  final Note note;
  final Function(int)? onDelete;
  final Function(Note)? onTap;

  const NoteItem({
    required this.note,
    this.onDelete,
    this.onTap,
  });

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1: return Colors.green;
      case 2: return Colors.orange;
      case 3: return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: note.color != null ? Color(int.parse(note.color!.replaceFirst('#', '0xff'))) : null,
      elevation: 2,
      margin: EdgeInsets.all(8),
      child: InkWell(
        onTap: () => onTap?.call(note),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getPriorityColor(note.priority),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                note.content.length > 100
                    ? '${note.content.substring(0, 100)}...'
                    : note.content,
                style: TextStyle(fontSize: 14),
              ),
              if (note.tags != null && note.tags!.isNotEmpty) ...[
                SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  children: note.tags!
                      .map((tag) => Chip(
                    label: Text(tag),
                    labelStyle: TextStyle(fontSize: 12),
                  ))
                      .toList(),
                ),
              ],
              Spacer(),
              Text(
                'Cập nhật: ${DateFormat('dd/MM/yyyy HH:mm').format(note.modifiedAt)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              if (onDelete != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => onDelete!(note.id!),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}