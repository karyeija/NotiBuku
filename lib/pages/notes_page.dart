import 'package:flutter/material.dart';
import 'package:notibuku/models/date.dart';
import 'package:notibuku/models/note.dart';
import 'package:notibuku/pages/details_page.dart';
import 'package:notibuku/services/note_services.dart';
import 'package:notibuku/services/sizefactor.dart';
import 'package:notibuku/widgets/drawer.dart';

class NoteList extends StatefulWidget {
  const NoteList({super.key});

  @override
  State<NoteList> createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  List<Note> notes = [];
  Future<void> loadNotes() async {
    final notes = await DatabaseService.getNotes();
    setState(() {
      this.notes = notes;
    });
  }

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  void _showNoteDialog(Note? note) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => DetailsPage(note: note)),
    );

    if (result != null && result) {
      await loadNotes();
    }
  }

  void _deleteNote(int id) async {
    await DatabaseService.deleteNote(id);
    await loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    double sizeFactor = getSizeFactor(context);
    final double titlefSize = sizeFactor * 0.025;
    final double contentfSize = sizeFactor * 0.02;

    return Scaffold(
      drawer: CustomDrawer(),
      floatingActionButton: SizedBox(
        height: sizeFactor * 0.08,
        width: sizeFactor * 0.08,
        child: Center(
          child: InkWell(
            onTap: () {
              _showNoteDialog(null);
            },
            child: Container(
              decoration: ShapeDecoration(
                color: Colors.green[900],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(sizeFactor * 0.08),
                ),
              ),
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: sizeFactor * 0.07,
              ),
            ),
          ),
        ),
      ),

      appBar: AppBar(
        title: Text('NOTES'),
        titleTextStyle: TextStyle(
          fontFamily: 'ALGER',
          fontSize: 30,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: notes.isEmpty
          ? Center(
              child: Text(
                'No Data',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
            )
          : ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                //return the list of notes starting from the most current
                final note = notes.reversed.toList()[index];

                // In NoteFormWidget cancel onPressed:
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: Text('Cancel'),
                );

                // In NoteList build itemBuilder:
                double? cardHeight = sizeFactor * 0.08;
                return SizedBox(
                  height: cardHeight,
                  child: Dismissible(
                    key: Key(note.id.toString()),

                    // This shows a confirmation dialog before dismissing
                    confirmDismiss: (direction) async {
                      final bool? confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Row(
                              children: [
                                Icon(
                                  Icons.warning,
                                  color: Colors.red[900],
                                  size: 30,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Delete ',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                        TextSpan(
                                          text: '${note.title}? ',
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false), // Cancel
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true), // Confirm
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.pink,
                                ),
                                child: const Text(
                                  'Yes',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                      return confirmed == true;
                    },

                    // Runs only if confirmed is true
                    onDismissed: (direction) async {
                      _deleteNote(note.id!);
                      setState(() => notes.removeAt(index));
                      // Optionally show a snackbar or reload notes here
                    },

                    background: SizedBox(
                      height: cardHeight,
                      child: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                    ),

                    child: InkWell(
                      onTap: () {
                        _showNoteDialog(note);
                      },
                      child: SizedBox(
                        height: cardHeight,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 3,
                          ),
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color: const Color.fromARGB(255, 244, 235, 220),
                          ),
                          margin: EdgeInsets.all(4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              //leading widget
                              Container(
                                height: sizeFactor * 0.07,
                                width: sizeFactor * 0.07,
                                decoration: ShapeDecoration(
                                  color: const Color.fromARGB(
                                    255,
                                    247,
                                    242,
                                    242,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      sizeFactor * 0.07,
                                    ),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    note.title.isNotEmpty
                                        ? FormatDate.dayOrToday(note.createdAt)
                                        : '?',
                                    style: TextStyle(
                                      fontSize: contentfSize,
                                      color: Colors.purple[900],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 5),
                              SizedBox(
                                height: cardHeight,

                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    //title widget in the card
                                    SizedBox(
                                      width: sizeFactor * 0.2,
                                      child: Text(
                                        note.title,
                                        style: TextStyle(
                                          color: const Color.fromARGB(
                                            255,
                                            1,
                                            72,
                                            45,
                                          ),
                                          fontSize: titlefSize,
                                          fontStyle: FontStyle.normal,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    //Title in the card
                                    Expanded(
                                      child: SizedBox(
                                        width: sizeFactor * 0.22,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 9.0,
                                          ),
                                          child: Text(
                                            maxLines: 1,
                                            note.content
                                                .split('\n')
                                                .first, // Extract only the first line
                                            style: TextStyle(
                                              color: Colors.black,
                                              // fontSize: 16,
                                              fontSize: contentfSize,
                                              fontStyle: FontStyle.normal,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 20),
                              //Hour in the card
                              Expanded(
                                child: SizedBox(
                                  // width: sizeFactor * 0.1,
                                  child: Text(
                                    FormatDate.hour(note.createdAt),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: contentfSize,
                                      fontFamily: 'Technology',
                                    ),
                                  ),
                                ),
                              ),

                              // Expanded(child: SizedBox()),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
