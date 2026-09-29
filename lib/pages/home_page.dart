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
    CategoryContainer('Personal', Icons.person, Colors.blue, 1),
    CategoryContainer('Business', Icons.business, Colors.green, 1),
    CategoryContainer('To-Do', Icons.check_circle_outline, Colors.orange, 1),
    CategoryContainer('Learning', Icons.school, Colors.purple, 1),
    CategoryContainer('Ideas', Icons.lightbulb_outline, Colors.amber, 1),
    CategoryContainer('Urgent', Icons.warning_amber, Colors.red, 1),
    CategoryContainer('All Notes', Icons.menu_book, Colors.deepPurple, 0),
  ];

  // ================================================================
  // LOAD NOTES
  // ================================================================

  Future<void> loadNotes() async {
    final notesByDay = await DatabaseService.getNotesGroupedByDay();
    final allNotesList = await DatabaseService.getAllNotes();

    if (!mounted) return;

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

  // ================================================================
  // FILTERS
  // ================================================================

  void _applyFilters() {
    List<Note> filteredNotes = List<Note>.from(allNotes);

    // Category filter
    if (selectedCategory != null &&
        selectedCategory!.isNotEmpty &&
        selectedCategory != 'All Notes') {
      filteredNotes = filteredNotes
          .where((note) => note.category == selectedCategory)
          .toList();
    }

    // Date filter
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

    // Search filter
    if (searchText.isNotEmpty) {
      final query = searchText.toLowerCase();

      filteredNotes = filteredNotes.where((note) {
        return note.title.toLowerCase().contains(query) ||
            note.content.toLowerCase().contains(query);
      }).toList();
    }

    // Group filtered notes by day
    final Map<String, List<Note>> grouped = {};

    for (final note in filteredNotes) {
      final dayKey = note.createdAt.substring(0, 10);

      grouped.putIfAbsent(dayKey, () => []).add(note);
    }

    // Sort newest date first
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) => DateTime.parse(b).compareTo(DateTime.parse(a)));

    if (!mounted) return;

    setState(() {
      filteredGroupedNotes = {for (final key in sortedKeys) key: grouped[key]!};
    });
  }

  void _onSearchChanged(String value) {
    searchText = value;

    if (value.isEmpty) {
      selectedDate = null;
    }

    _applyFilters();
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

  // ================================================================
  // DATE
  // ================================================================

  Future<void> _showDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate == null) return;

    selectedDate = pickedDate;

    _applyFilters();
  }

  void _clearDateOnly() {
    selectedDate = null;
    _applyFilters();
  }

  // ================================================================
  // CATEGORY
  // ================================================================

  void _selectCategory(String? category) {
    setState(() {
      selectedCategory = category;
      showCategoryView = false;
    });

    _applyFilters();
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

  // ================================================================
  // INITIALIZATION
  // ================================================================

  @override
  void initState() {
    super.initState();

    loadNotes();

    _searchController.addListener(() {
      _onSearchChanged(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ================================================================
  // NOTE ACTIONS
  // ================================================================

  Future<void> _showNoteDialog(Note? note) async {
    final result = await Navigator.of(context).push<Note>(
      MaterialPageRoute(builder: (context) => DetailsPage(note: note)),
    );

    if (result != null) {
      await DatabaseService.updateNote(result);
    }

    await loadNotes();
  }

  Future<void> _deleteNote(int id) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Note?'),
          content: const Text(
            'Are you sure you want to delete this note? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('DELETE', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await DatabaseService.deleteNote(id);
    await loadNotes();
  }

  Future<void> _toggleTodoComplete(Note note) async {
    final updatedNote = Note(
      id: note.id,
      title: note.title,
      content: note.content,
      createdAt: note.createdAt,
      category: note.category,
      isCompleted: !(note.isCompleted ?? false),

      color: note.color,
      titleTextColor: note.titleTextColor,
      contentTextColor: note.contentTextColor,
      titleFontFamily: note.titleFontFamily,
      contentFontFamily: note.contentFontFamily,
      titleFontSize: note.titleFontSize,
      contentFontSize: note.contentFontSize,
    );

    await DatabaseService.updateNote(updatedNote);

    if (!mounted) return;

    setState(() {
      allNotes = [
        for (final n in allNotes) n.id == updatedNote.id ? updatedNote : n,
      ];
    });

    await loadNotes();
    _applyFilters();
  }

  // ================================================================
  // CATEGORY COUNT
  // ================================================================

  int _getCategoryNoteCount(String category) {
    if (category == 'All Notes') {
      return allNotes.length;
    }

    return allNotes.where((note) => note.category == category).length;
  }

  // ================================================================
  // BADGE
  // ================================================================

  Widget _buildBadge() {
    return Positioned(
      right: 4,
      top: 4,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(6),
        ),
        constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
        child: const Text(
          '●',
          style: TextStyle(color: Colors.white, fontSize: 8),
        ),
      ),
    );
  }

  // ================================================================
  // MAIN BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    final double sizeFactor = getSizeFactor(context);

    final double titlefSize = sizeFactor * 0.025;

    final double screenWidth = Func().screenWidth(context);

    final bool isSmall = screenWidth <= 322;

    final bool isMedium = screenWidth > 322 && screenWidth <= 700;

    // ==============================================================
    // CATEGORY VIEW
    // ==============================================================

    if (showCategoryView) {
      return Scaffold(
        drawer: Container(color: Colors.white, child: CustomDrawer()),
        appBar: _buildCategoryAppBar(),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;

            // Landscape
            final bool isLandscape = width > height;

            // Choose columns based primarily on available width.
            final int crossAxisCount;

            if (isLandscape) {
              if (width >= 1000) {
                crossAxisCount = 5;
              } else if (width >= 700) {
                crossAxisCount = 4;
              } else {
                crossAxisCount = 3;
              }
            } else {
              if (width <= 322) {
                crossAxisCount = 2;
              } else {
                crossAxisCount = 3;
              }
            }

            // Smaller spacing in landscape so the cards have
            // enough room vertically and horizontally.
            final double horizontalPadding = isLandscape ? 24 : 20;

            final double spacing = isLandscape ? 14 : 20;

            return CustomScrollView(
              slivers: [
                // --------------------------------------------------------
                // CATEGORY HEADER
                // --------------------------------------------------------
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(isLandscape ? 16 : 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Choose Category',
                          style: TextStyle(
                            fontSize: isLandscape ? 27 : 28,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 87, 5, 102),
                          ),
                        ),

                        SizedBox(height: isLandscape ? 8 : 20),

                        Text(
                          'Tap to view notes',
                          style: TextStyle(
                            fontSize: isLandscape ? 14 : 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // --------------------------------------------------------
                // CATEGORY GRID
                // --------------------------------------------------------
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: isLandscape ? 8 : 10,
                  ),

                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,

                      // Landscape cards are wider and shorter.
                      childAspectRatio: isLandscape ? 1.03 : 0.85,

                      crossAxisSpacing: spacing,
                      mainAxisSpacing: spacing,
                    ),

                    delegate: SliverChildBuilderDelegate((context, index) {
                      final category = categories[index];

                      final noteCount = _getCategoryNoteCount(category.name);

                      return _buildCategoryCard(
                        category,
                        noteCount,
                        isLandscape,
                      );
                    }, childCount: categories.length),
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    // ==============================================================
    // NOTES VIEW
    // ==============================================================

    final displayNotes =
        searchText.isEmpty && selectedDate == null && selectedCategory == null
        ? groupedNotes
        : filteredGroupedNotes;

    final bool hasActiveFilter =
        searchText.isNotEmpty ||
        selectedDate != null ||
        selectedCategory != null;

    bool isLandscape = screenWidth > MediaQuery.of(context).size.height;
    return Scaffold(
      drawer: Container(color: Colors.white, child: CustomDrawer()),

      // ------------------------------------------------------------
      // NEW NOTE BUTTON
      // ------------------------------------------------------------
      bottomSheet: NewNoteButton(
        screenWidth: screenWidth,
        defaultCategory: selectedCategory,
        onRefresh: loadNotes,
      ),

      // ------------------------------------------------------------
      // APP BAR
      // ------------------------------------------------------------
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _backToCategories,
        ),

        title: Row(
          children: [
            Icon(
              Icons.label_important_outline,
              color: Colors.amber[200],
              size: 20,
            ),

            const SizedBox(width: 8),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedCategory ?? 'Notes',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                if (selectedCategory != null && selectedCategory != 'All Notes')
                  Text(
                    '${_getCategoryNoteCount(selectedCategory!)} notes',
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
              ],
            ),
          ],
        ),

        titleTextStyle: const TextStyle(
          fontFamily: 'ALGER',
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),

        actions: [
          // ----------------------------------------------------------
          // CLEAR FILTERS
          // ----------------------------------------------------------
          if (hasActiveFilter)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _clearAllFilters,
            ),

          // ----------------------------------------------------------
          // SEARCH
          // ----------------------------------------------------------
          isSearching
              ? SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search notes...',
                      hintStyle: const TextStyle(color: Colors.white60),
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        color: Colors.white70,
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();

                          setState(() {
                            isSearching = false;
                          });
                        },
                      ),
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      isSearching = true;
                    });
                  },
                ),

          // ----------------------------------------------------------
          // DATE FILTER
          // ----------------------------------------------------------
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.filter_list),
                if (selectedDate != null) _buildBadge(),
              ],
            ),
            onPressed: _showDatePicker,
          ),
        ],
      ),

      // ------------------------------------------------------------
      // NOTES BODY
      // ------------------------------------------------------------
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
              isLandscape,
            ),
    );
  }

  // ================================================================
  // CATEGORY APP BAR
  // ================================================================

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

          const SizedBox(width: 8),

          Expanded(
            child: AnimatedTextKit2.Rainbow(
              repeat: true,
              text: 'NotiBuku',
              duration: const Duration(seconds: 10),
              textStyle: const TextStyle(
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
        isSearching
            ? SizedBox(
                width: 150,
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(top: 12),
                    hintText: 'Search notes...',
                    hintStyle: const TextStyle(color: Colors.white60),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      color: Colors.white,
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();

                        setState(() {
                          isSearching = false;
                        });
                      },
                    ),
                  ),
                ),
              )
            : IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  setState(() {
                    isSearching = true;
                  });
                },
              ),
      ],
    );
  }

  // ================================================================
  // CATEGORY CARD
  //
  // IMPORTANT:
  // No fixed height here.
  //
  // SliverGrid determines the outer card dimensions.
  // Scale is only used for the contents.
  // ================================================================

  Widget _buildCategoryCard(
    CategoryContainer category,
    int noteCount,
    bool isLandscape,
  ) {
    final double cardWidth = isLandscape ? 100 : 120;

    final double iconContainerSize = isLandscape ? 34 : 40;
    final double iconSize = isLandscape ? 20 : 22;
    final double titleSize = isLandscape ? 13 : 14;
    final double countSize = isLandscape ? 10 : 11;

    return GestureDetector(
      onTap: () => _selectCategory(category.name),

      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: cardWidth),

          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),

            width: cardWidth,

            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  category.color.withValues(alpha: 0.10),
                  category.color.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),

              borderRadius: BorderRadius.circular(16),

              border: Border.all(
                color: category.color.withValues(alpha: 0.30),
                width: 1.5,
              ),

              boxShadow: [
                BoxShadow(
                  color: category.color.withValues(alpha: 0.20),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),

            child: Padding(
              padding: EdgeInsets.all(isLandscape ? 2 : 4),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Container(
                    alignment: Alignment.center,

                    width: iconContainerSize,
                    height: iconContainerSize,

                    decoration: BoxDecoration(
                      color: category.color.withValues(alpha: 0.20),

                      shape: BoxShape.circle,

                      border: Border.all(
                        color: category.color.withValues(alpha: 0.40),
                        width: 1.5,
                      ),
                    ),

                    child: Icon(
                      category.icon,
                      size: iconSize,
                      color: category.color,
                    ),
                  ),

                  SizedBox(height: isLandscape ? 4 : 6),

                  Text(
                    category.name,

                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                      color: category.color,
                      height: 1.1,
                    ),

                    textAlign: TextAlign.center,

                    maxLines: 1,

                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: isLandscape ? 3 : 5),

                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: category.color.withValues(alpha: 0.20),

                      shape: BoxShape.circle,

                      border: Border.all(
                        color: category.color.withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),

                    child: Text(
                      '$noteCount',

                      style: TextStyle(
                        fontSize: countSize,
                        color: category.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================================================================
  // NOTES LIST
  // ================================================================

  Widget _buildNotesList(
    Map<String, List<Note>> displayNotes,
    double sizeFactor,
    double titlefSize,
    bool isSmall,
    bool isMedium,
    double screenWidth,
    bool hasActiveFilter,
    bool isLandscape,
  ) {
    return Column(
      children: [
        if (hasActiveFilter)
          Container(
            width: double.infinity,

            padding: EdgeInsets.symmetric(
              horizontal: isLandscape ? 16 : 8,
              vertical: isLandscape ? 4 : 8,
            ),

            child: Wrap(
              spacing: isLandscape ? 6 : 8,
              runSpacing: isLandscape ? 4 : 8,

              children: [
                if (searchText.isNotEmpty)
                  Chip(
                    label: Text(
                      'Search: $searchText',
                      style: TextStyle(fontSize: isLandscape ? 12 : 14),
                    ),

                    visualDensity: isLandscape
                        ? const VisualDensity(horizontal: -2, vertical: -2)
                        : VisualDensity.standard,

                    onDeleted: () {
                      searchText = '';

                      _searchController.clear();

                      _applyFilters();
                    },

                    deleteIcon: Icon(Icons.close, size: isLandscape ? 16 : 18),
                  ),

                if (selectedDate != null)
                  Chip(
                    label: Text(
                      '${selectedDate!.day} '
                      '${getMonthName(selectedDate!.month)}',

                      style: TextStyle(fontSize: isLandscape ? 12 : 14),
                    ),

                    visualDensity: isLandscape
                        ? const VisualDensity(horizontal: -2, vertical: -2)
                        : VisualDensity.standard,

                    onDeleted: _clearDateOnly,

                    deleteIcon: Icon(Icons.close, size: isLandscape ? 16 : 18),
                  ),
              ],
            ),
          ),

        // ------------------------------------------------------------
        // GROUPED NOTES
        // ------------------------------------------------------------
        GroupedNotesList(
          displayNotes: displayNotes,

          onDelete: _deleteNote,

          onTapRegularNote: _showNoteDialog,

          onTapTodoNote: (note) async {
            final result = await showDialog<Note>(
              context: context,

              builder: (dialogContext) => TodoSummaryDialog(note: note),
            );

            if (result != null) {
              await loadNotes();
            }
          },

          onToggleComplete: _toggleTodoComplete,

          onLongPress: (note) => _deleteNote(note.id!),

          screenWidth: screenWidth,

          sizeFactor: sizeFactor,

          titlefSize: titlefSize,

          isSmall: isSmall,

          isMedium: isMedium,

          getMonthName: getMonthName,

          isLandscape: isLandscape,
        ),
      ],
    );
  }
}

// ====================================================================
// CATEGORY MODEL
// ====================================================================

class CategoryContainer {
  final String name;
  final IconData icon;
  final Color color;
  final int defaultCount;

  CategoryContainer(this.name, this.icon, this.color, this.defaultCount);
}
