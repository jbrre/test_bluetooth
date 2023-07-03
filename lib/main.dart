import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:logger/logger.dart';
import 'bluetooth_utils.dart'; // Import the BluetoothUtils class

final logger = Logger();
final FlutterBlePeripheral blePeripheral = FlutterBlePeripheral();
final AdvertiseData advertiseData = AdvertiseData(
  serviceUuid: 'bf27730d-860a-4e09-889c-2d8b6a9e0fe7',
  manufacturerId: 1234,
  manufacturerData: Uint8List.fromList([1, 2, 3, 4, 5, 6]),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check Bluetooth availability
  bool isBluetoothEnabled = await BluetoothUtils.isBluetoothAvailable();

  if (isBluetoothEnabled) {
    logger.i('Bluetooth is available');
    await blePeripheral.start(advertiseData: advertiseData);
    logger.i('Advertising data over Bluetooth');
  } else {
    logger.i('Bluetooth is not available');
  }

  runApp(MyApp(isBluetoothEnabled: isBluetoothEnabled));
}

class MyApp extends StatelessWidget {
  final bool isBluetoothEnabled; // Store the Bluetooth availability status

  const MyApp({Key? key, required this.isBluetoothEnabled}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: isBluetoothEnabled
          ? const MyHomePage(title: 'Flutter Demo Home Page')
          : handleBluetoothFail(),
      // Use MyHomePage if Bluetooth is enabled, otherwise call handleBluetoothFail()
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _placeholderText = 'No data';

  void _updateNumber(int number) {
    setState(() {
      _placeholderText = number.toString();
    });
  }

  @override
  void initState() {
    super.initState();
    Future<void> checkConnectionStatus() async {
      bool isConnected = await blePeripheral.isConnected;
      if (isConnected) {
        setState(() {
          _placeholderText = 'Someone connected';
        });
      } else {
        logger.i('No device is connected to the Bluetooth peripheral.');
      }
    }
    checkConnectionStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Number from Bluetooth:',
            ),
            Text(
              _placeholderText,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          int receivedNumber = 42;
          _updateNumber(receivedNumber);
        },
        tooltip: 'Receive Number',
        child: const Icon(Icons.bluetooth),
      ),
    );
  }
}

Widget handleBluetoothFail() {
  // Placeholder function when Bluetooth is not available
  logger.e('Bluetooth is not available on this device');
  return Scaffold(
    appBar: AppBar(
      title: const Text('Bluetooth Unavailable'),
    ),
    body: const Center(
      child: Text('Bluetooth is not available on this device.'),
    ),
  );
}
