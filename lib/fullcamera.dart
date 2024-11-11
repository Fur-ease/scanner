import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class FullCamera extends StatefulWidget {
  const FullCamera({
    super.key,
    required this.camera,
    required this.onClose,
    required this.onScanSuccess,
  });

  final CameraDescription camera;
  final VoidCallback onClose;
  final Function(String) onScanSuccess;

  @override
  State<FullCamera> createState() => _FullCameraState();
}

class _FullCameraState extends State<FullCamera> with SingleTickerProviderStateMixin {
  late MobileScannerController cameraController;
  bool isFlashOn = false;
  bool hasScanned = false;
  bool isScanning = false;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    cameraController = MobileScannerController();

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 250).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        isScanning = true;
      });
      _animationController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    cameraController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleFlash() {
    setState(() {
      isFlashOn = !isFlashOn;
      cameraController.toggleTorch();
    });
  }

  void _handleScan(String scannedData) {
    if (!hasScanned) {
      setState(() {
        hasScanned = true;
        isScanning = false;
      });
      _animationController.stop();
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          widget.onScanSuccess(scannedData);
          widget.onClose(); 
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 1,
      minChildSize: 0.3, 
      maxChildSize: 1.0, 
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              MobileScanner(
                controller: cameraController,
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    print('Scanned data: ${barcode.rawValue}');
                    _handleScan(barcode.rawValue!); 
                  }
                },
              ),
              Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                    children: [
                      if (isScanning && !hasScanned)
                        Positioned(
                          top: _animation.value,
                          child: Container(
                            height: 2,
                            width: 250,
                            color: Colors.green.withOpacity(0.5),
                          ),
                        ),
                      ...List.generate(4, (index) {
                        final isTop = index < 2;
                        final isLeft = index.isEven;
                        return Positioned(
                          top: isTop ? 0 : null,
                          bottom: !isTop ? 0 : null,
                          left: isLeft ? 0 : null,
                          right: !isLeft ? 0 : null,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              border: Border(
                                top: isTop ? BorderSide(color: hasScanned ? Colors.green : Colors.white, width: 4) : BorderSide.none,
                                bottom: !isTop ? BorderSide(color: hasScanned ? Colors.green : Colors.white, width: 4) : BorderSide.none,
                                left: isLeft ? BorderSide(color: hasScanned ? Colors.green : Colors.white, width: 4) : BorderSide.none,
                                right: !isLeft ? BorderSide(color: hasScanned ? Colors.green : Colors.white, width: 4) : BorderSide.none,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.15,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Text(
                      hasScanned ? 'Scanned!' : 'Scan QR Code',
                      style: TextStyle(
                        color: hasScanned ? Colors.green : Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hasScanned ? 'Successfully scanned the QR code' : 'Place the QR code within the frame',
                      style: TextStyle(
                        color: hasScanned ? Colors.green : Colors.white,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 20,
                left: 16,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: widget.onClose, 
                ),
              ),
              Positioned(
                top: 20,
                right: 16,
                child: IconButton(
                  onPressed: _toggleFlash,
                  icon: Icon(
                    isFlashOn ? Icons.flash_on : Icons.flash_off,
                    color: Colors.white,
                  ),
                ),
              ),
              if (hasScanned)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 100,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}