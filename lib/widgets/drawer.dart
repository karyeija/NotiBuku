import 'package:flutter/material.dart';
import 'package:notibuku/pages/about.dart';
import 'package:notibuku/widgets/styled_text.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  Widget build(BuildContext context) {
    // Define the icons and dimensions
    final aboutIcon = 'assets/images/aboutButton.png';
    var pageHeight = UIHelpers.pageHeight(context);
    var pageWidth = UIHelpers.pageWidth(context);
    return Drawer(
      width: pageWidth * 0.6, // Set the width of the drawer
      backgroundColor: Colors.white,
      child: ListView(
        children: [
          DrawerHeader(
            // padding: EdgeInsets.zero,
            decoration: const BoxDecoration(color: Colors.deepPurple),
            child: Text(
              'Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: pageHeight * 0.06,
              ),
            ),
          ),
          ListTile(
            // tileColor: Colors.amber,
            title: styledText(
              'About',
              fontFamily: 'Tahoma',
              fontSize: pageHeight * 0.04,
            ),
            leading: Image.asset(aboutIcon, height: pageHeight * 0.08),
            onTap: () => showGeneralDialog(
              context: context,
              pageBuilder:
                  (
                    BuildContext context,
                    Animation<double> animation,
                    Animation<double> secondaryAnimation,
                  ) {
                    return AboutPage();
                  },
            ),
          ),
        ],
      ),
    );
  }
}
