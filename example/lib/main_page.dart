
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'login_page.dart';

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
import 'loading_page.dart';

class DioData{
  static _filtration(Response response,callBack(t)){
    if(response.statusCode==200){
      callBack(response.data);
    }else {
      callBack(null);
    }
  }
  //app_server/GetJsonValue?username=$name&password=$password&SearName=rtu_id&SearValue=$id&n=20
  static monitorData(int id, String name, String password, int count, callBack(t)) async{
    print('request:' + id.toString());
    //var response = await HttpHelper().request("Tools/DataHandler.ashx?action=getjsonvalue&SearName=rtu_id&SearValue=$id&n=500");
    var response = await HttpHelper().request("GetJsonValue?username=$name&password=$password&SearName=rtu_id&SearValue=$id&n=$count");
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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(_style);
    return MaterialApp(

      debugShowCheckedModeBanner: false,
      title: 'RTU调试',
      /*home: FutureBuilder(
        builder: _buildFuture,
        future:  _futureBuilderFuture, // 用户定义的需要异步执行的代码，类型为Future<String>或者null的变量或函数
      ),*/
      home: LoadingPage(),
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
                height: 150,
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
  final String userName;
  final String password;
  final int role;

  HomePage(this.userName, this.password, this.role);

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  static const int _maxCount  = 500;

  static const int _roleAdmin = 1;
  static const int _roleUser  = 2;

  static const int _addDevice = 1;
  static const int _rtuDebug  = 2;
  static const int _ttDebug   = 3;
  static const int _logout    = 4;
  List<int> monitorId = new List<int>();
  List<Entity> _entityList;
  List<MonitorData> monitorDataList = new List<MonitorData>();

  _getMonitorIdLocal() async{
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

    //_handleRefresh();
    _getStationData(_maxCount);
  }


  _stationRequest(String name, String password, callBack(t)) async{
    var response = await HttpHelper().request("GetStationServlet?username=$name&password=$password");
    if(response != null){
      callBack(response.data);
    }else{
      //showInSnackBar('网络连接失败，请检查网络连接！');
    }
  }

  Future<void> _getMonitorIdRemote(String name, String password) async {
    await _stationRequest(name, password, (t) {

      Map<String, dynamic> user = json.decode(t);

      if(user.containsKey('isExist')){
        if(user['isExist']){
          List<dynamic> stations = user['stations'];
          setState(() {
            monitorId.clear();
            if((stations != null) && stations.isNotEmpty){
              stations.forEach((f){
                monitorId.add(int.parse(f));
              });
            }
            if(monitorDataList.isNotEmpty){
              for(int i = 0; i < monitorDataList.length; i++){
                int id = monitorDataList.elementAt(i).getRtuId();
                if(!stations.contains(id.toString())){
                  monitorDataList.removeAt(i);
                }
              }
            }
          });
        }
      }
      //showInSnackBar('用户名或密码错误！');
    });
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

  _setLogoutStatus() async{
    var prefs = await SharedPreferences.getInstance();
    await prefs.setBool('login', false);
  }

  @override
  void initState() {
    super.initState();

    if(widget.userName != null && widget.password != null){
      print("user name:" + widget.userName);
      print("password:" + widget.password);
      print('role:' + widget.role.toString());
    }

    if(widget.role == _roleAdmin){
      _getMonitorIdLocal();
    }else if(widget.role == _roleUser){
      _getMonitorIdRemote(widget.userName, widget.password).then((_){
        _getStationData(_maxCount);
      });
    }
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
    else if(value == _logout){
      // 弹出对话框
      showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("提示"),
            content: Text("您确定要退出当前登录吗?"),
            actions: <Widget>[
              FlatButton(
                child: Text("取消"),
                onPressed: () => Navigator.of(context).pop(), // 关闭对话框
              ),
              FlatButton(
                child: Text("确定"),
                onPressed: () {
                  //关闭对话框并返回true
                  //Navigator.of(context).pop(true);
                  _setLogoutStatus();
                  Navigator.of(context).pushAndRemoveUntil(
                      new MaterialPageRoute(builder: (context) => new LoginPage()),
                          (route) => route == null);
                },
              ),
            ],
          );
        },
      );
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

  Future<void> _getData(int id, int count) async {
    await DioData.monitorData(id, widget.userName, widget.password, count, (t) {
      _entityList = t;
    });

    if(_entityList != null){
      //刷新界面
      setState(() {
        if(_entityList.isNotEmpty && (_entityList.length > 0 )){
          _onMonitorListUpdate(_entityList);
        }
      });
    }
  }

   _getStationData(int count) async{
    if(monitorId.isNotEmpty && monitorId.length > 0){
      for(int i = 0; i < monitorId.length; i++){
        print("monitorId:" + monitorId[i].toString());
        await _getData(monitorId[i], count);
      }
    }
  }

  Future<void> _handleManualRefresh() async{
    final Completer<Null> completer = new Completer<Null>();

    if(widget.role == _roleAdmin){
      //await _getStationData(2);
      await _getStationData(_maxCount);
    }else if(widget.role == _roleUser){
      await _getMonitorIdRemote(widget.userName, widget.password);
      await _getStationData(_maxCount);
    }

    //await Future.delayed(Duration(seconds: 3), (){});
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
          return RtuDeviceCard(d.getFirstEntity(),
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

    Widget _buildIcon(){
      if(widget.role == _roleAdmin){
        return Icon(Icons.add);
      }
      else{
        return Icon(Icons.more_vert);
      }
    }

    List<PopupMenuItem<int>> _buildItems(BuildContext context)
    {
      List<PopupMenuItem<int>> list = new List<PopupMenuItem<int>>();
      if(widget.role == _roleAdmin){
        list.add(const PopupMenuItem<int>(
          value: _addDevice,
          child: ListTile(
            leading: Icon(Icons.add_to_queue),
            title: Text('添加设备'),
          ),
        ));
        list.add(const PopupMenuItem<int>(
          value: _rtuDebug,
          child: ListTile(
            leading: Icon(Icons.settings),
            title: Text('RTU配置'),
          ),
        ));
      }

      list.add(PopupMenuItem<int>(
          value: _logout,
          child: Center(
            child: Text('退出登录',
              style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.red),
            ),
          )
      ));

      return list;
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('在线监测'),
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<int>(
            icon: _buildIcon(),
            onSelected: showMenuSelection,
            itemBuilder: (BuildContext context) => _buildItems(context),
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
        onRefresh: _handleManualRefresh,
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
                    child: Text(int.parse(widget.data.rtuId).toString(),
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














