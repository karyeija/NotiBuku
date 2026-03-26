import 'package:flutter/material.dart';

class CategoryPicker extends StatefulWidget {
  final String? currentCategory;
  final Function(String?) onChanged;

  const CategoryPicker({
    super.key,
    required this.currentCategory,
    required this.onChanged,
  });

  @override
  State<CategoryPicker> createState() => _CategoryPickerState();
}

class _CategoryPickerState extends State<CategoryPicker> {
  final List<Category> categories = [
    Category('Personal', Icons.person, Colors.blue),
    Category('Business', Icons.business, Colors.green),
    Category('To-Do', Icons.check_circle_outline, Colors.orange),
    Category('Learning', Icons.school, Colors.purple),
    Category('Ideas', Icons.lightbulb_outline, Colors.amber),
    Category('Urgent', Icons.warning_amber, Colors.red),
  ];

  @override
  Widget build(BuildContext context) {
    // final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = widget.currentCategory == cat.name;

          return GestureDetector(
            onTap: () => widget.onChanged(cat.name),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? cat.color.withValues(alpha: .2)
                    : Colors.grey[50],
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected ? cat.color : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(cat.icon, size: 18, color: cat.color),
                  SizedBox(width: 6),
                  Text(
                    cat.name,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: cat.color,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class Category {
  final String name;
  final IconData icon;
  final Color color;

  Category(this.name, this.icon, this.color);
}
