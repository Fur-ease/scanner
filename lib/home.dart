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
  bool isReplacing = false;
   late String currentTab = _tabs[_tabController.index];
  // final List<String>? _scannedDataList = scannedDataMap[currentTab];
  final List<String> _tabs = ['CCL','Car details','Driver details','Client details'];
  final Map<String, List<String>> scannedDataMap = {
    'CCL':[],
    'Car details':[],
    'Driver details':[],
    'Client details':[],
  };

  int scanCount = 0;
  //final List<String> _scannedDataList = [];

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
      if(isReplacing){
        String currentTab =_tabs[_tabController.index];
        scannedDataMap[currentTab]!.clear();
        scanCount = _tabs.indexOf(currentTab);
      }
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
    return WillPopScope(
      onWillPop: () async {
        if (_tabController.index > 0) {
          setState(() {
            _tabController.index = _tabController.index - 1;
          });
          return false; 
        }
        return true; 
      },
      child: Scaffold(
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
                                String currentTab = _tabs[_tabController.index];
                                if (isReplacing){
                                  scannedDataMap[currentTab]!.clear();
                                  scannedDataMap[currentTab]!.add(scannedData);
                                  isReplacing = false;
                                } else {
                                  if (_tabController.index == 0) {
                                    scannedDataMap[currentTab]!.add(scannedData);
                                  } else {
                                    //int nextTabIndex = (_tabController.index ) % _tabs.length;
                                   // String nextTab = _tabs[nextTabIndex];
                                    scannedDataMap[currentTab]!.add(scannedData) ;
                                    
                                    //_tabController.animateTo(nextTabIndex);
                                  }
                                }
                                // if (_tabController.index < _tabs.length - 1) {
                                //   int nextTabIndex = (_tabController.index + 1) % _tabs.length;
                                //   _tabController.animateTo(nextTabIndex);
                                // }
                                //scannedDataMap[currentTab]?.add(scannedData);
                                //scanCount++;
                                //_scannedDataList.add(scannedData);
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
                                onTap: () {
                                   if (scannedDataMap[_tabs[0]]!.length > 3) {
                                      _showTopSnackBar(context); 
                                    } else {
                                      _toggleFullCamera();
                                    }
                                  },
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: (scannedDataMap[_tabs[_tabController.index]]!.length > 3)
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
              SizedBox(
                width: MediaQuery.of(context).size.width,
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
               String currentTab = _tabs[_tabController.index];
               List<String>? _scannedDataList = scannedDataMap[currentTab];
              if (_scannedDataList != null && index < _scannedDataList.length ) {
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
                  child: Flexible(
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentTab,
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
                            onPressed: () {
                              int currentTabIndex = _tabController.index;
                              if (currentTabIndex == _tabs.length - 1) {
                                Navigator.push(
                                  context, 
                                  MaterialPageRoute(
                                    builder: (context) => Billing(
                                    scannedData: [_scannedDataList.last],)
                                  )
                                );
                              } else {
                                if (currentTabIndex != _tabs.length - 1) {
                                  if(_scannedDataList[index].isEmpty) {
                                    showTopSnackBar(
                                      context as OverlayState,
                                      const CustomSnackBar.info(
                                        message: "please scan first",
                                      )
                                    );
                                  } else {
                                    setState(() {
                                    _tabController.index = currentTabIndex + 1;
                                  });
                                  _tabController.animateTo(currentTabIndex + 1);
                                  }
                                } 
                              } 
                            },
                            child: const Text(
                              "Continue",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Positioned(
                          bottom: 5,
                          left: 5,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber
                            ),
                            onPressed: () {
                              isReplacing = true;
                              _toggleFullCamera();
                              },
                            child: const Text("Replace Current Data"),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              } else {
                return Container();
              }
            },
            childCount: scannedDataMap[_tabs[_tabController.index]]?.length ?? 0, 
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