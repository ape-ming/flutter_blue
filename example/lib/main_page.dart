
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_example/monitor_data.dart';
import 'main.dart';
import 'rtu_configure.dart';
import 'dart:developer' as developer;
import 'monitor_data.dart';

class MainApp extends StatefulWidget{

  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp>{

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RTU调试',
      home: new HomePage(),
    );
  }
}

class HomePage extends StatefulWidget{

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{
  static const int _addDevice = 1;
  static const int _rtuDebug  = 2;
  static const int _ttDebug   = 3;
  List<MonitorData> monitor_data_list = new List<MonitorData>();

  @override
  void initState() {
    super.initState();
    MonitorData data = new MonitorData();
    monitor_data_list.add(data);
  }

  void showMenuSelection(int value) {
    if(value == _rtuDebug){
      Navigator.push(
          context,
          new MaterialPageRoute(builder: (context) => FindDevicesScreen())
          );
    }
    else if(value == _ttDebug) {
      //Navigator.push(
      //    context,
       //   new MaterialPageRoute(builder: (context) => RtuConfigurePage())
      //);
    }
  }

  void onMonitorListRemove(MonitorData d){
    showDialog<int>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: Text(
          '是否要移除当前设备?',
          //style: dialogTextStyle,
        ),
        actions: <Widget>[
          FlatButton(
            child: const Text('否'),
            onPressed: () { Navigator.pop(context, 0); },
          ),
          FlatButton(
            child: const Text('是'),
            onPressed: () { Navigator.pop(context, 1); },
          ),
        ],
      ),
    ).then<void>((int value) { // The value passed to Navigator.pop() or null.
      if(value == 1){
        setState(() {
          monitor_data_list.remove(d);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if(monitor_data_list.isEmpty){
      body = Center(
        child: Text('没有添加任何设备'),
      );
    }
    else{
      body = ListView(
        children: monitor_data_list.map((d){
          return RtuDeviceCard(d,
            onDelete: (){onMonitorListRemove(d);},
          );
        }).toList(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('RTU调试'),
        actions: <Widget>[
          PopupMenuButton<int>(
            icon: Icon(Icons.settings),
            onSelected: showMenuSelection,
            itemBuilder: (BuildContext context) => <PopupMenuItem<int>>[
              const PopupMenuItem<int>(
                value: _rtuDebug,
                child: Text('RTU配置'),
              ),
              const PopupMenuItem<int>(
                value: _ttDebug,
                child: Text('设备透传调试'),
              ),
            ],
          ),
        ],

      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: (){
            MonitorData data;
            setState(() {
              monitor_data_list.add(data);
            });
          },
      ),
      body: body,
      /*
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            UserAccountsDrawerHeader(
              currentAccountPicture: new CircleAvatar(
                backgroundImage: new AssetImage('packages/flutter_gallery_assets/logos/flutter_white/logo.png'),

              ),
            ),
            ListTile(
              leading: new CircleAvatar(child: Text('1'),),
              title: Text('RTU配置'),
            ),
            ListTile(
              leading: new CircleAvatar(child: Text('2'),),
              title: Text('透传调试'),
            ),

          ],
        ),
      ),
       */
    );
  }
}

class RtuDeviceCard extends StatefulWidget{
  final MonitorData data;
  final VoidCallback onDelete;
  RtuDeviceCard(this.data, {this.onDelete});
  _RtuDeviceCardState createState() => _RtuDeviceCardState();
}

class _RtuDeviceCardState extends State<RtuDeviceCard>{
  Widget deviceItem(IconData icon, String title, String value, String tail){
    return Padding(
      padding: EdgeInsets.only(top: 3, bottom: 3, left: 10.0, right: 10.0),
      child: Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 10.0),
            //child: Icon(icon, color: Colors.blue,),
          ),
          Expanded(
            child: Text(title,
              style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.black),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 10.0),
            child: Text(value,
              style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.blue),
            )
          ),
          SizedBox(
            width: 40,

            child: Text(tail,
              style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Card(
        margin: EdgeInsets.only(top: 5.0, bottom: 5.0, left: 20.0, right: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 5.0, left: 10.0, right: 5.0),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(right: 10.0),
                    child: Icon(Icons.devices, color: Colors.blue,),
                  ),
                  Expanded(
                    child: Text('6001',
                      style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.black),
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onDelete,
                    child: Icon(Icons.clear, color: Colors.grey,),
                  ),
                ],
              ),
            ),
            Divider(),
            Padding(
              padding: EdgeInsets.only(bottom: 10.0),
              child: Column(
                children: <Widget>[
                  deviceItem(Icons.ac_unit, '流速', '1.234', 'm/s'),
                  deviceItem(Icons.map, '空高', '11.234', 'm'),
                  deviceItem(Icons.add_alarm, '水位', '3.256', 'm'),
                  deviceItem(Icons.add_alarm, '信号强度', '5565', ' '),
                  Padding(
                    padding: EdgeInsets.only(top: 5, bottom: 3, left: 20.0),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.query_builder, size: 13.0, color: Colors.grey,),
                        Text(' 更新时间:  ',
                          style: Theme.of(context).textTheme.caption.copyWith(color: Colors.grey),
                        ),
                        Text('2019-5-10 12:24:36',
                          style: Theme.of(context).textTheme.caption.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}














