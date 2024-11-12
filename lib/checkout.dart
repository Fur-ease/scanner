import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
//import 'package:lottie/lottie.dart';
import 'package:scanner/home.dart';
import 'package:scanner/main.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class Checkout extends StatefulWidget {
  final List<String> scannedData;
  final double totalAmount;

  const Checkout({super.key, required this.scannedData, required this.totalAmount});

  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  final ImagePicker _picker = ImagePicker();
  final File?  _image = null; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                List<String> titles = [ 'Client details'];
                return Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(16),
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
                  child: Column(
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
                        widget.scannedData[index],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
              childCount: widget.scannedData.length,
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(16),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Total Amount",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Total: \$${widget.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Upload Picture",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.withOpacity(0.8),
                    ),
                    onPressed: () async {
                      await _picker.pickImage(source: ImageSource.camera);
                      if (_image != null) {
                        setState(() {});
                      }
                      Navigator.of(context).pop();
                    },
                    //_showImageSourceDialog,
                    child: const Text(
                      'Take Picture',
                      ),
                  ),
                  const SizedBox(height: 10),
                  if (_image != null)
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.orange),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(_image.path),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.withOpacity(0.9),
                  alignment: Alignment.center,
                ),
                onPressed: () {
                  if (_image != null) {
                    showTopSnackBar(
                      Overlay.of(context),
                       CustomSnackBar.error(
                        message: "Please insert document or picture",
                        backgroundColor: Colors.red,
                        icon: Lottie.asset("assets/error.json"),
                        //icon: Icon(Icons.check, size: 50),
                      ),
                    );
                  }
                  else{
                      showTopSnackBar(
                      Overlay.of(context),
                       CustomSnackBar.success(
                        message: "Checkout successful!",
                        backgroundColor: Colors.green,
                        icon: Lottie.asset("assets/success.json"),
                        //icon: Icon(Icons.check, size: 50),
                      ),
                    );
                    Navigator.pushNamed(context, MaterialPageRoute(builder: (context) => Home(camera: cameras.first,)) as String);
                  }
                },
                child: const Text(
                  'Confirm Checkout',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

//   void _showImageSourceDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Select Image Source'),
//           actions: [
//             TextButton(
//               onPressed: () async {
//                 await _picker.pickImage(source: ImageSource.camera);
//                 if (_image != null) {
//                   setState(() {});
//                 }
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Camera'),
//             ),
//             // TextButton(
//             //   onPressed: () async {
//             //     _image = await _picker.pickImage(source: ImageSource.gallery);
//             //     if (_image != null) {
//             //       setState(() {});
//             //     }
//             //     Navigator.of(context).pop();
//             //   },
//             //   child: const Text('Gallery'),
//             // ),
//           ],
//         );
//       },
//     );
//   }
 }