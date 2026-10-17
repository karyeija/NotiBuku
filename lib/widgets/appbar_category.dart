import 'package:flutter/material.dart';
import 'package:animated_text_kit2/animated_text_kit2.dart';

class NotiBukuCategoryAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final bool isSearching;
  final TextEditingController searchController;
  final VoidCallback onSearchPressed;
  final VoidCallback onClearSearch;

  const NotiBukuCategoryAppBar({
    super.key,
    required this.isSearching,
    required this.searchController,
    required this.onSearchPressed,
    required this.onClearSearch,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;

    final iconSize = isSearching ? (isLandscape ? 30.0 : 22.0) : 30.0;

    final titleFontSize = isSearching ? (isLandscape ? 12.0 : 9.0) : 20.0;

    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Icon(Icons.menu_book_sharp, color: Colors.amber[200], size: iconSize),
          SizedBox(width: isSearching ? 12 : 8),
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
        fontSize: titleFontSize,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      actions: [
        if (isSearching)
          SizedBox(
            width: isLandscape ? 150 : 120,
            child: TextField(
              controller: searchController,
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
                  onPressed: onClearSearch,
                ),
              ),
            ),
          )
        else
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: onSearchPressed,
          ),
      ],
    );
  }
}
