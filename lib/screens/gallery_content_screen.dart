import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:intl/intl.dart';

class GalleryContentScreen extends StatefulWidget {
  const GalleryContentScreen({super.key});

  @override
  _GalleryContentScreenState createState() => _GalleryContentScreenState();
}

class _GalleryContentScreenState extends State<GalleryContentScreen> {
  List<AssetEntity> _assets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    final PermissionState permission =
        await PhotoManager.requestPermissionExtend();
    if (permission.isAuth) {
      final List<AssetPathEntity> paths =
          await PhotoManager.getAssetPathList(onlyAll: true);

      if (paths.isNotEmpty) {
        final List<AssetEntity> allAssets = [];

        for (final path in paths) {
          final List<AssetEntity> assets =
              await path.getAssetListRange(start: 0, end: 1000);
          allAssets.addAll(assets);
        }

        allAssets.sort((a, b) {
          DateTime aDate = a.createDateTime;
          DateTime bDate = b.createDateTime;
          return bDate.compareTo(aDate); // ترتيب تنازلي حسب التاريخ
        });

        setState(() {
          _assets = allAssets;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      _showPermissionDeniedDialog();
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('طلب الإذن مرفوض'),
          content: const Text('يرجى منح الإذن للوصول إلى بيانات التخزين'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('موافق'),
            ),
          ],
        );
      },
    );
  }

  List<List<AssetEntity>> _groupImagesByDate(List<AssetEntity> assets) {
    Map<String, List<AssetEntity>> groupedImages = {};

    for (var asset in assets) {
      String date = DateFormat('yyyy-MM-dd').format(asset.createDateTime);
      if (!groupedImages.containsKey(date)) {
        groupedImages[date] = [];
      }
      groupedImages[date]?.add(asset);
    }

    return groupedImages.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الصور',
          style:  TextStyle(
            color:Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Color(0xff1976d2), Color.fromARGB(174, 255, 76, 225)]),
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
          Color(0xff1976d2),
          Color.fromARGB(174, 255, 76, 225)
        ])),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _assets.isEmpty
                ? const Center(child: Text('لم يجد اي صورة'))
                : ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _groupImagesByDate(_assets).length,
                    itemBuilder: (context, index) {
                      final groupedAssets = _groupImagesByDate(_assets)[index];
                      final date = DateFormat('yyyy-MM-dd')
                          .format(groupedAssets.first.createDateTime);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              date,
                              style: const TextStyle(
                                color:Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(8.0),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 8.0,
                              crossAxisSpacing: 8.0,
                              childAspectRatio: 1,
                            ),
                            itemCount: groupedAssets.length,
                            itemBuilder: (context, index) {
                              final asset = groupedAssets[index];
                              return GestureDetector(
                                onTap: () {
                                  // عند النقر على الصورة، قم بعرض الصورة في شاشة جديدة
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FullImageScreen(
                                          assets: groupedAssets,
                                          initialIndex: index),
                                    ),
                                  );
                                },
                                child: FutureBuilder<Widget>(
                                  future: _getThumbnail(asset),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    }
                                    return snapshot.data ??
                                        const Center(
                                            child: Icon(Icons.broken_image));
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
      ),
    );
  }

  Future<Widget> _getThumbnail(AssetEntity asset) async {
    final thumbnail =
        await asset.thumbnailDataWithSize(const ThumbnailSize(200, 200));
    if (thumbnail != null) {
      return Image.memory(thumbnail, fit: BoxFit.cover);
    } else {
      return const Center(child: Icon(Icons.broken_image));
    }
  }
}

class FullImageScreen extends StatelessWidget {
  final List<AssetEntity> assets;
  final int initialIndex;

  const FullImageScreen(
      {required this.assets, required this.initialIndex, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('عرض الصورة'),
      ),
      body: PageView.builder(
        itemCount: assets.length,
        controller: PageController(initialPage: initialIndex),
        itemBuilder: (context, index) {
          final asset = assets[index];
          return Center(
            child: FutureBuilder<Widget>(
              future: _getFullImage(asset),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return snapshot.data ??
                    const Center(child: Icon(Icons.broken_image));
              },
            ),
          );
        },
      ),
    );
  }

  Future<Widget> _getFullImage(AssetEntity asset) async {
    final fullImage = await asset.file;
    if (fullImage != null) {
      return Image.file(fullImage, fit: BoxFit.cover);
    } else {
      return const Center(child: Icon(Icons.broken_image));
    }
  }
}
