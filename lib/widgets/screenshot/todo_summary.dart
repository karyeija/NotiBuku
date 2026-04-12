import 'package:flutter/material.dart';
import 'package:notibuku/forms/note_form_widget.dart';
import 'package:notibuku/models/note.dart';

class TodoSummaryDialog extends StatelessWidget {
  final Note note;

  const TodoSummaryDialog({super.key, required this.note});

  int get pendingTasks => note.todoList.where((t) => !t.isCompleted).length;
  int get totalTasks => note.todoList.length;
  int get completedTasks => totalTasks - pendingTasks;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(note.title, style: TextStyle(fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Task summary
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$pendingTasks/$totalTasks tasks',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$completedTasks completed',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Chip(
                    label: Text('$pendingTasks'),
                    backgroundColor: pendingTasks > 0
                        ? Colors.orange
                        : Colors.green,
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // ✅ Quick task preview (first 4 tasks)
            Expanded(
              child: ListView.builder(
                itemCount: (note.todoList.length).clamp(0, 4),
                itemBuilder: (context, index) {
                  final task = note.todoList[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    color: task.isCompleted ? Colors.grey[100] : null,
                    child: ListTile(
                      dense: true,
                      leading: Checkbox(
                        value: task.isCompleted,
                        onChanged: null,
                      ),
                      title: Text(
                        task.text,
                        style: TextStyle(
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close'),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            Navigator.pop(context);
            // ✅ Open full editor
           final result = await Navigator.push<Note>(
              context,
              MaterialPageRoute(
                builder: (context) => NoteFormWidget(note: note),
              ),
            );

            if (result != null && context.mounted) {
              Navigator.pop(context, result); // 🔥 bubble update up
            }

            if (result != null && context.mounted) {
              Navigator.pop(context, result); // 🔥 bubble update up
            }
          },
          icon: Icon(Icons.edit),
          label: Text('Edit Tasks'),
        ),
      ],
    );
  }
}
