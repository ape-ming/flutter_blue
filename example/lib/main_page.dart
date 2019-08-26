
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'data_table_page.dart';
import 'main.dart';
import 'http_helper.dart';
import 'package:dio/dio.dart';
import 'entity.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'monitor_data.dart';
import 'rtu_ble_protocol.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class DioData{
  static _filtration(Response response,callBack(t)){
    if(response.statusCode==200){
      callBack(response.data);
    }else {
      callBack(null);
    }
  }
  static monitorData(int id, callBack(t)) async{
    print('request:' + id.toString());
    var response = await HttpHelper().request("Tools/DataHandler.ashx?action=getjsonvalue&SearName=rtu_id&SearValue=$id");
    if(response != null){
      print(response.data);
      List<Entity> list = getEntityList(json.decode(response.data));
      callBack(list);
    }
  }
}

class MainApp extends StatefulWidget{

  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp>{
  final SystemUiOverlayStyle _style =
  SystemUiOverlayStyle(statusBarColor: Colors.transparent);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(_style);
    return MaterialApp(

      debugShowCheckedModeBanner: false,
      title: 'RTU调试',
      home: new HomePage(),
      localizationsDelegates: [
        //此处
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        //此处
        const Locale('zh', 'CH'),
        const Locale('en', 'US'),
      ],
      locale: Locale('zh'),
    );
  }
}

class AddDevice extends StatefulWidget{
  final List<int> deviceList;
  final Function onAdd;
  final Function onRemove;
  AddDevice(this.deviceList, {this.onAdd, this.onRemove});

  _AddDeviceState createState() => _AddDeviceState();
}

class _AddDeviceState extends State<AddDevice>{
  int address;
  List<int> deviceList;
  TextEditingController addressController = new TextEditingController();

  Widget devices(int id, VoidCallback onMove){
    return ListTile(
      title: Text(id.toString()),
      leading: Icon(Icons.devices, color: Colors.blue,),
      trailing: IconButton(
        icon: Icon(Icons.clear, color: Colors.grey,),
        onPressed: onMove,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    deviceList = widget.deviceList;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('添加站地址'),
      content: Container(
        width: 200,
        height: 300,
        child: SingleChildScrollView(
          //padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              TextField(
                //controller: TextEditingController(text: param.start_addr.toString()),
                  keyboardType: TextInputType.number,
                  maxLength: 8,
                  inputFormatters: [
                    WhitelistingTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    hintText: '输入站地址',
                    labelText: '站地址',
                  ),
                  onChanged: (str){
                    address = int.parse(str);
                  }
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlineButton.icon(
                      icon: const Icon(Icons.add, size: 18.0),
                      label: const Text('添加'),
                      onPressed: () {
                        if(address > 0){
                          //widget.onAdd(address);
                          setState(() {
                            if(!deviceList.contains(address)){
                              deviceList.add(address);
                              widget.onAdd(address);
                            }
                          });
                        }
                      },
                    ),
                  )
                ],
              ),
              //Text('已添加站地址'),
              SizedBox(
                height: 200,
                child: ListView(
                  children: deviceList.map((d){
                    return devices(d, (){
                      setState(() {
                        if(deviceList.contains(d)){
                          deviceList.remove(d);
                        }
                        widget.onRemove(d);
                      });
                    });
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget{

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  static const int _addDevice = 1;
  static const int _rtuDebug  = 2;
  static const int _ttDebug   = 3;
  List<int> monitorId = new List<int>();
  List<Entity> _entityList;
  List<MonitorData> monitorDataList = new List<MonitorData>();

  _getMonitorId() async{
    List<String> list;

    var prefs = await SharedPreferences.getInstance();

    list = prefs.getStringList('monitor_id');

    print('monitor_id list');
    print(list.toString());

    setState(() {
      monitorId.clear();
      if((list != null) && list.isNotEmpty){
        list.forEach((f){
          monitorId.add(int.parse(f));
        });
      }
    });

    _handleRefresh();
  }

  _setMonitorId() async{
    List<String> list = new List<String>();

    var prefs = await SharedPreferences.getInstance();

    if(monitorId.isNotEmpty){
      monitorId.forEach((f){
        list.add(f.toString());
      });
    }

    print('monitor_id list set');
    print(list.toString());

    await prefs.setStringList('monitor_id', list);
  }

  @override
  void initState() {
    super.initState();
    _getMonitorId();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void showDemoDialog<T>({ BuildContext context, Widget child }) {
    showDialog<T>(
      context: context,
      builder: (BuildContext context) => child,
    )
        .then<void>((T value) {
      if (value != null) {
        //showInSnackBar(command);
        //writeCharacter.write(utf8.encode(command));
      }
    });
  }

  void showMenuSelection(int value) {
    MonitorData e;

    if(value == _addDevice){
      showDemoDialog(
          context: context,
          child: AddDevice(monitorId,
            onAdd: (d){
              if(!monitorId.contains(d)){
                monitorId.add(d);
              }
              _setMonitorId();
            },
            onRemove: (device){
              setState(() {
                if(monitorId.contains(device)){
                  monitorId.remove(device);
                }

                _setMonitorId();

                if(monitorDataList.isNotEmpty){
                  monitorDataList.forEach((m){
                    if(m.getRtuId() == device){
                      e = m;
                    }
                  });
                  if(e != null){
                    monitorDataList.remove(e);
                  }
                }
              });
            },
          ));
    }
    else if(value == _rtuDebug){
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

  void _onMonitorListUpdate(List<Entity> data){
    bool exist = false;
    int index;

    if(monitorDataList.isEmpty){
      monitorDataList.add(new MonitorData(data));
    }
    else{
      monitorDataList.forEach((m){
        if(m.getRtuId() == int.parse(data[0].rtuId)){
          exist = true;
          index = monitorDataList.indexOf(m);
        }
      });

      if(exist == false){
        monitorDataList.add(new MonitorData(data));
      }
      else{
        monitorDataList[index].update(data);
      }
    }

    print('monitorDataList len:' + monitorDataList.length.toString());
  }

  Future<void> _getData(int id) async {
    await DioData.monitorData(id, (t) {
      _entityList = t;
      //print(_entityList[_entityList.length - 1].id.toString());
    });

    if(_entityList != null){
      print('getData OK');
    }
    else{
      print('getData timeout');
    }

    if(_entityList != null){
      //刷新界面
      setState(() {
        if(_entityList.isNotEmpty && (_entityList.length > 0 )){
          _onMonitorListUpdate(_entityList);
        }
      });
    }
  }

  Future<void> _handleRefresh() async{
    final Completer<Null> completer = new Completer<Null>();

    if(monitorId.isNotEmpty && monitorId.length > 0){
      for(int i = 0; i < monitorId.length; i++){
        await _getData(monitorId[i]);
      }
    }

    completer?.complete();

    return completer.future;
  }

  void onMonitorListRemove(Entity d){
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
          monitorDataList.remove(d);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if(monitorDataList.isEmpty){
      body = Center(
        child: Text('无数据'),
      );
    }
    else{
      body = ListView(
        //physics: BouncingScrollPhysics(),
        physics: AlwaysScrollableScrollPhysics(),
        children: monitorDataList.map((d){
          return RtuDeviceCard(d.getLastEntity(),
            onTap: (){
              Navigator.push(
                  context,
                  new MaterialPageRoute(builder: (context) => DataTablePage(d.getRtuId(), d.getType(), d.getEntityList()))
              );
            //onMonitorListRemove(d);
            },
          );
        }).toList(),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('RTU调试'),
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<int>(
            icon: Icon(Icons.add),
            onSelected: showMenuSelection,
            itemBuilder: (BuildContext context) => <PopupMenuItem<int>>[
              const PopupMenuItem<int>(
                value: _addDevice,
                child: ListTile(
                  leading: Icon(Icons.add_to_queue),
                  title: Text('添加设备'),
                ),
              ),
              const PopupMenuItem<int>(
                value: _rtuDebug,
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('RTU配置'),
                ),
              ),
            ],
          ),
        ],

      ),

      /*
      PreferredSize(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.yellow, Colors.pink])),
            child: SafeArea(child: Text("1212")),
          ),
          preferredSize: Size(double.infinity, 60)
      ),
      */

      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.refresh),
          onPressed: (){
            _refreshIndicatorKey.currentState.show();
          },
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _handleRefresh,
        child: Padding(
          padding: EdgeInsets.only(top: 10.0, bottom: 20.0),
          child: body,
        )
      ),
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
  final Entity data;
  final VoidCallback onTap;
  RtuDeviceCard(this.data, {this.onTap});
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

  List<Widget> deviceItemsList(Entity data){
    List<Widget> list = new List<Widget>();

    if(data.flowVelocity >= 0){
      list.add(deviceItem(Icons.ac_unit, '流速', data.flowVelocity.toString(), 'm/s'));
    }
    if(data.airHeight >= 0){
      list.add(deviceItem(Icons.map, '空高', data.airHeight.toString(), 'm'));
    }
    if(data.waterLevel >= 0){
      list.add(deviceItem(Icons.add_alarm, '水位', data.waterLevel.toString(), 'm'));
    }
    if(data.flowVelSigIntens >= 0){
      list.add(deviceItem(Icons.add_alarm, '流速信号强度', data.flowVelSigIntens.toString(), ' '));
    }
    if(data.watLevSigIntens >= 0){
      list.add(deviceItem(Icons.add_alarm, '水位信号强度', data.watLevSigIntens.toString(), ' '));
    }
    if(data.flowRateInstant >= 0){
      list.add(deviceItem(Icons.add_alarm, '瞬时流量', data.flowRateInstant.toString(), 'm³/s'));
    }
    if(data.flowRateTotal >= 0){
      list.add(deviceItem(Icons.add_alarm, '累计流量', data.flowRateTotal.toString(), 'm³'));
    }
    if(data.powerVol >= 0){
      list.add(deviceItem(Icons.add_alarm, '供电电压', data.powerVol.toString(), 'V'));
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
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
                    child: Text(int.parse(widget.data.monitPonitId).toString(),
                      style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.black),
                    ),
                  ),
                  GestureDetector(
                    //onTap: widget.onTap,
                    child: Icon(Icons.keyboard_arrow_right, color: Colors.grey,),
                  ),
                ],
              ),
            ),
            Divider(),
            Padding(
              padding: EdgeInsets.only(bottom: 10.0),
              child: Column(
                children: <Widget>[
                  Column(
                    children: deviceItemsList(widget.data),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 5, bottom: 3, left: 20.0),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.query_builder, size: 13.0, color: Colors.grey,),
                        Text(' 更新时间:  ',
                          style: Theme.of(context).textTheme.caption.copyWith(color: Colors.grey),
                        ),
                        Text(widget.data.collectTime.replaceAll(new RegExp(r'T'), ' '),
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














