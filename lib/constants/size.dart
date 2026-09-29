import 'package:flutter/material.dart';

class Scale {
  static double getScale(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return screenWidth / screenHeight;
  }

  static const double referenceScale = 0.46;

  static double getScalingFactor(BuildContext context) {
    return getScale(context) / referenceScale;
  }
}

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = Scale.getScalingFactor(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('My Page', style: TextStyle(fontSize: 20 * scale)),
      ),
      body: Padding(
        padding: EdgeInsets.all(16 * scale),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 120 * scale,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12 * scale),
              ),
              child: Center(
                child: Text(
                  'Responsive Container',
                  style: TextStyle(fontSize: 18 * scale),
                ),
              ),
            ),

            SizedBox(height: 20 * scale),

            ElevatedButton(
              onPressed: () {},
              child: Text('Continue', style: TextStyle(fontSize: 16 * scale)),
            ),
          ],
        ),
      ),
    );
  }
}
