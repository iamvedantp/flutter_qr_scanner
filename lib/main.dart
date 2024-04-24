import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart'; // Import the QR code scanner package
import 'package:url_launcher/url_launcher.dart'; // Import the URL launcher package

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "QR Code Scanner",
      theme: ThemeData(
          primarySwatch: Colors.blueGrey), // Set app theme to blue-grey
      debugShowCheckedModeBanner: false,
      home: const HomePage(), // Set HomePage as the initial screen
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
                // Navigate to QRCodeWidget when "Scan Now" button is pressed
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
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR'); // Key for QRView widget
  late QRViewController controller; // Controller for QR code scanning
  String result = ''; // Store scanned QR code result
  bool isFlashOn = false; // Track flashlight status

  @override
  void dispose() {
    controller.dispose(); // Dispose the QRViewController to release resources
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
            child: Stack(
              alignment: Alignment.center,
              children: [
                QRView(
                  key: qrKey,
                  onQRViewCreated: (controller) {
                    // Initialize QRViewController and handle scan events
                    setState(() {
                      this.controller = controller;
                    });
                    controller.scannedDataStream.listen((scandata) {
                      setState(() {
                        result = scandata.code!; // Store scanned QR code result
                        if (result.isNotEmpty) {
                          // Pause camera when a QR code is successfully scanned
                          controller.pauseCamera();
                        }
                      });
                    });
                  },
                ),
                if (result.isEmpty)
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white,
                        width: 2.0,
                      ),
                    ),
                    width: 200.0,
                    height: 200.0,
                  ),
              ],
            ),
          ),
          if (result.isNotEmpty)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Scanned URL:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  result,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Copy scanned URL to clipboard
                        Clipboard.setData(ClipboardData(text: result));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Copied to Clipboard'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 13, horizontal: 20),
                      ),
                      child: const Text(
                        'Copy',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    const SizedBox(width: 180),
                    ElevatedButton(
                      onPressed: () {
                        // Open scanned URL in default browser
                        final Uri url = Uri.parse(result);
                        launch(url.toString());
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 13, horizontal: 20),
                      ),
                      child: const Text(
                        'Open',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {
                    // Clear result and resume camera for scanning again
                    setState(() {
                      result = '';
                    });
                    controller.resumeCamera();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 30),
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
      bottomNavigationBar: result.isEmpty
          ? BottomAppBar(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      // Toggle flashlight on/off
                      setState(() {
                        isFlashOn = !isFlashOn;
                      });
                      controller.toggleFlash();
                    },
                    icon: Icon(
                      isFlashOn ? Icons.highlight : Icons.highlight_off,
                      size: 30,
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
