import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';

class VideosScreen extends StatefulWidget {
  const VideosScreen({super.key});

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  List<AssetPathEntity> albums = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlbums();
  }

  Future<void> _loadAlbums() async {
    final PermissionState permission =
        await PhotoManager.requestPermissionExtend();
    if (!permission.isAuth) {
      setState(() => isLoading = false);
      return;
    }

    final fetchedAlbums = await PhotoManager.getAssetPathList(
      type: RequestType.video,
      filterOption: FilterOptionGroup(
        orders: [
          const OrderOption(type: OrderOptionType.createDate, asc: false),
        ],
      ),
    );

    setState(() {
      albums = fetchedAlbums;
      isLoading = false;
    });
  }

  Future<List<AssetEntity>> _getAssets(AssetPathEntity album) async {
    final List<AssetEntity> allAssets = [];
    int start = 0;
    const int batchSize = 100;

    while (true) {
      final List<AssetEntity> assets = await album.getAssetListRange(
        start: start,
        end: start + batchSize,
      );

      if (assets.isEmpty) {
        break;
      }

      allAssets.addAll(assets);
      start += batchSize;
    }

    allAssets.sort((a, b) => b.createDateTime.compareTo(a.createDateTime));

    return allAssets;
  }

  void _openVideoViewer(AssetPathEntity album) async {
    final assets = await _getAssets(album);
    if (assets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No videos found in this album"),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoViewerScreen(
          assets: assets,
        ),
      ),
    );
  }

  Future<Widget> _getAlbumThumbnail(AssetPathEntity album) async {
    final assets = await album.getAssetListRange(start: 0, end: 1);
    if (assets.isNotEmpty) {
      final thumbnail = await assets.first
          .thumbnailDataWithSize(const ThumbnailSize(200, 200));
      if (thumbnail != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.memory(thumbnail, fit: BoxFit.cover),
        );
      }
    }
    return const Icon(Icons.video_collection, size: 50, color: Colors.grey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الفيديوهات',
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
      ),
      body: Container(
        decoration: const BoxDecoration(
            gradient:
                LinearGradient(colors: [Color(0xff1976d2), Color.fromARGB(174, 255, 76, 225)])),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : albums.isEmpty
                ? const Center(child: Text("No albums found"))
                : GridView.builder(
                    padding: const EdgeInsets.all(12.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12.0,
                      crossAxisSpacing: 12.0,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: albums.length,
                    itemBuilder: (context, index) {
                      final album = albums[index];
                      return GestureDetector(
                        onTap: () => _openVideoViewer(album),
                        child: Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: FutureBuilder<Widget>(
                                  future: _getAlbumThumbnail(album),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    }
                                    return snapshot.data ?? Container();
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  album.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
        
        ),
      
      
     
    );
  }
}

class VideoViewerScreen extends StatefulWidget {
  final List<AssetEntity> assets;

  const VideoViewerScreen({Key? key, required this.assets}) : super(key: key);

  @override
  _VideoViewerScreenState createState() => _VideoViewerScreenState();
}

class _VideoViewerScreenState extends State<VideoViewerScreen> {
  late VideoPlayerController _controller;
  late bool isPlaying;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = 0;
    isPlaying = false;
    _initializeVideo(widget.assets[currentIndex]);
  }

  void _initializeVideo(AssetEntity asset) async {
    final videoFile = await asset.file;
    if (videoFile != null) {
      _controller = VideoPlayerController.file(videoFile)
        ..initialize().then((_) {
          setState(() {});
          _controller.play();
          isPlaying = true;
        });
    }
  }

  void _togglePlayPause() {
    setState(() {
      if (isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
      isPlaying = !isPlaying;
    });
  }

  void _nextVideo() {
    setState(() {
      if (currentIndex < widget.assets.length - 1) {
        currentIndex++;
        _initializeVideo(widget.assets[currentIndex]);
      }
    });
  }

  void _previousVideo() {
    setState(() {
      if (currentIndex > 0) {
        currentIndex--;
        _initializeVideo(widget.assets[currentIndex]);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Video'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _controller.value.isInitialized
          ? Column(
              children: [
                AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.skip_previous),
                      onPressed: _previousVideo,
                    ),
                    IconButton(
                      icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                      onPressed: _togglePlayPause,
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next),
                      onPressed: _nextVideo,
                    ),
                  ],
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
