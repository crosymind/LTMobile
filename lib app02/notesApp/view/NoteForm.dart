import 'package:flutter/material.dart';
import '../model/note.dart';
import '../db/UserDatabaseHelpers.dart';

class NoteFormScreen extends StatefulWidget {
  final Note? note;

  const NoteFormScreen({Key? key, this.note}) : super(key: key);

  @override
  _NoteFormScreenState createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends State<NoteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();
  final _dbHelper = NoteDatabaseHelper.instance;

  int _priority = 1;
  String? _color;
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _priority = widget.note!.priority;
      _color = widget.note!.color;
      _tags = widget.note!.tags ?? [];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _addTag() {
    if (_tagsController.text.isNotEmpty) {
      setState(() {
        _tags.add(_tagsController.text);
        _tagsController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _saveNote() async {
    if (_formKey.currentState!.validate()) {
      final note = Note(
        id: widget.note?.id,
        title: _titleController.text,
        content: _contentController.text,
        priority: _priority,
        tags: _tags.isNotEmpty ? _tags : null,
        color: _color,
      );

      if (note.id == null) {
        await _dbHelper.insertNote(note);
      } else {
        await _dbHelper.updateNote(note);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Thêm ghi chú' : 'Sửa ghi chú'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Tiêu đề',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tiêu đề';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: 'Nội dung',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập nội dung';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text('Mức độ ưu tiên:'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Radio<int>(
                      value: 1,
                      groupValue: _priority,
                      onChanged: (value) {
                        setState(() {
                          _priority = value!;
                        });
                      },
                    ),
                    const Text('Thấp'),
                    Radio<int>(
                      value: 2,
                      groupValue: _priority,
                      onChanged: (value) {
                        setState(() {
                          _priority = value!;
                        });
                      },
                    ),
                    const Text('Trung bình'),
                    Radio<int>(
                      value: 3,
                      groupValue: _priority,
                      onChanged: (value) {
                        setState(() {
                          _priority = value!;
                        });
                      },
                    ),
                    const Text('Cao'),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Màu sắc:'),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildColorOption('FF0000', Colors.red),
                    _buildColorOption('00FF00', Colors.green),
                    _buildColorOption('0000FF', Colors.blue),
                    _buildColorOption('FFFF00', Colors.yellow),
                    _buildColorOption('FF00FF', Colors.purple),
                    _buildColorOption('00FFFF', Colors.cyan),
                    _buildColorOption('FFFFFF', Colors.white),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Nhãn (tags):'),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _tagsController,
                        decoration: const InputDecoration(
                          labelText: 'Thêm nhãn',
                          border: OutlineInputBorder(),
                        ),
                        onFieldSubmitted: (_) => _addTag(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _addTag,
                    ),
                  ],
                ),
                if (_tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorOption(String colorHex, Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _color = colorHex;
        });
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          border: _color == colorHex
              ? Border.all(color: Colors.black, width: 3)
              : null,
        ),
      ),
    );
  }
}