import 'package:flutter/material.dart';

class CustomBottomBar extends StatelessWidget {
  final Function(int) onTap;
  final int currentIndex;

  const CustomBottomBar(
      {super.key, required this.onTap, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xff1976d2), Color.fromARGB(174, 255, 76, 225)]),
        // color:  Colors.blue,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Padding(
            padding: const EdgeInsets.all(0),
            child: TextButton(
              style: TextButton.styleFrom(
                // side: BorderSide(color: Color.fromARGB(255, 255, 255, 255), width: 2),
                backgroundColor:
                    currentIndex == 0 ? Colors.white : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                onTap(0);
              },
              child: currentIndex == 0
                  ? const Icon(Icons.folder, color: Colors.black)
                  : const Icon(Icons.folder, color: Colors.white),
            ),
          ),
          // IconButton(
          //   icon: const Icon(Icons.photo_album_rounded, color: Colors.white),
          //   onPressed: () {
          //     onTap(0);
          //   },
          // ),
          Padding(
            padding: const EdgeInsets.all(0),
            child: TextButton(
              style: TextButton.styleFrom(
                // side: BorderSide(color: Color.fromARGB(255, 255, 255, 255), width: 2),
                backgroundColor:
                    currentIndex == 1 ? Colors.white : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                onTap(1);
              },
              child: currentIndex == 1
                  ? const Icon(Icons.video_settings, color: Colors.black)
                  : const Icon(Icons.video_settings, color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(0),
            child: TextButton(
              style: TextButton.styleFrom(
                // side: BorderSide(color: Color.fromARGB(255, 255, 255, 255), width: 2),
                backgroundColor:
                    currentIndex == 2 ? Colors.white : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                onTap(2);
              },
              child: currentIndex == 2
                  ? const Icon(Icons.photo_library, color: Colors.black)
                  : const Icon(Icons.photo_library, color: Colors.white),
            ),
          ),
          //
          Padding(
            padding: const EdgeInsets.all(0),
            child: TextButton(
              style: TextButton.styleFrom(
                // side: BorderSide(color: Color.fromARGB(255, 255, 255, 255), width: 2),
                backgroundColor:
                    currentIndex == 3 ? Colors.white : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                onTap(3);
              },
              child: currentIndex == 3
                  ? const Icon(Icons.settings, color: Colors.black)
                  : const Icon(Icons.settings, color: Colors.white),
            ),
          ),
          // IconButton(
          //   icon: const Icon(Icons.settings, color: Colors.white),
          //   onPressed: () {
          //     onTap(2);
          //   },
          // ),
        ],
      ),
    );
  }
}
