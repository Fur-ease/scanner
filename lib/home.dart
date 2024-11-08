import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scanner/fullcamera.dart';

class Home extends StatefulWidget {
  final CameraDescription camera;

  const Home({super.key, required this.camera});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  late TabController _tabController;
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isFullCameraVisible = false;

  final List<String> _tabs = ['overview', 'car details', 'payment details'];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  Future<void> _initializeCamera() async {
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _toggleFullCamera() {
    setState(() {
      _isFullCameraVisible = !_isFullCameraVisible;
    });

    if (_isFullCameraVisible) {
      // Stop the camera when FullCamera is shown
      _controller.dispose();
    } else {
      // Reinitialize the camera when FullCamera is closed
      _initializeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                _buildNormalContent(),
                if (_isFullCameraVisible)
                  DraggableScrollableSheet(
                    initialChildSize: 1, // Adjust the initial size
                    minChildSize: 0.3, // Minimum size when collapsed
                    maxChildSize: 1.0, // Maximum size when expanded
                    builder: (BuildContext context, ScrollController scrollController) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        child: FullCamera(
                          camera: widget.camera,
                          onClose: () {
                            _toggleFullCamera();
                          },
                          onScanSuccess: (scannedData) {
                            // Handle scanned data
                            print("Scanned data in: $scannedData");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Scanned: $scannedData')),
                            );
                            _toggleFullCamera(); // Close the camera after scanning
                          },
                        ),
                      );
                    },
                  ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildNormalContent() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          pinned: true,
          expandedHeight: 300,
          collapsedHeight: 60,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  SystemNavigator.pop();
                },
                child: const Icon(
                  Icons.exit_to_app,
                  color: Colors.black,
                ),
              ),
              const Text(
                "scan",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                ),
              ),
              PopupMenuButton(
                color: Colors.white,
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 0,
                    child: Text("Send Feedback"),
                  ),
                  const PopupMenuItem(
                    value: 1,
                    child: Text("Privacy Policy"),
                  ),
                  const PopupMenuItem(
                    value: 2,
                    child: Text("Terms of Service"),
                  ),
                ],
              ),
            ],
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              children: [
                Container(
                  height: 350,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    child: CameraPreview(_controller),
                  ),
                ),
                SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      Expanded(
                        child: Center(
                          child: GestureDetector(
                            onTap: _toggleFullCamera,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _tabs.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _buildCustomTab(_tabs[index], index),
                      );
                    },
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                  ),
                ),
              ),
            ],
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return ListTile(
                title: Text('index: $index ,0'),
              );
            },
            childCount: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomTab(String text, int index) {
    bool isSelected = _tabController.index == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _tabController.animateTo(index);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.orange),
          borderRadius: BorderRadius.circular(20),
          color: isSelected ? Colors.orange.withOpacity(0.2) : Colors.transparent,
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.orange,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}