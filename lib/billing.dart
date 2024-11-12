import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scanner/checkout.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class Billing extends StatefulWidget {
  final List<String> scannedData;
  final int amount = 200;

  const Billing({super.key, required this.scannedData});

  @override
  State<Billing> createState() => _BillingState();
}

class _BillingState extends State<Billing> {
   final TextEditingController _amountLitresController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return content();
  }

  Widget content() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                List<String> titles = ['Client Details'];
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
                      const Text(
                        "Payment",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _amountLitresController,
                        decoration: const InputDecoration(
                          labelText: "Amount Litres",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly], 
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {}); 
                        }, 
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Amount per liter: \$${widget.amount}",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "total Amount: \$${_calculateTotalAmount()}", 
                      style: const TextStyle(fontSize: 18, color: Colors.black),
                      ),
                      const SizedBox(height: 20), 
                    ],
                  ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          alignment: Alignment.center,
                        ),
                        onPressed: () {
                         if(_amountLitresController.text.isNotEmpty){
                            double totalAmount = _calculateTotalAmount();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Checkout(
                                scannedData: widget.scannedData,
                                totalAmount: totalAmount,
                              ),
                            ),
                          );
                          }else{
                            showTopSnackBar(
                              Overlay.of(context),
                              const CustomSnackBar.info(
                                message: "Please enter amount litres",
                                backgroundColor: Colors.red,
                                icon: Icon(Icons.info, size: 50,),
                              ),
                            );
                          }
                        },
                        child: const Text('confirm',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  double _calculateTotalAmount() {

    double litres = double.tryParse(_amountLitresController.text) ?? 0;
    return widget.amount * litres; 
  }
}