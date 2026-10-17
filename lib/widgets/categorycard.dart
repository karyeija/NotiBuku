import 'package:flutter/material.dart';
import 'package:notibuku/pages/home_page.dart';

// Replace this import with the actual location of CategoryContainer.

class NotiBukuCategoryCard extends StatelessWidget {
  final CategoryContainer category;
  final int noteCount;
  final bool isLandscape;
  final VoidCallback onTap;

  const NotiBukuCategoryCard({
    super.key,
    required this.category,
    required this.noteCount,
    required this.isLandscape,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double cardWidth = isLandscape ? 200 : 120;
    final double cardHeight = isLandscape ? 200 : 120;

    final double iconContainerSize = isLandscape ? 34 : 40;
    final double iconSize = isLandscape ? 25 : 22;
    final double titleSize = isLandscape ? 13 : 14;
    final double countSize = isLandscape ? 10 : 11;

    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: cardWidth,
            maxHeight: cardHeight,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: cardWidth,
            height: cardHeight,
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
              padding: EdgeInsets.all(isLandscape ? 2 : 3),
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
                  SizedBox(height: isLandscape ? 3 : 2),
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
}
