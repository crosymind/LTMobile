import 'package:flutter/material.dart';
import 'package:notesapp/notesApp/model/Note.dart'; // Import lớp Note đã tạo trước đó
import 'package:notesapp/notesApp/db/UserDatabaseHelpers.dart';
import 'package:notesapp/notesApp/view/NoteDetailScreen.dart';
import 'package:intl/intl.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
class NoteForm extends StatefulWidget {
  final Note note;

  const NoteForm({required this.note});

  @override
  _NoteFormState createState() => _NoteFormState();
}

class _NoteFormState extends State<NoteForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late int _priority;
  late List<String> _tags;
  late String? _color;
  final _tagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
    _priority = widget.note.priority;
    _tags = widget.note.tags?.toList() ?? [];
    _color = widget.note.color;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (_formKey.currentState!.validate()) {
      final updatedNote = widget.note.copyWith(
        title: _titleController.text,
        content: _contentController.text,
        priority: _priority,
        modifiedAt: DateTime.now(),
        tags: _tags,
        color: _color,
      );

      final dbHelper = NoteDatabaseHelper.instance;
      if (updatedNote.id == null) {
        await dbHelper.insertNote(updatedNote);
      } else {
        await dbHelper.updateNote(updatedNote);
      }

      Navigator.pop(context, true);
    }
  }

  void _addTag() {
    if (_tagController.text.isNotEmpty && !_tags.contains(_tagController.text)) {
      setState(() => _tags.add(_tagController.text));
      _tagController.clear();
    }
  }

  void _removeTag(String tag) {
    setState(() => _tags.remove(tag));
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chọn màu'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: _color != null ? Color(int.parse(_color!.replaceFirst('#', '0xff'))) : Colors.white,
            onColorChanged: (color) {
              setState(() => _color = '#${color.value.toRadixString(16).substring(2)}');
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note.id == null ? 'Thêm ghi chú mới' : 'Chỉnh sửa ghi chú'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Tiêu đề',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập tiêu đề' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: 'Nội dung',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập nội dung' : null,
              ),
              SizedBox(height: 16),
              Text('Mức độ ưu tiên'),
              Row(
                children: [
                  Radio<int>(
                    value: 1,
                    groupValue: _priority,
                    onChanged: (value) => setState(() => _priority = value!),
                  ),
                  Text('Thấp'),
                  Radio<int>(
                    value: 2,
                    groupValue: _priority,
                    onChanged: (value) => setState(() => _priority = value!),
                  ),
                  Text('Trung bình'),
                  Radio<int>(
                    value: 3,
                    groupValue: _priority,
                    onChanged: (value) => setState(() => _priority = value!),
                  ),
                  Text('Cao'),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _tagController,
                      decoration: InputDecoration(
                        labelText: 'Thêm nhãn',
                        border: OutlineInputBorder(),
                      ),
                      onFieldSubmitted: (_) => _addTag(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: _addTag,
                  ),
                ],
              ),
              if (_tags.isNotEmpty) ...[
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _tags
                      .map((tag) => Chip(
                    label: Text(tag),
                    onDeleted: () => _removeTag(tag),
                  ))
                      .toList(),
                ),
              ],
              SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.color_lens),
                title: Text('Màu sắc'),
                trailing: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _color != null ? Color(int.parse(_color!.replaceFirst('#', '0xff'))) : null,
                    border: Border.all(),
                    shape: BoxShape.circle,
                  ),
                ),
                onTap: _showColorPicker,
              ),
            ],
          ),
        ),
      ),
    );
  }
}