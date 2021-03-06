// Copyright 2017, Paul DeMarco.
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'login_page.dart';
//import 'package:flutter_blue_example/widgets.dart';
import 'utils.dart';
import 'widgets.dart';
import 'main_page.dart';
import 'dart:developer';
import 'rtu_configure.dart';
import 'dart:io';  //提供Platform接口
import 'package:flutter/services.dart'; //提供SystemUiOverlayStyle

void realRunApp() async {
  bool success = await Utils.getInstance();
  print("init-"+success.toString());
  runApp(MainApp());
}

void main() {
  //runApp(FlutterBlueApp());
  runApp(MainApp());

  if(Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle =
    SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}

class FlutterBlueApp extends StatefulWidget {

  @override
  _FlutterBlueAppState createState() => _FlutterBlueAppState();

}

class _FlutterBlueAppState extends State<FlutterBlueApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.lightBlue,
      home: StreamBuilder<BluetoothState>(
          stream: FlutterBlue.instance.state,
          initialData: BluetoothState.unknown,
          builder: (c, snapshot) {
            final state = snapshot.data;
            if (state == BluetoothState.on) {
              return FindDevicesScreen();
            }
            return BluetoothOffScreen(state: state);
          }),
    );
  }

}

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key key, this.state}) : super(key: key);

  final BluetoothState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.bluetooth_disabled,
              size: 200.0,
              color: Colors.white54,
            ),
            Text(
              'Bluetooth Adapter is ${state.toString().substring(15)}.',
              style: Theme.of(context)
                  .primaryTextTheme
                  .subhead
                  .copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class FindDevicesScreen extends StatefulWidget {

  _FindDevicesScreen createState() => _FindDevicesScreen();
}

class _FindDevicesScreen extends State<FindDevicesScreen>{

  bool isConnected = false;
  BluetoothDevice connectedDevice;

  void showDemoDialog<T>({ BuildContext context, Widget child }) {
    showDialog<T>(
      context: context,
      builder: (BuildContext context) => child,
    );
  }

  void onData(BluetoothState state) {
    print('onData');
  }

  void onError() {
    print('onError');
  }

  void onDone() {
    print('onDone');
  }


  void deviceConnectedData(BluetoothDeviceState state) {
    if(state == BluetoothDeviceState.connected) {
      if(isConnected == false) {
        isConnected = true;
        print('------------BluetoothDeviceState.connected');

        connectedDevice.discoverServices();
        //connectedDevice.services.listen(deviceServicesData);

        Navigator.push(
            context,
            new MaterialPageRoute(builder: (context) => RtuConfigurePage(device: connectedDevice,))
        );
      }
    }
    else if(state == BluetoothDeviceState.disconnected) {
      if(isConnected == true){
        isConnected = false;
        print('------------BluetoothDeviceState.disconnected');
      }
    }
  }

  void scanResultData(List<ScanResult> result){
    result.forEach((r){
      r.device.state.listen(deviceConnectedData, onDone: onDone);
    });
  }

  void onOpenDevice(BluetoothDevice device){
    connectedDevice = device;
    device.state.listen(deviceConnectedData, onDone: onDone);
    device.connect();
  }

  void scanResultDone() {
    print('++++++++++++scanResultDone');
  }

  @override
  void initState(){
    super.initState();
    FlutterBlue flutterBlue = FlutterBlue.instance;

    flutterBlue.state.listen(onData, onDone: onDone);
    //flutterBlue.scanResults.listen(scanResultData, onDone: scanResultDone);

    //Stream.periodic(Duration(seconds: 2))
    //    .asyncMap((_) => FlutterBlue.instance.connectedDevices).listen(onData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('查找设备'),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            FlutterBlue.instance.startScan(timeout: Duration(seconds: 4)),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              /*
              StreamBuilder<List<BluetoothDevice>>(
                stream: Stream.periodic(Duration(seconds: 2))
                    .asyncMap((_) => FlutterBlue.instance.connectedDevices),
                initialData: [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data
                      .map((d) => ListTile(
                    title: Text(d.name),
                    subtitle: Text(d.id.toString()),
                    trailing: StreamBuilder<BluetoothDeviceState>(
                      stream: d.state,
                      initialData:
                      BluetoothDeviceState.disconnected,
                      builder: (c, snapshot) {
                        if (snapshot.data ==
                            BluetoothDeviceState.connected) {
                          return RaisedButton(
                            child: Text('打开'),
                            onPressed: () {
                              connectedDevice = d;
                              return Navigator.of(context)
                                  .push(MaterialPageRoute(
                                  builder: (context) =>
                                      DeviceScreen(device: d)));
                            }
                          );
                        }
                        return Text(snapshot.data.toString());
                      },
                    ),
                  ))
                      .toList(),
                ),
              ),
              */
              StreamBuilder<List<ScanResult>>(
                stream: FlutterBlue.instance.scanResults,
                initialData: [],
                builder: (c, snapshot) {
                  return Column(
                    children: snapshot.data
                        .map(
                          (r) => ScanResultTile(
                        result: r,
                        onTap: (){onOpenDevice(r.device);},
                        /*
                            () {
                          connectedDevice = r.device;
                          r.device.connect();
                          //return Navigator.of(context).push(
                          //    MaterialPageRoute(builder: (context) {
                          //      r.device.connect();
                          //      connectedDevice = r.device;
                          //      return DeviceScreen(device: r.device);
                          //    }));
                        }
                        */
                      ),
                    )
                        .toList(),
                  );
                }
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: FlutterBlue.instance.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data) {
            return FloatingActionButton(
              child: Icon(Icons.stop),
              onPressed: () => FlutterBlue.instance.stopScan(),
              backgroundColor: Colors.red,
            );
          } else {
            return FloatingActionButton(
                child: Icon(Icons.search),
                onPressed: () => FlutterBlue.instance
                    .startScan(timeout: Duration(seconds: 4)));
          }
        },
      ),
    );
  }
}

class DeviceScreen extends StatelessWidget {
  const DeviceScreen({Key key, this.device}) : super(key: key);

  final BluetoothDevice device;

  List<Widget> _buildServiceTiles(List<BluetoothService> services) {
    return services
        .map(
          (s) => ServiceTile(
                service: s,
                characteristicTiles: s.characteristics
                    .map(
                      (c) => CharacteristicTile(
                            characteristic: c,
                            onReadPressed: () => c.read(),
                            onWritePressed: () => c.write([13, 24]),
                            onNotificationPressed: () =>
                                c.setNotifyValue(!c.isNotifying),
                            descriptorTiles: c.descriptors
                                .map(
                                  (d) => DescriptorTile(
                                        descriptor: d,
                                        onReadPressed: () => d.read(),
                                        onWritePressed: () => d.write([11, 12]),
                                      ),
                                )
                                .toList(),
                          ),
                    )
                    .toList(),
              ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(device.name),
        actions: <Widget>[
          StreamBuilder<BluetoothDeviceState>(
            stream: device.state,
            initialData: BluetoothDeviceState.connecting,
            builder: (c, snapshot) {
              VoidCallback onPressed;
              String text;
              switch (snapshot.data) {
                case BluetoothDeviceState.connected:
                  onPressed = () => device.disconnect();
                  text = 'DISCONNECT';
                  break;
                case BluetoothDeviceState.disconnected:
                  onPressed = () => device.connect();
                  text = 'CONNECT';
                  break;
                default:
                  onPressed = null;
                  text = snapshot.data.toString().substring(21).toUpperCase();
                  break;
              }
              return FlatButton(
                  onPressed: onPressed,
                  child: Text(
                    text,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .button
                        .copyWith(color: Colors.white),
                  ));
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            StreamBuilder<BluetoothDeviceState>(
              stream: device.state,
              initialData: BluetoothDeviceState.connecting,
              builder: (c, snapshot) => ListTile(
                    leading: (snapshot.data == BluetoothDeviceState.connected)
                        ? Icon(Icons.bluetooth_connected)
                        : Icon(Icons.bluetooth_disabled),
                    title: Text(
                        'Device is ${snapshot.data.toString().split('.')[1]}.'),
                    subtitle: Text('${device.id}'),
                    trailing: StreamBuilder<bool>(
                      stream: device.isDiscoveringServices,
                      initialData: false,
                      builder: (c, snapshot) => IndexedStack(
                            index: snapshot.data ? 1 : 0,
                            children: <Widget>[
                              IconButton(
                                icon: Icon(Icons.refresh),
                                onPressed: () => device.discoverServices(),
                              ),
                              IconButton(
                                icon: SizedBox(
                                  child: CircularProgressIndicator(
                                    valueColor:
                                        AlwaysStoppedAnimation(Colors.grey),
                                  ),
                                  width: 18.0,
                                  height: 18.0,
                                ),
                                onPressed: null,
                              )
                            ],
                          ),
                    ),
                  ),
            ),
            StreamBuilder<List<BluetoothService>>(
              stream: device.services,
              initialData: [],
              builder: (c, snapshot) {
                return Column(
                  children: _buildServiceTiles(snapshot.data),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
