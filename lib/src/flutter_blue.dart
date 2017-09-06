// Copyright 2017, Paul DeMarco.
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of flutter_blue;

class FlutterBlue {
  final MethodChannel _channel = const MethodChannel('$NAMESPACE/methods');
  final EventChannel _stateChannel = const EventChannel('$NAMESPACE/state');
  final EventChannel _scanResultChannel =
      const EventChannel('$NAMESPACE/scanResult');
  final EventChannel _servicesDiscoveredChannel =
      const EventChannel('$NAMESPACE/servicesDiscovered');
  final EventChannel _characteristicReadChannel =
      const EventChannel('$NAMESPACE/characteristicRead');
  final EventChannel _descriptorReadChannel =
      const EventChannel('$NAMESPACE/descriptorRead');
  final EventChannel _characteristicNotifiedChannel =
      const EventChannel('$NAMESPACE/characteristicNotified');
  final StreamController<MethodCall> _methodStreamController =
      new StreamController.broadcast(); // ignore: close_sinks
  Stream<MethodCall> get _methodStream => _methodStreamController
      .stream; // Used internally to dispatch methods from platform.

  /// Singleton boilerplate
  FlutterBlue._() {
    _channel.setMethodCallHandler((MethodCall call) {
      _methodStreamController.add(call);
    });
  }
  static FlutterBlue _instance = new FlutterBlue._();
  static FlutterBlue get instance => _instance;

  /// Checks whether the device supports Bluetooth
  Future<bool> get isAvailable => _channel.invokeMethod('isAvailable');

  /// Checks if Bluetooth functionality is turned on
  Future<bool> get isOn => _channel.invokeMethod('isOn');

  /// Gets the current state of the Bluetooth module
  Future<BluetoothState> get state {
    return _channel
        .invokeMethod('state')
        .then((List<int> data) => new protos.BluetoothState.fromBuffer(data))
        .then((s) => BluetoothState.values[s.state.value]);
  }

  /// Occurs when the bluetooth state has changed
  Stream<BluetoothState> onStateChanged() {
    return _stateChannel
        .receiveBroadcastStream()
        .map((List<int> data) => new protos.BluetoothState.fromBuffer(data))
        .map((s) => BluetoothState.values[s.state.value]);
  }

  /// Starts a scan for Bluetooth Low Energy devices
  /// Timeout closes the stream after a specified [Duration]
  Stream<ScanResult> scan({
    ScanMode scanMode = ScanMode.lowLatency,
    List<Guid> withServices = const [],
    List<Guid> withDevices = const [],
    Duration timeout,
  }) async* {
    var settings = protos.ScanSettings.create()
      ..androidScanMode = scanMode.value
      ..serviceUuids.addAll(withServices.map((g) => g.toString()).toList());
    StreamSubscription subscription;
    StreamController controller;
    controller = new StreamController(
      onListen: () {
        if(timeout != null) {
          new Future.delayed(timeout, () => controller.close());
        }
      },
      onCancel: () {
        _stopScan();
        subscription.cancel();
      },
    );

    await _channel.invokeMethod('startScan', settings.writeToBuffer());

    subscription = _scanResultChannel.receiveBroadcastStream().listen(
          controller.add,
          onError: controller.addError,
          onDone: controller.close,
        );

    yield* controller.stream
        .map((List<int> data) => new protos.ScanResult.fromBuffer(data))
        .map((p) => new ScanResult.fromProto(p));
  }

  /// Stops a scan for Bluetooth Low Energy devices
  Future<Null> _stopScan() => _channel.invokeMethod('stopScan');

  /// Establishes a connection to the Bluetooth Device.
  /// Returns a stream of [BluetoothDeviceState]
  /// Timeout closes the stream after a specified [Duration]
  /// To cancel connection to device, simply cancel() the stream subscription
  Stream<BluetoothDeviceState> connect(BluetoothDevice device,
      {Duration timeout}) async* {
    var request = protos.ConnectRequest.create()
      ..remoteId = device.id.toString()
      ..androidAutoConnect = true;
    var connected = false;
    StreamSubscription subscription;
    StreamController controller;
    controller = new StreamController(
      onListen: () {
        if(timeout != null) {
          new Future.delayed(timeout, () => (!connected) ? controller.close(): null);
        }
      },
      onCancel: () {
        _cancelConnection(device);
        subscription.cancel();
      },
    );

    await _channel.invokeMethod('connect', request.writeToBuffer());

    subscription = device.onStateChanged().listen(
        (data) {
          if(data == BluetoothDeviceState.connected) {
            print('connected!');
            connected = true;
          }
          controller.add(data);
        },
          onError: controller.addError,
          onDone: controller.close,
        );

    yield* controller.stream;
  }

  /// Cancels connection to the Bluetooth Device
  Future<Null> _cancelConnection(BluetoothDevice device) {
    return _channel.invokeMethod('disconnect', device.id.toString());
  }
}

/// State of the bluetooth adapter.
enum BluetoothState {
  unknown,
  unavailable,
  unauthorized,
  turningOn,
  on,
  turningOff,
  off
}

class ScanMode {
  const ScanMode(this.value);
  static const lowPower = const ScanMode(0);
  static const balanced = const ScanMode(1);
  static const lowLatency = const ScanMode(2);
  static const opportunistic = const ScanMode(-1);
  final int value;
}

class DeviceIdentifier {
  final String id;
  const DeviceIdentifier(this.id);

  @override
  String toString() => id;

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(other) =>
      other is DeviceIdentifier && compareAsciiLowerCase(id, other.id) == 0;
}

class ScanResult {
  const ScanResult({this.device, this.advertisementData, this.rssi});

  ScanResult.fromProto(protos.ScanResult p)
      : device = new BluetoothDevice.fromProto(p.device),
        advertisementData =
            new AdvertisementData.fromProto(p.advertisementData),
        rssi = p.rssi;

  final BluetoothDevice device;
  final AdvertisementData advertisementData;
  final int rssi;
}

class AdvertisementData {
  final String localName;
  final List<int> manufacturerData;
  final Map<String, List<int>> serviceData;
  final int txPowerLevel;
  final bool connectable;

  AdvertisementData(
      {this.localName,
      this.manufacturerData,
      this.serviceData,
      this.txPowerLevel,
      this.connectable});

  AdvertisementData.fromProto(protos.AdvertisementData p)
      : localName = p.localName,
        manufacturerData = p.manufacturerData,
        serviceData = new Map.fromIterable(p.serviceData,
            key: (v) => v.key, value: (v) => v.value),
        txPowerLevel = p.txPowerLevel,
        connectable = p.connectable;
}