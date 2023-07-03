import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothUtils {
  static Future<bool> isBluetoothAvailable() async {
    final FlutterBluetoothSerial flutterBluetoothSerial = FlutterBluetoothSerial.instance;
    return await flutterBluetoothSerial.isEnabled ?? false;
  }
}
