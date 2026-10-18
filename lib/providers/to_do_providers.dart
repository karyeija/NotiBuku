import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notibuku/models/note.dart';
import 'package:notibuku/models/to_do_item.dart';
import 'package:notibuku/services/note_services.dart';

final todoNotesProvider =
    StateNotifierProvider<TodoNotesNotifier, Map<String, Note>>((ref) {
      return TodoNotesNotifier();
    });

class TodoNotesNotifier extends StateNotifier<Map<String, Note>> {
  TodoNotesNotifier() : super({});

  /// ==============================
  /// 📥 LOAD NOTES (INITIAL ONLY)
  /// ==============================
  Future<void> loadNotes() async {
    final notes = await DatabaseService.getAllNotes();

    state = {for (final note in notes) note.id.toString(): note};
  }

  /// ==============================
  /// ➕ ADD NOTE
  /// ==============================
  void addTodoNote(Note note) {
    final id = note.id;

    if (id == null) {
      throw ArgumentError('Cannot add an unsaved note to provider state.');
    }

    state = {...state, id.toString(): note};
  }

  /// ==============================
  /// UPDATE NOTE (NO FULL RELOAD)
  /// ==============================
  void updateTodoNote(Note updatedNote) {
    final id = updatedNote.id;

    if (id == null) {
      throw ArgumentError('Cannot update a note without an ID.');
    }

    state = {...state, id.toString(): updatedNote};
  }

  /// ==============================
  /// DELETE NOTE
  /// ==============================
  Future<void> deleteTodoNote(String noteId) async {
    await DatabaseService.deleteNote(int.parse(noteId));

    final newState = Map<String, Note>.from(state);
    newState.remove(noteId);

    state = newState;
  }

  /// ==============================
  /// GET NOTE BY ID (FAST O(1))
  /// ==============================
  Note? getById(String id) {
    return state[id];
  }

  /// ==============================
  /// ==============================
  Future<void> toggleTodo({
    required String noteId,
    required String todoId,
  }) async {
    final note = state[noteId];
    if (note == null) return;

    final updatedTodos = note.todoList.map((todo) {
      if (todo.id == todoId) {
        return TodoItem(
          id: todo.id,
          text: todo.text,
          isCompleted: !todo.isCompleted,
        );
      }
      return todo;
    }).toList();

    final updatedNote = note.copyWith(todoList: updatedTodos);

    await DatabaseService.updateNote(updatedNote);

    state = {...state, noteId: updatedNote};
  }
}
