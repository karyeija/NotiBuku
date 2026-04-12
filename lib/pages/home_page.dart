import 'package:flutter/material.dart';
import 'package:notibuku/models/note.dart';
import 'package:notibuku/pages/details_page.dart';
import 'package:notibuku/services/note_services.dart';
import 'package:notibuku/services/sizefactor.dart';
import 'package:notibuku/utils/helpers.dart';
import 'package:notibuku/widgets/drawer.dart';
import 'package:animated_text_kit2/animated_text_kit2.dart';
import 'package:notibuku/widgets/new_note_button_widget.dart';
import 'package:notibuku/widgets/notes/grouped_notes_list_widget.dart';
import 'package:notibuku/widgets/screenshot/todo_summary.dart';

class NoteList extends StatefulWidget {
  const NoteList({super.key});

  @override
  State<NoteList> createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  Map<String, List<Note>> groupedNotes = {};
  Map<String, List<Note>> filteredGroupedNotes = {};
  List<Note> allNotes = [];
  String searchText = '';
  DateTime? selectedDate;
  String? selectedCategory;
  bool isSearching = false;
  bool showCategoryView = true;
  final TextEditingController _searchController = TextEditingController();

  final List<CategoryContainer> categories = [
    CategoryContainer('Personal', Icons.person, Colors.blue, 12),
    CategoryContainer('Business', Icons.business, Colors.green, 8),
    CategoryContainer('To-Do', Icons.check_circle_outline, Colors.orange, 15),
    CategoryContainer('Learning', Icons.school, Colors.purple, 6),
    CategoryContainer('Ideas', Icons.lightbulb_outline, Colors.amber, 4),
    CategoryContainer('Urgent', Icons.warning_amber, Colors.red, 2),
    CategoryContainer('All Notes', Icons.menu_book, Colors.deepPurple, 0),
  ];

  Future<void> loadNotes() async {
    final notesByDay = await DatabaseService.getNotesGroupedByDay();
    final allNotesList = await DatabaseService.getAllNotes();

    setState(() {
      groupedNotes = notesByDay;
      allNotes = allNotesList;
      filteredGroupedNotes = notesByDay;
      searchText = '';
      selectedDate = null;
      selectedCategory = null;
      _searchController.clear();
      isSearching = false;
    });
  }

  void _applyFilters() {
    List<Note> filteredNotes = allNotes;

    if (selectedCategory != null &&
        selectedCategory!.isNotEmpty &&
        selectedCategory != 'All Notes') {
      filteredNotes = filteredNotes
          .where((note) => note.category == selectedCategory)
          .toList();
    }

    if (selectedDate != null) {
      filteredNotes = filteredNotes.where((note) {
        final noteDate = DateTime.parse(note.createdAt);
        final noteDateOnly = DateTime(
          noteDate.year,
          noteDate.month,
          noteDate.day,
        );
        final selectedDateOnly = DateTime(
          selectedDate!.year,
          selectedDate!.month,
          selectedDate!.day,
        );
        return noteDateOnly.isAtSameMomentAs(selectedDateOnly);
      }).toList();
    }

    if (searchText.isNotEmpty) {
      filteredNotes = filteredNotes.where((note) {
        return note.title.toLowerCase().contains(searchText.toLowerCase()) ||
            note.content.toLowerCase().contains(searchText.toLowerCase());
      }).toList();
    }

    final Map<String, List<Note>> grouped = {};
    for (var note in filteredNotes) {
      final dayKey = note.createdAt.substring(0, 10);
      grouped.putIfAbsent(dayKey, () => []).add(note);
    }

    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) => DateTime.parse(b).compareTo(DateTime.parse(a)));

    setState(() {
      filteredGroupedNotes = {for (var key in sortedKeys) key: grouped[key]!};
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      searchText = value;
      if (value.isEmpty) selectedDate = null;
      _applyFilters();
    });
  }

  void _clearAllFilters() {
    setState(() {
      searchText = '';
      selectedDate = null;
      selectedCategory = null;
      _searchController.clear();
      filteredGroupedNotes = groupedNotes;
      isSearching = false;
    });
  }

  void _showDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        _applyFilters();
      });
    }
  }

  void _clearDateOnly() {
    setState(() {
      selectedDate = null;
      _applyFilters();
    });
  }

  void _selectCategory(String? category) {
    setState(() {
      selectedCategory = category;
      showCategoryView = false;
      _applyFilters();
    });
  }

  void _backToCategories() {
    setState(() {
      selectedCategory = null;
      searchText = '';
      selectedDate = null;
      _searchController.clear();
      filteredGroupedNotes = groupedNotes;
      showCategoryView = true;
      isSearching = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadNotes();
    _searchController.addListener(
      () => _onSearchChanged(_searchController.text),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showNoteDialog(Note? note) async {
    final result = await Navigator.of(context).push<Note>(
      MaterialPageRoute(builder: (context) => DetailsPage(note: note)),
    );

    if (result != null) {
      // IMPORTANT: update DB OR local list immediately
      await DatabaseService.updateNote(result);
    }

    await loadNotes(); // refresh UI properly
  }

  void _deleteNote(int id) async {
    await DatabaseService.deleteNote(id);
    await loadNotes();
  }

  Future<void> _toggleTodoComplete(Note note) async {
    // Create updated note
    final updatedNote = Note(
      id: note.id,
      title: note.title,
      content: note.content,
      createdAt: note.createdAt,
      category: note.category,
      isCompleted: !(note.isCompleted ?? false), // Toggle
      // Copy other properties
      color: note.color,
      titleTextColor: note.titleTextColor,
      contentTextColor: note.contentTextColor,
      titleFontFamily: note.titleFontFamily,
      contentFontFamily: note.contentFontFamily,
      titleFontSize: note.titleFontSize,
      contentFontSize: note.contentFontSize,
    );

    await DatabaseService.updateNote(updatedNote);

    setState(() {
      allNotes = [
        for (final n in allNotes)
          if (n.id == updatedNote.id) updatedNote else n,
      ];
    });
    await loadNotes();
    _applyFilters();
  }

  int _getCategoryNoteCount(String category) {
    if (category == 'All Notes') return allNotes.length;
    return allNotes.where((note) => note.category == category).length;
  }

  Widget _buildBadge() {
    return Positioned(
      right: 4,
      top: 4,
      child: Container(
        padding: EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(6),
        ),
        constraints: BoxConstraints(minWidth: 12, minHeight: 12),
        child: Text('●', style: TextStyle(color: Colors.white, fontSize: 8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double sizeFactor = getSizeFactor(context);
    final double titlefSize = sizeFactor * 0.025; //  FIXED: Now defined
    final screenWidth = Func().screenWidth(context);
    final bool isSmall = screenWidth <= 322;
    final bool isMedium = screenWidth > 322 && screenWidth <= 700;

    if (showCategoryView) {
      return Scaffold(
        drawer: Container(color: Colors.white, child: CustomDrawer()),
        // bottomSheet: _buildBottomSheet(screenWidth),
        appBar: _buildCategoryAppBar(),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose Category',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 87, 5, 102),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Tap to view notes',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isSmall ? 2 : 3,
                  childAspectRatio: 0.85, //  CHANGED: 1.2→0.85 (taller cards)
                  crossAxisSpacing: 20, //  BIGGER gaps: 15→20
                  mainAxisSpacing: 20,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final category = categories[index];
                  final noteCount = _getCategoryNoteCount(category.name);
                  return _buildCategoryCard(category, noteCount);
                }, childCount: categories.length),
              ),
            ),
          ],
        ),
      );
    }

    final displayNotes =
        searchText.isEmpty && selectedDate == null && selectedCategory == null
        ? groupedNotes
        : filteredGroupedNotes;
    final hasActiveFilter =
        searchText.isNotEmpty ||
        selectedDate != null ||
        selectedCategory != null;

    return Scaffold(
      drawer: Container(color: Colors.white, child: CustomDrawer()),
      // In NoteList build() method:
      bottomSheet: NewNoteButton(
        screenWidth: screenWidth,
        defaultCategory: selectedCategory,
        onRefresh: loadNotes, // ← Your refresh method
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: _backToCategories,
        ),
        title: Row(
          children: [
            Icon(
              Icons.label_important_outline,
              color: Colors.amber[200],
              size: 20,
            ),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedCategory ?? 'Notes',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (selectedCategory != null && selectedCategory != 'All Notes')
                  Text(
                    '${_getCategoryNoteCount(selectedCategory!)} notes',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
              ],
            ),
          ],
        ),
        titleTextStyle: TextStyle(
          fontFamily: 'ALGER',
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          if (hasActiveFilter)
            IconButton(
              icon: Icon(Icons.clear_all),
              onPressed: _clearAllFilters,
            ),

          //  FIXED SEARCH:
          isSearching
              ? SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search notes...',
                      hintStyle: TextStyle(color: Colors.white60),
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        color: Colors.white70,
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => isSearching = false);
                        },
                      ),
                    ),
                  ),
                )
              : IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => setState(() => isSearching = true),
                ),

          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.filter_list),
                if (selectedDate != null) _buildBadge(),
              ],
            ),
            onPressed: _showDatePicker,
          ),
        ],
      ),
      body: displayNotes.isEmpty
          ? Center(
              child: Text(
                'No notes found',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            )
          : _buildNotesList(
              displayNotes,
              sizeFactor,
              titlefSize,
              isSmall,
              isMedium,
              screenWidth,
              hasActiveFilter,
            ),
    );
  }

  AppBar _buildCategoryAppBar() {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Icon(
            Icons.menu_book_sharp,
            color: Colors.amber[200],
            size: isSearching ? 20 : 30,
          ),
          SizedBox(width: 8),
          Expanded(
            child: AnimatedTextKit2.Rainbow(
              repeat: true,
              text: 'NotiBuku',
              duration: Duration(seconds: 10),
              textStyle: TextStyle(
                // fontSize: 22,
                color: Color.fromARGB(255, 87, 5, 102),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      titleTextStyle: TextStyle(
        fontFamily: 'ALGER',
        fontSize: isSearching ? 18 : 30,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      actions: [
        // Same search logic as list view!
        isSearching
            ? SizedBox(
                width: 150,
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(top: 12),
                    hintText: 'Search notes...',
                    hintStyle: TextStyle(color: Colors.white60),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      color: Colors.white,
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => isSearching = false);
                      },
                    ),
                  ),
                ),
              )
            : IconButton(
                icon: Icon(Icons.search),
                onPressed: () => setState(() => isSearching = true),
              ),
      ],
    );
  }

  Widget _buildCategoryCard(CategoryContainer category, int noteCount) {
    return GestureDetector(
      onTap: () => _selectCategory(category.name),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              category.color.withValues(alpha: 0.1),
              category.color.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: category.color.withValues(alpha: 0.3),
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: category.color.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Padding(
          //  FIXED: Use Padding instead of Container
          padding: EdgeInsets.all(12), //  REDUCED: 16→12 (fits 72.8px height)
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                alignment: Alignment.center,
                height: 40, //  REDUCED: 48→40 (fits tight space)
                width: 40, //  REDUCED: 48→40
                padding: EdgeInsets.only(top: 6), //  REDUCED: 8→6
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: category.color.withValues(alpha: 0.4),
                    width: 1.5, //  THINNER: 2→1.5
                  ),
                ),
                child: Icon(
                  category.icon,
                  size: 28, //  REDUCED: 32→28
                  color: category.color,
                ),
              ),
              SizedBox(height: 6), //  REDUCED: 8→6
              Flexible(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2), //  REDUCED: 4→2
                  child: Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 14, //  REDUCED: 16→14
                      fontWeight: FontWeight.bold,
                      color: category.color,
                      height: 1.1, //  TIGHTER: 1.2→1.1
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1, //  FIXED: 2→1 (critical for space)
                  ),
                ),
              ),
              SizedBox(height: 2), //  REDUCED: 4→2
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 2,
                ), //  TIGHTER
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: category.color.withValues(alpha: 0.1),
                    width: 1.5, //  THINNER: 2→1.5
                  ),
                ),
                child: Text(
                  '$noteCount',
                  style: TextStyle(
                    fontSize: 10, //  REDUCED: 14→12
                    color: category.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotesList(
    Map<String, List<Note>> displayNotes,
    double sizeFactor,
    double titlefSize,
    bool isSmall,
    bool isMedium,
    double screenWidth,
    bool hasActiveFilter,
  ) {
    return Column(
      children: [
        if (hasActiveFilter)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(8),
            child: Wrap(
              spacing: 8,
              children: [
                if (searchText.isNotEmpty)
                  Chip(
                    label: Text('Search: $searchText'),
                    onDeleted: () {
                      setState(() {
                        searchText = '';
                        _searchController.clear();
                        _applyFilters();
                      });
                    },
                    deleteIcon: Icon(Icons.close, size: 18),
                  ),
                if (selectedDate != null)
                  Chip(
                    label: Text(
                      '${selectedDate!.day} ${getMonthName(selectedDate!.month)}',
                    ),
                    onDeleted: _clearDateOnly,
                    deleteIcon: Icon(Icons.close, size: 18),
                  ),
              ],
            ),
          ),
        GroupedNotesList(
          displayNotes: displayNotes,
          onDelete: _deleteNote,
          // ✅ SPLIT onTap into two callbacks
          onTapRegularNote: _showNoteDialog, // Regular notes → NoteFormWidget
          // In home_page.dart - replace your onTapTodoNote:
          onTapTodoNote: (note) async {
            final result = await showDialog<Note>(
              context: context,
              builder: (dialogContext) => TodoSummaryDialog(note: note),
            );

            if (result != null) {
              await loadNotes(); // 🔥 refresh instantly
            }
          },

          // Quick preview → Edit button → Full NoteFormWidget
          onToggleComplete: _toggleTodoComplete,
          onLongPress: (note) => _deleteNote(note.id!),
          screenWidth: screenWidth,
          sizeFactor: sizeFactor,
          titlefSize: titlefSize,
          isSmall: isSmall,
          isMedium: isMedium,
          getMonthName: getMonthName,
        ),
      ],
    );
  }
}

class CategoryContainer {
  final String name;
  final IconData icon;
  final Color color;
  final int defaultCount;

  CategoryContainer(this.name, this.icon, this.color, this.defaultCount);
}
