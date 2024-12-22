import 'package:flutter/material.dart';
import 'screens/gallery_screen.dart';

void main() => runApp(const GalleryApp());

class GalleryApp extends StatelessWidget {
  const GalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'المعرض الشخصي',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue ,fontFamily:'Cairo'),
      home: const GalleryScreen(),
    );
  }
}
