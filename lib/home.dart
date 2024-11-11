import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scanner/billing.dart';
import 'package:scanner/fullcamera.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

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

  final List<String> _tabs = ['overview','payment details'];
  final List<String> _scannedDataList = [];

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
      _controller.dispose();
    } else {
      _initializeCamera();
    }
  }

  void _showTopSnackBar(BuildContext context) {
    showTopSnackBar(
      Overlay.of(context),
      const CustomSnackBar.info(
        message: "You have scanned all required codes",
        backgroundColor: Colors.red,
        icon: Icon(
          Icons.info,
          size: 40,
        ),
      ),
    );
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
                    initialChildSize: 1, 
                    minChildSize: 0.3, 
                    maxChildSize: 1.0,
                    builder: (BuildContext context, ScrollController scrollController) {
                      return Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        child: FullCamera(
                          camera: widget.camera,
                          onClose: () {
                            _toggleFullCamera();
                          },
                          onScanSuccess: (scannedData) {
                            setState(() {
                              _scannedDataList.add(scannedData);
                            });
                            
                            print("Scanned data in: $scannedData");
                            // showTopSnackBar(
                            //     Overlay.of(context),
                            //     CustomSnackBar.success(
                            //       message:
                            //           "Scanned: $scannedData",
                            //     ),
                            //     persistent: true,
                            // );
                            // ScaffoldMessenger.of(context).showSnackBar(
                            //   SnackBar(
                            //     content: Text(
                            //       'Scanned: $scannedData',
                            //       ),
                            //   ),
                            // );
                            //_toggleFullCamera(); 
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
                  color: Colors.white,
                ),
              ),
              const Text(
                "scan",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                ),
              ),
              PopupMenuButton(
                icon: const Icon(
                  Icons.more_vert, 
                color: Colors.white, 
                ),
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
                      const SizedBox(height: 30),
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: (_scannedDataList.length > 2)  ? () {
                                  _showTopSnackBar(context as BuildContext); 
                                    } 
                                      : _toggleFullCamera,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: (_scannedDataList.length > 2)
                                      ? Colors.grey.withOpacity(0.1)
                                      : Colors.grey.withOpacity(0.4),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8), 
                              const Text(
                                'Scan with your camera',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20, 
                                  fontWeight: FontWeight.bold, 
                                ),
                              ),
                            ],
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
               List<String> titles = ['CLI', 'Car Details', 'Personal Details'];
              if (index < _scannedDataList.length) {
                return Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(16),
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.orange),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        blurStyle: BlurStyle.outer,
                        blurRadius: 2,
                        offset: const Offset(0, 0),
                        color: Colors.grey.withOpacity(0.6),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            titles[index],
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 10), 
                          Text(
                            _scannedDataList[index],
                            style: const TextStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10,),
                      Positioned(
                        bottom: 5,
                        right: 5,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.amber,
                          ),
                          onPressed: (_scannedDataList.length > 2 && index < 2) ? null : () {
                            if (_scannedDataList.length > 2) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Billing(scannedData: _scannedDataList,)), 
                              );
                            } else {
                              setState(() {
                                _toggleFullCamera();
                              });
                            }
                          }, 
                          child: const Text(
                            "Continue",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return Container();
              }
            },
            childCount: _scannedDataList.length, 
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