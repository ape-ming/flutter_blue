import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:convert';
import 'dart:async';
import 'rtu_ble_protocol.dart';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';

@visibleForTesting
enum Location {
  Barbados,
  Bahamas,
  Bermuda
}

typedef DemoItemBodyBuilder<T> = Widget Function(DemoItem<T> item);
typedef ValueToString<T> = String Function(T value);

class DualHeaderWithHint extends StatelessWidget {
  const DualHeaderWithHint({
    this.name,
    this.value,
    this.hint,
    this.showHint,
  });

  final String name;
  final String value;
  final String hint;
  final bool showHint;

  Widget _crossFade(Widget first, Widget second, bool isExpanded) {
    return AnimatedCrossFade(
      firstChild: first,
      secondChild: second,
      firstCurve: const Interval(0.0, 0.6, curve: Curves.fastOutSlowIn),
      secondCurve: const Interval(0.4, 1.0, curve: Curves.fastOutSlowIn),
      sizeCurve: Curves.fastOutSlowIn,
      crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return Row(
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.only(left: 24.0),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                name,
                style: textTheme.body1.copyWith(fontSize: 15.0),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.only(left: 24.0),
            child: _crossFade(
              Text(value, style: textTheme.caption.copyWith(fontSize: 15.0)),
              Text(hint, style: textTheme.caption.copyWith(fontSize: 15.0)),
              showHint,
            ),
          ),
        ),
      ],
    );
  }
}

class CollapsibleBody extends StatelessWidget {
  const CollapsibleBody({
    this.margin = EdgeInsets.zero,
    this.child,
    this.onSave,
    this.onCancel,
  });

  final EdgeInsets margin;
  final Widget child;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return Column(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(
            left: 24.0,
            right: 24.0,
            bottom: 24.0,
          ) - margin,
          child: Center(
            child: DefaultTextStyle(
              style: textTheme.caption.copyWith(fontSize: 15.0),
              child: child,
            ),
          ),
        ),
        const Divider(height: 1.0),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(right: 8.0),
                child: FlatButton(
                  onPressed: onCancel,
                  child: const Text('取消', style: TextStyle(
                    color: Colors.black54,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w500,
                  )),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 8.0),
                child: FlatButton(
                  onPressed: onSave,
                  textTheme: ButtonTextTheme.accent,
                  child: const Text('设置'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DemoItem<T> {
  DemoItem({
    this.name,
    this.value,
    this.hint,
    this.builder,
    this.valueToString,
  }) : textController = TextEditingController(text: valueToString(value));

  final String name;
  final String hint;
  final TextEditingController textController;
  final DemoItemBodyBuilder<T> builder;
  final ValueToString<T> valueToString;
  T value;
  bool isExpanded = false;

  ExpansionPanelHeaderBuilder get headerBuilder {
    return (BuildContext context, bool isExpanded) {
      return DualHeaderWithHint(
        name: name,
        value: valueToString(value),
        hint: hint,
        showHint: isExpanded,
      );
    };
  }

  Widget build() => builder(this);
}

class ElementsTitle extends StatefulWidget{
  ElementsTitle({this.context, this.onTap, this.onDelete});
  final String context;
  final Function onTap;
  final VoidCallback onDelete;

  _ElementsTitleState createState() => _ElementsTitleState();
}

class _ElementsTitleState extends State<ElementsTitle>{
  ElementParam param = ElementParam();

  @override
  void initState() {
    super.initState();
  }

  Widget _buildItem(String title, String text){
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.caption),
          SizedBox(
            width: 12.0,
          ),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context)
                  .textTheme
                  .caption
                  .apply(color: Colors.black),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildItems(){

    RtuBleProtocol protocol = RtuBleProtocol();
    param = protocol.decode(widget.context);

    String scaling;
    if(param.scaling == 0)
      scaling = '无缩放';
    else if(param.scaling < 0){
      int abs = param.scaling.abs();
      scaling = '缩小$abs倍';
    }
    else
      scaling = '放大${param.scaling}倍';
    return <Widget>[
      _buildItem('要素名称', protocol.getNameText(param.name)),
      _buildItem('单位', protocol.getUnitText(param.unit)),
      _buildItem('功能码', protocol.getFuncCodeText(param.fun_code)),
      _buildItem('起始地址', param.start_addr.toString()),
      _buildItem('寄存器个数', param.reg_count.toString()),
      _buildItem('缩放系数', scaling),
    ];
  }

  void onTapHandle(){
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AddElement(param: param,),
    )
        .then<void>((String value) { // The value passed to Navigator.pop() or null.
      if (value != null) {
        String command = "addele $value";
        print('++++++++++++++++'+command);
        widget.onTap(command);
      }
    });
  }

  void onDeleteHandle(){
    showDialog<int>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: Text(
          '确定要删除要素?',
          //style: dialogTextStyle,
        ),
        actions: <Widget>[
          FlatButton(
            child: const Text('取消'),
            onPressed: () { Navigator.pop(context, 0); },
          ),
          FlatButton(
            child: const Text('确定'),
            onPressed: () { Navigator.pop(context, 1); },
          ),
        ],
      ),
    )
      .then<void>((int value) { // The value passed to Navigator.pop() or null.
        if(value == 1){
          RtuBleProtocol protocol = new RtuBleProtocol();
          String command = "delele " + protocol.getNameCode(param.name);
          print('++++++++++++++++'+command);
          widget.onTap(command);
          widget.onDelete();
        }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapHandle,
      child: Stack(
        children: <Widget>[
          Card(
            margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: Padding(
              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: Column(
                  children: _buildItems(),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: Icon(Icons.close),
              onPressed: onDeleteHandle,
            ),
          ),
        ],
      ),
    );
  }
}

class AddElement extends StatefulWidget{

  final ElementParam param;
  final RtuBleProtocol protocol = new RtuBleProtocol();

  AddElement({this.param});

  _AddElement createState() => _AddElement();
}

class _AddElement extends State<AddElement>{
  //拷贝参数
  ElementParam param;
  String _scalingMode;

  void onOkPressed(){
    print('+++++++widget.param:'+param.start_addr.toString());
    String command = widget.protocol.encode(param);

    Navigator.pop(context, command);
  }

  @override
  void initState() {
    super.initState();

    if(widget.param == null)
      param = new ElementParam();
    else
      param = widget.param;

    if(param.scaling <= 0)
      _scalingMode = '缩小';
    else
      _scalingMode = '放大';
  }

  List<PopupMenuItem<T>> _buildSelectItem<T>(var map){
    var list = new List<PopupMenuItem<T>>();
    map.forEach((k, v){
      list.add(PopupMenuItem<T>(
        value: k,
        child: Text(v),
      )
      );
    });
    return list;
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('添加要素'),
      content: Container(
        width: 200,
        height: 300,
        child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(5.0),
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(5.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text('要素名称'),
                        ),
                        PopupMenuButton<element_name>(
                          padding: EdgeInsets.zero,
                          initialValue: param.name,
                          onSelected: (value){setState(() {
                            param.name = value;
                          });},
                          child: Row(
                            children: <Widget>[
                              Text(widget.protocol.getNameText(param.name)),
                              Icon(Icons.keyboard_arrow_down),
                            ],
                          ),
                          itemBuilder: (BuildContext context) => _buildSelectItem(widget.protocol.getNameMap()),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(5.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text('单位'),
                        ),
                        PopupMenuButton<element_unit>(
                          padding: EdgeInsets.zero,
                          initialValue: param.unit,
                          onSelected: (value){setState(() {
                            param.unit = value;
                          });},
                          child: Row(
                            children: <Widget>[
                              Text(widget.protocol.getUnitText(param.unit)),
                              Icon(Icons.keyboard_arrow_down),
                            ],
                          ),
                          itemBuilder: (BuildContext context) => _buildSelectItem(widget.protocol.getUnitMap()),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(5.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text('功能码'),
                        ),
                        PopupMenuButton<element_fun_code>(
                          padding: EdgeInsets.zero,
                          initialValue: param.fun_code,
                          onSelected: (value){setState(() {
                            param.fun_code = value;
                          });},
                          child: Row(
                            children: <Widget>[
                              Text(widget.protocol.getFuncCodeText(param.fun_code)),
                              Icon(Icons.keyboard_arrow_down),
                            ],
                          ),
                          itemBuilder: (BuildContext context) => _buildSelectItem(widget.protocol.getFuncCodeMap()),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(5.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text('寄存器个数'),
                        ),
                        PopupMenuButton<int>(
                          padding: EdgeInsets.zero,
                          initialValue: param.reg_count,
                          onSelected: (value){setState(() {
                            param.reg_count = value;
                          });},
                          child: Row(
                            children: <Widget>[
                              Text(param.reg_count.toString()),
                              Icon(Icons.keyboard_arrow_down),
                            ],
                          ),
                          itemBuilder: (BuildContext context) => <PopupMenuItem<int>>[
                            PopupMenuItem<int>(
                              value: 1,
                              child: Text(1.toString()),
                            ),
                            PopupMenuItem<int>(
                              value: 2,
                              child: Text(2.toString()),
                            ),
                            PopupMenuItem<int>(
                              value: 3,
                              child: Text(3.toString()),
                            ),
                            PopupMenuItem<int>(
                              value: 4,
                              child: Text(4.toString()),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(5.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text('缩放模式'),
                        ),
                        PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          initialValue: _scalingMode,
                          onSelected: (value){setState(() {
                            _scalingMode = value;
                          });},
                          child: Row(
                            children: <Widget>[
                              Text(_scalingMode),
                              Icon(Icons.keyboard_arrow_down),
                            ],
                          ),
                          itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
                            PopupMenuItem<String>(
                              value: '缩小',
                              child: Text('缩小'),
                            ),
                            PopupMenuItem<String>(
                              value: '放大',
                              child: Text('放大'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 5.0, right: 5.0, bottom: 5.0),
                    child:TextField(
                        controller: TextEditingController(text: param.start_addr.toString()),
                        keyboardType: TextInputType.number,
                        maxLength: 5,
                        inputFormatters: [
                          WhitelistingTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          hintText: '输入起始地址',
                          labelText: '起始地址',
                        ),
                        onChanged: (str){param.start_addr = int.parse(str);}
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 5.0, right: 5.0, bottom: 5.0),
                    child:TextField(
                      controller: TextEditingController(text: param.scaling.abs().toString()),
                      keyboardType: TextInputType.number,
                      maxLength: 5,
                      inputFormatters: [
                        WhitelistingTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        hintText: '输入缩放倍数',
                        labelText: '缩放倍数',
                      ),
                      onChanged: (str){
                        param.scaling = int.parse(str);
                        if(_scalingMode == '缩小')
                          param.scaling = -param.scaling;
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 20.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: OutlineButton(
                            child: const Text('保存'),
                            onPressed: onOkPressed,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            )
        ),
      ),
    );
  }
}

class RtuConfigurePage extends StatefulWidget{
  const RtuConfigurePage({Key key, this.device}) : super(key: key);

  final BluetoothDevice device;

  _RtuConfigurePageState createState() => _RtuConfigurePageState();
}

class _RtuConfigurePageState extends State<RtuConfigurePage>{
  List<DemoItem<dynamic>> _demoItems;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  BluetoothService service;
  List<BluetoothCharacteristic> characteristics;
  BluetoothCharacteristic readCharacter;
  BluetoothCharacteristic writeCharacter;
  List<String> elementItems = new List<String>();

  final StreamController<List<String>> _streamController = StreamController<List<String>>();

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(value),
      duration: Duration(seconds: 1),
    ));
  }

  void showDemoDialog<T>({ BuildContext context, Widget child }) {
    showDialog<T>(
      context: context,
      builder: (BuildContext context) => child,
    )
        .then<void>((T value) { // The value passed to Navigator.pop() or null.
      if (value != null) {
        String command = "addele $value";
        print('++++++++++++++++'+command);
        showInSnackBar(command);
        writeCharacter.write(utf8.encode(command));
      }
    });
  }

  void _bleDataHandle(String data){
    if(data.startsWith('ele: ')){
      List<String> eleList = new List<String>();
      List<String> streamList = new List<String>();
      eleList = data.split('\r\n');

      setState(() {
        if(elementItems.isNotEmpty){
          elementItems.clear();
        }
      });

      eleList.forEach((e){
        if(e.isNotEmpty){
          streamList.add(e);
          setState(() {
            elementItems.add(e);
          });
        }
      });

      //_streamController.sink.add(streamList);
    }
  }

  void _onCharacterValue(List<int> value){
    if(value.length > 2){
      String data = utf8.decode(value);
      print('++++++++received:'+ data);
      _bleDataHandle(data);
      //showInSnackBar(data);
    }
  }

  void _onServicesData(List<BluetoothService> services){
    if(services.length > 0){
        services.forEach((s){
          String uuid = '0x${s.uuid.toString().toUpperCase().substring(4, 8)}';
          if(int.parse(uuid) == 0x01){
            service = s;
            characteristics = s.characteristics;
            characteristics.forEach((c){
              String character = '0x${c.uuid.toString().toUpperCase().substring(4, 8)}';
              if(int.parse(character) == 0x02){
                if(writeCharacter == null){
                  writeCharacter = c;
                  print('++++++++find writeCharacter');
                }
              }
              else if(int.parse(character) == 0x03){
                if(readCharacter == null){
                  readCharacter = c;
                  c.setNotifyValue(true);
                  c.value.listen(_onCharacterValue);
                  print('++++++++find readCharacter');
                }
              }
            });
          }
          print('--------service:' + uuid);
      });
    }
  }

  Widget _buildForm(DemoItem<String> item, VoidCallback close, VoidCallback onSaved){
    return Form(
      child: Builder(
        builder: (BuildContext context) {
          return CollapsibleBody(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            onSave: () { Form.of(context).save(); close(); },
            onCancel: () { Form.of(context).reset(); close(); },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextFormField(
                controller: item.textController,
                decoration: InputDecoration(
                  hintText: item.hint,
                  labelText: item.name,
                ),
                onSaved: (String value) {
                  item.value = value;
                  onSaved();
                },
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    widget.device.services.listen(_onServicesData);

    _demoItems = <DemoItem<dynamic>>[
      DemoItem<String>(
        name: '站地址',
        value: '',
        hint: '输入站地址',
        valueToString: (String value) => value,
        builder: (DemoItem<String> item) {
          void close() {
            setState(() {
              item.isExpanded = false;
            });
          }
          return _buildForm(item, close, (){
            String command = "setport ${item.value}";
            print('+++++++++send value:'+command);
            writeCharacter.write(utf8.encode(command));
          });
        },
      ),
      DemoItem<String>(
        name: '中心站IP',
        value: '',
        hint: '输入IP地址',
        valueToString: (String value) => value,
        builder: (DemoItem<String> item) {
          void close() {
            setState(() {
              item.isExpanded = false;
            });
          }
          return _buildForm(item, close, (){
            String command = "setceip ${item.value}";
            print('+++++++++send value:'+command);
            writeCharacter.write(utf8.encode(command));
          });
        },
      ),
      /*
      DemoItem<Location>(
        name: 'Location',
        value: Location.Bahamas,
        hint: 'Select location',
        valueToString: (Location location) => location.toString().split('.')[1],
        builder: (DemoItem<Location> item) {
          void close() {
            setState(() {
              item.isExpanded = false;
            });
          }
          return Form(
            child: Builder(
                builder: (BuildContext context) {
                  return CollapsibleBody(
                    onSave: () { Form.of(context).save(); close(); },
                    onCancel: () { Form.of(context).reset(); close(); },
                    child: FormField<Location>(
                      initialValue: item.value,
                      onSaved: (Location result) { item.value = result; },
                      builder: (FormFieldState<Location> field) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            RadioListTile<Location>(
                              value: Location.Bahamas,
                              title: const Text('Bahamas'),
                              groupValue: field.value,
                              onChanged: field.didChange,
                            ),
                            RadioListTile<Location>(
                              value: Location.Barbados,
                              title: const Text('Barbados'),
                              groupValue: field.value,
                              onChanged: field.didChange,
                            ),
                            RadioListTile<Location>(
                              value: Location.Bermuda,
                              title: const Text('Bermuda'),
                              groupValue: field.value,
                              onChanged: field.didChange,
                            ),
                          ],
                        );
                      },
                    ),
                  );
                }
            ),
          );
        },
      ),
      DemoItem<double>(
        name: 'Sun',
        value: 80.0,
        hint: 'Select sun level',
        valueToString: (double amount) => '${amount.round()}',
        builder: (DemoItem<double> item) {
          void close() {
            setState(() {
              item.isExpanded = false;
            });
          }

          return Form(
            child: Builder(
                builder: (BuildContext context) {
                  return CollapsibleBody(
                    onSave: () { Form.of(context).save(); close(); },
                    onCancel: () { Form.of(context).reset(); close(); },
                    child: FormField<double>(
                      initialValue: item.value,
                      onSaved: (double value) { item.value = value; },
                      builder: (FormFieldState<double> field) {
                        return Slider(
                          min: 0.0,
                          max: 100.0,
                          divisions: 5,
                          activeColor: Colors.orange[100 + (field.value * 5.0).round()],
                          label: '${field.value.round()}',
                          value: field.value,
                          onChanged: field.didChange,
                        );
                      },
                    ),
                  );
                }
            ),
          );
        },
      ),
      */
    ];
  }

  Widget _buildElementTile(String data){
    return Row(
      children: <Widget>[
        Expanded(
          child: ElementsTitle(
            context: data,
            onDelete: (){
              setState(() {
                elementItems.remove(data);
              });
            },
            onTap: (value){
              writeCharacter.write(utf8.encode(value));
              showInSnackBar(value);
            },),
        )
      ],
    );
  }

  @override
  void dispose() {
    _streamController.close();
    widget.device.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget elements;
    if(elementItems.isEmpty){
      elements = Center(
        child: Text(' '),
      );
    }
    else{
      elements = Column(
        children: elementItems.map<Widget>((i){
          return _buildElementTile(i);
        }).toList(),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('RTU配置'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: (){},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          top: false,
          bottom: false,
          child: Container(
            margin: const EdgeInsets.all(24.0),
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(bottom: 10.0),
                  child: ExpansionPanelList(
                    expansionCallback: (int index, bool isExpanded) {
                      setState(() {
                        _demoItems[index].isExpanded = !isExpanded;
                      });
                    },
                    children: _demoItems.map<ExpansionPanel>((DemoItem<dynamic> item) {
                      return ExpansionPanel(
                        isExpanded: item.isExpanded,
                        headerBuilder: item.headerBuilder,
                        body: item.build(),
                      );
                    }).toList(),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlineButton.icon(
                        icon: const Icon(Icons.add, size: 18.0),
                        label: const Text('添加要素'),
                        onPressed: () {
                          showDemoDialog<String>(
                            context: context,
                            child: AddElement(),
                          );
                        },
                      ),
                    )
                  ],
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlineButton.icon(
                        icon: const Icon(Icons.search, size: 18.0),
                        label: const Text('查询所有要素'),
                        onPressed: () {
                          String command = "cateles";
                          writeCharacter.write(utf8.encode(command));
                        },
                      ),
                    )
                  ],
                ),

                elements,

                /*
                StreamBuilder<List<String>>(
                  stream: _streamController.stream,
                  initialData: [ ],
                  builder: (c, snapshot) {
                    return Column(
                      children: snapshot.data
                          .map((d) => _buildElementTile(d),
                        )
                        .toList(),
                    );
                  },
                ),
                */
              ],
            ),
          ),
        ),
      ),
    );
  }
}



