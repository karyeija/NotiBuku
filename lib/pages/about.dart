import 'package:flutter/material.dart';
import 'package:notibuku/widgets/styled_text.dart';
import 'package:url_launcher/url_launcher.dart';

const String appName = 'NotiBuku'; //the app name
const String appDescription =
    'A handy digital note taking application'; //a short description
const String appVersion = '1.0.0'; //the app version eg 1.0.0
const String developerName = 'Karyeija Felex'; //Your name
const String developerEmail = 'karyeijafelex@gmail.com'; //Your email
const String logoPath = 'assets/icons/logo.png'; //path/to/your/icon

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  void launchEmail(String email) {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    launchUrl(emailUri);
  }

  @override
  Widget build(BuildContext context) {
    var pageWidth = UIHelpers.pageWidth(context);
    return AboutDialog(
      applicationName: appName,
      applicationVersion: appVersion,
      applicationIcon: Image(
        image: AssetImage(logoPath),
        width: pageWidth * 0.1,
        height: pageWidth * 0.1,
      ),
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Proprietory License',
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Developed by: \n$developerName',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
        ),
        GestureDetector(
          onTap: () => launchEmail(developerEmail),
          child: Text(
            developerEmail,
            style: TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
