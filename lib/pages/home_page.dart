import 'package:flutter/material.dart';
import 'package:notibuku/models/note.dart';
import 'package:notibuku/pages/details_page.dart';
import 'package:notibuku/services/note_services.dart';
import 'package:notibuku/services/sizefactor.dart';
import 'package:notibuku/widgets/drawer.dart';
import 'package:animated_text_kit2/animated_text_kit2.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:notibuku/widgets/note_card.dart'; // 🔥 ADD THIS IMPORT

class NoteList extends StatefulWidget {
  const NoteList({super.key});

  @override
  State<NoteList> createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  Map<String, List<Note>> groupedNotes = {};

  Future<void> loadNotes() async {
    final notesByDay = await DatabaseService.getNotesGroupedByDay();
    setState(() {
      groupedNotes = notesByDay;
    });
  }

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  void _showNoteDialog(Note? note) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => DetailsPage(note: note)),
    );
    await loadNotes(); // 🔥 ALWAYS REFRESH
  }

  void _deleteNote(int id) async {
    await DatabaseService.deleteNote(id);
    await loadNotes();
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    double sizeFactor = getSizeFactor(context);
    final double titlefSize = sizeFactor * 0.025;
    final screenWidth = Func().screenWidth(context);
    final bool isSmall = screenWidth <= 322;
    final bool isMedium = screenWidth > 322 && screenWidth <= 700;

    return Scaffold(
      drawer: Container(color: Colors.white, child: CustomDrawer()),

      // 🔥 CORRECT "New Note" BUTTON (unchanged)
      bottomSheet: InkWell(
        onTap: () => _showNoteDialog(null),
        child: Container(
          margin: EdgeInsets.all(10),
          width: Func().screenWidth(context) * 0.7,
          decoration: ShapeDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 153, 123, 16),
                Color.fromARGB(255, 94, 3, 110),
                Colors.purple,
                Color.fromARGB(255, 241, 153, 147),
                Colors.blue,
              ],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'New Note',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),

      appBar: AppBar(
        title: Row(
          children: [
            FaIcon(FontAwesomeIcons.bookOpen, color: Colors.amber[200]),
            SizedBox(width: 12),
            AnimatedTextKit2.Rainbow(
              repeat: true,
              text: 'NotiBuku',
              duration: Duration(seconds: 10),
              textStyle: TextStyle(
                fontSize: 25,
                color: Color.fromARGB(255, 87, 5, 102),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        titleTextStyle: TextStyle(
          fontFamily: 'ALGER',
          fontSize: 30,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),

      body: groupedNotes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedTextKit2.MatrixFall(
                    delay: Duration(seconds: 2),
                    repeat: true,
                    text: 'Welcome to',
                    duration: Duration(seconds: 3),
                    textStyle: TextStyle(
                      fontSize: 40,
                      color: Color.fromARGB(255, 87, 5, 102),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Noti',
                          style: TextStyle(
                            fontSize: 40,
                            color: Color.fromARGB(255, 87, 5, 102),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: 'Buku',
                          style: TextStyle(
                            fontSize: 40,
                            color: Color.fromARGB(255, 230, 139, 79),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: groupedNotes.length,
              itemBuilder: (context, groupIndex) {
                final dayKeys = groupedNotes.keys.toList();
                final dayKey = dayKeys[groupIndex];
                final dayNotes = groupedNotes[dayKey]!;

                final dayDate = DateTime.parse(dayKey);
                final formattedDay =
                    dayDate.day == DateTime.now().day &&
                        dayDate.month == DateTime.now().month &&
                        dayDate.year == DateTime.now().year
                    ? 'Today'
                    : '${dayDate.day} ${_getMonthName(dayDate.month)} ${dayDate.year}';

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ExpansionTile(
                    expandedAlignment: Alignment.centerLeft,
                    initiallyExpanded: false,
                    leading: CircleAvatar(
                      radius: sizeFactor * 0.03,
                      backgroundColor: Color.fromARGB(255, 244, 235, 220),
                      child: Text(
                        dayNotes.length.toString().padLeft(2, '0'),
                        style: TextStyle(
                          fontSize: titlefSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple[900],
                        ),
                      ),
                    ),
                    title: Center(
                      child: AnimatedTextKit2.Rainbow(
                        repeat: true,
                        text: formattedDay,
                        duration: Duration(seconds: 2),
                        textStyle: TextStyle(
                          fontSize: 18,
                          color: Color.fromARGB(255, 87, 5, 102),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    childrenPadding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                    tilePadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    backgroundColor: Color.fromARGB(255, 244, 235, 220),
                    collapsedBackgroundColor: const Color.fromARGB(
                      0,
                      58,
                      11,
                      11,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      side: BorderSide(
                        color: Color.fromARGB(255, 1, 72, 45),
                        width: 1,
                      ),
                    ),
                    //  note mapping section in ExpansionTile children:
                    children: [
                      ...dayNotes.map((note) {
                        double? cardHeight = isSmall
                            ? screenWidth *
                                  0.2 // Reduced sizes
                            : isMedium
                            ? screenWidth *
                                  0.14 // Reduced sizes
                            : screenWidth * 0.1;
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 2),
                          child: SizedBox(
                            height: cardHeight,
                            child: Dismissible(
                              key: Key(note.id.toString()),
                              confirmDismiss: (direction) async {
                                final bool? confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Row(
                                      children: [
                                        Icon(
                                          Icons.warning,
                                          color: Colors.red[900],
                                          size: 30,
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: 'Delete ',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: '${note.title}?',
                                                  style: TextStyle(
                                                    color: Colors.blue,
                                                  ),
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
                                            Navigator.of(context).pop(false),
                                        child: Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        style: TextButton.styleFrom(
                                          backgroundColor: Colors.pink,
                                        ),
                                        child: Text(
                                          'Yes',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                                return confirmed == true;
                              },
                              onDismissed: (direction) async {
                                _deleteNote(note.id!);
                              },
                              background: SizedBox(
                                height: cardHeight,
                                child: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              // 🔥 INTEGRATE NoteCard - KEEPS YOUR LAYOUT!
                              child: NoteCard(
                                note: note,
                                onTap: () => _showNoteDialog(note),
                                onLongPress: () => _deleteNote(
                                  note.id!,
                                ), // For delete confirmation
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
