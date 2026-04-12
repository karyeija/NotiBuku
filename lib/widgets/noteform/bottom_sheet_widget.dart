import 'package:flutter/material.dart';

class NoteBottomSheet extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final VoidCallback onAddTask;

  final bool isSaving;
  final bool isSaveButtonEnabled;
  final bool isChecklistMode; // ✅ NEW

  const NoteBottomSheet({
    super.key,
    required this.onCancel,
    required this.onSave,
    required this.onAddTask,
    required this.isSaving,
    required this.isSaveButtonEnabled,
    required this.isChecklistMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        color: Colors.green,
        boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // CANCEL
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: onCancel,
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),

            // SAVE
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: isSaving || !isSaveButtonEnabled ? null : onSave,
              child: isSaveButtonEnabled
                  ? const Text('Save', style: TextStyle(color: Colors.white))
                  : const Text(
                      'No changes',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
            ),

            if (isChecklistMode)
              ElevatedButton.icon(
                onPressed: onAddTask,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Add Task',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
