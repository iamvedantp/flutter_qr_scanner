import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "QR Code Scanner",
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: const Center(
          child: Text(
            'QR Code Scanner',
            style: TextStyle(color: Colors.black87, fontSize: 28),
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QRCodeWidget(),
                  ),
                );
              },
              child: const Text(
                'Scan Now',
                style: TextStyle(fontSize: 25),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QRCodeWidget extends StatefulWidget {
  const QRCodeWidget({Key? key}) : super(key: key);

  @override
  State<QRCodeWidget> createState() => _QRCodeWidgetState();
}

class _QRCodeWidgetState extends State<QRCodeWidget> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late QRViewController controller;
  String result = '';

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Scanner'),
      ),
      body: Column(
        children: [
          Expanded(
            child: QRView(
              key: qrKey,
              onQRViewCreated: (controller) {
                setState(() {
                  this.controller = controller;
                });
                controller.scannedDataStream.listen((scandata) {
                  setState(() {
                    result = scandata.code!;
                    if (result.isNotEmpty) {
                      // If result is not empty, close the camera
                      controller.pauseCamera();
                    }
                  });
                });
              },
            ),
          ),
          if (result.isNotEmpty)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Scanned URL:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  result,
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: result));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Copied to Clipboard'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(vertical: 13, horizontal: 20),
                      ),
                      child: const Text(
                        'Copy',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    SizedBox(width: 180),
                    ElevatedButton(
                      onPressed: () {
                        final Uri url = Uri.parse(result);
                        launchUrl(url);
                      },
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(vertical: 13, horizontal: 20),
                      ),
                      child: const Text(
                        'Open',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {
                    // Clear the result and resume the camera
                    setState(() {
                      result = '';
                    });
                    controller.resumeCamera();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                  ),
                  child: const Text(
                    'Scan Again',
                    style: TextStyle(fontSize: 23),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
