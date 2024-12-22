import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:image_picker/image_picker.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<AssetPathEntity> _paths = [];
  bool _isLoading = false;
  bool _isGridView = true;

  Future<void> _requestAssets() async {
    setState(() {
      _isLoading = true;
    });

    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps == PermissionState.authorized) {
      final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(onlyAll: false);
      setState(() {
        _paths = paths;
        _isLoading = false;
      });
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




final ImagePicker _picker = ImagePicker();
Future<void> _openCamera() async {
    // التقاط صورة باستخدام الكاميرا
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      try {
        // حفظ الصورة في المعرض
        final AssetEntity? savedImage =
            await PhotoManager.editor.saveImageWithPath(image.path);

        if (savedImage != null) {
          setState(() {
            // تحديث الألبومات لتضمين الصورة الجديدة
            _requestAssets();
          });

          // عرض رسالة نجاح
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(' تم حفظ الصورة بنجاح إلى المعرض!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        // التعامل مع الخطأ وعرض رسالة فشل
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ فشل حفظ الصورة: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // التعامل مع حالة عدم التقاط صورة
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('📷 لم يتم التقاط أي صورة.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  // Future<void> _openCamera() async {
  //   final XFile? image = await _picker.pickImage(source: ImageSource.camera);

  //   if (image != null) {
  //     // حفظ الصورة إلى المعرض
  //     try {
  //       final AssetEntity? savedImage =
  //           await PhotoManager.editor.saveImageWithPath(image.path);
  //       if (savedImage != null) {
  //         setState(() {
  //           // إعادة تحميل الألبومات لتضمين الصورة الجديدة
  //           _requestAssets();
  //         });
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text('تم حفظ الصورة بنجاح إلى المعرض!')),
  //         );
  //       }
  //     } catch (e) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('فشل حفظ الصورة: $e')),
  //       );
  //     }
  //   }
  // }

  @override
  void initState() {
    super.initState();
    _requestAssets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الألبومات',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xffffffff),
          ),
        
        
        ),

        centerTitle: true,
         flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Color(0xff1976d2), Color.fromARGB(174, 255, 76, 225)]),
          ),
          // child: ,
        ),
        leading: IconButton(
            icon: const Icon(Icons.camera_alt, color: Colors.white),
            onPressed: _openCamera,
          ),
        
        actions: [
          PopupMenuButton<String>(
           child: const Padding(
              padding: EdgeInsets.all(10.0),
              child: Icon(Icons.format_align_center, color: Colors.white),
            ),
          
            onSelected: (value) {
              setState(() {
                _isGridView = value == 'grid_view';
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                
                value: 'grid_view',
                child: 
                 Row(
                  children: <Widget>[
                    Icon(
                      Icons.grid_view,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'عرض ك شبكة',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
                
              const PopupMenuItem(               
                value: 'list_view',
                child:  Row(
                  children: <Widget>[
                    Icon(
                      Icons.list_outlined,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'عرض ك قائمة',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      
      body:
      Container(
        decoration: const BoxDecoration(
            gradient:
                LinearGradient(colors: [Color(0xff1976d2), Color.fromARGB(174, 255, 76, 225)])),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _paths.isEmpty
                ? const Center(child: Text('لاتوجد البومات'))
                : _isGridView
                    ? _buildGridView()
                    : _buildListView(),
      ),
         
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFDAF4FF),
        onPressed: _requestAssets,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
        childAspectRatio: 1.5,
      ),
      itemCount: _paths.length,
      itemBuilder: (context, index) {
        final path = _paths[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AlbumScreen(path: path),
              ),
            );
          },
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: FutureBuilder<Widget>(
                    future: _getAlbumThumbnail(path),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return snapshot.data ?? const Center(child: Icon(Icons.broken_image));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    path.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

Widget _buildListView() {
  return ListView.builder(
    padding: const EdgeInsets.all(8.0),
    itemCount: _paths.length,
    itemBuilder: (context, index) {
      final path = _paths[index];
      return Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: FutureBuilder<Widget>(
              future: _getAlbumThumbnail(path),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    width: 50,
                    height: 50,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return snapshot.data ?? const Icon(Icons.broken_image, size: 50);
              },
            ),
          ),
          title: Text(
            path.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          subtitle: FutureBuilder<int>(
            future: path.assetCountAsync,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text("...يتم التحميل");
              }
              return Text(
                "${snapshot.data ?? 0} ",
                style: TextStyle(color: Colors.grey[600]),
              );
            },
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AlbumScreen(path: path),
              ),
            );
          },
        ),
      );
    },
  );
}


  Future<Widget> _getAlbumThumbnail(AssetPathEntity path) async {
    final assets = await path.getAssetListRange(start: 0, end: 1);
    if (assets.isNotEmpty) {
      final thumbnail = await assets.first.thumbnailDataWithSize(const ThumbnailSize(200, 200));
      if (thumbnail != null) {
        return Image.memory(thumbnail, fit: BoxFit.cover);
      }
    }
    return const Center(child: Icon(Icons.image));
  }
}

class AlbumScreen extends StatefulWidget {
  final AssetPathEntity path;

  const AlbumScreen({super.key, required this.path});

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  List<AssetEntity> selectedAssets = [];

  // جلب الصور وترتيبها بحيث تظهر الصور الحديثة أولاً
  Future<List<AssetEntity>> _getAssets() async {
    final assets = await widget.path.getAssetListRange(
        start: 0, end: 100); // يمكنك تعديل هذا الرقم حسب الحاجة
    assets.sort((a, b) => b.createDateTime
        .compareTo(a.createDateTime)); // ترتيب الصور حسب تاريخ الإنشاء
    return assets;
  }

  void _toggleSelectAll(List<AssetEntity> assets) {
    setState(() {
      if (selectedAssets.length == assets.length) {
        // إذا كانت جميع الصور محددة، نقوم بإلغاء تحديدها
        selectedAssets.clear();
      } else {
        // إذا لم تكن جميع الصور محددة، نقوم بتحديدها
        selectedAssets = List.from(assets);
      }
    });
  }

  // دالة لفتح الشاشة الجديدة عند النقر على الصورة
  void _openImageViewer(int initialIndex, List<AssetEntity> assets) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageViewerScreen(
          assets: assets,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.path.name,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.select_all, // أيقونة تحديد الكل
            color: Colors.white,
          ),
          onPressed: () async {
            final assets = await _getAssets();
            _toggleSelectAll(assets); // تحديد أو إلغاء تحديد جميع الصور
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.arrow_forward, // أيقونة الرجوع
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).pop(); // الرجوع إلى الشاشة السابقة
            },
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff1976d2), Color.fromARGB(174, 255, 76, 225)],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff1976d2), Color.fromARGB(174, 255, 76, 225)],
          ),
        ),
        child: FutureBuilder<List<AssetEntity>>(
          future: _getAssets(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('خطأ في تحميل البيانات'));
            }

            final assets = snapshot.data;

            if (assets == null || assets.isEmpty) {
              return const Center(child: Text('لاتوجد بيانات'));
            }

            return GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // عدد الأعمدة في الشبكة
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
              ),
              itemCount: assets.length,
              itemBuilder: (context, index) {
                final asset = assets[index];
                return GestureDetector(
                  onTap: () =>
                      _openImageViewer(index, assets), // فتح الصورة عند النقر
                  child: FutureBuilder<Widget>(
                    future: _getAssetWidget(asset),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return snapshot.data ?? Container();
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<Widget> _getAssetWidget(AssetEntity asset) async {
    final thumbnail =
        await asset.thumbnailDataWithSize(const ThumbnailSize(200, 200));
    if (thumbnail != null) {
      return Image.memory(thumbnail, fit: BoxFit.cover);
    } else {
      return const Center(child: Icon(Icons.broken_image));
    }
  }
}

// شاشة عرض الصور
class ImageViewerScreen extends StatelessWidget {
  final List<AssetEntity> assets;
  final int initialIndex;

  const ImageViewerScreen({
    Key? key,
    required this.assets,
    required this.initialIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("عرض الصور"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: PageView.builder(
        itemCount: assets.length,
        controller: PageController(initialPage: initialIndex),
        itemBuilder: (context, index) {
          final asset = assets[index];
          return FutureBuilder<Widget>(
            future: _getAssetWidget(asset),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              return snapshot.data ?? Container();
            },
          );
        },
      ),
    );
  }

  Future<Widget> _getAssetWidget(AssetEntity asset) async {
    final thumbnail =
        await asset.thumbnailDataWithSize(const ThumbnailSize(400, 400));
    if (thumbnail != null) {
      return Image.memory(thumbnail, fit: BoxFit.contain);
    } else {
      return const Center(child: Icon(Icons.broken_image));
    }
  }
}
