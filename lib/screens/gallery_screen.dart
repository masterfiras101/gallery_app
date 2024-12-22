import 'package:flutter/material.dart';
import 'home_screen.dart'; 
import 'settings_screen.dart'; 
import 'gallery_content_screen.dart';
import 'videos_screen.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_bar.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const VideosScreen(),
    const GalleryContentScreen(), 
    const SettingsScreen(), 
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'المعرض'),
      body: 
          
      _screens[_currentIndex], 
      bottomNavigationBar: CustomBottomBar(
        onTap: _onTabTapped, 
        currentIndex: _currentIndex, 
      ),
    );
  }
}
