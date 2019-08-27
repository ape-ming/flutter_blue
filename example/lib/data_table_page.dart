import 'package:flutter/material.dart';
import 'entity.dart';
import 'monitor_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';

class LineChartView extends StatefulWidget{
  List<Entity> _entityList;
  MonitorType _type;

  LineChartView(MonitorType type, List<Entity> entityList){
    _type = type;
    _entityList = entityList.reversed.toList();
  }
  _LineChartViewState createState() => _LineChartViewState();
}

class _LineChartViewState extends State<LineChartView> {
  List<Entity> _entityList;
  MonitorType _type;
  final int _maxCount = 100;

  List<FlSpot> _airHeightSpot;
  List<FlSpot> _waterLevelSpot;
  List<FlSpot> _flowVelocitySpot;
  List<FlSpot> _flowVelSigIntensSpot;
  List<FlSpot> _watLevSigIntensSpot;

  double _maxAirHeight = 0;
  double _maxWaterLevel = 0;
  double _maxFlowVelocity = 0;
  double _maxFlowVelSigIntens = 0;
  double _maxWatLevSigIntens = 0;

  void initState() {
    super.initState();
    _entityList = widget._entityList;
    _type = widget._type;

    _airHeightSpot = airHeightSpot();
    _waterLevelSpot = waterLevelSpot();
    _flowVelocitySpot = flowVelocitySpot();
    _flowVelSigIntensSpot = flowVelSigIntensSpot();
    _watLevSigIntensSpot = watLevSigIntensSpot();
  }

  List<FlSpot> airHeightSpot(){
    List<FlSpot> spots = new List<FlSpot>();

    if(_entityList.isNotEmpty && _entityList.length > 0){
      int length = _maxCount > _entityList.length ? _entityList.length : _maxCount;
      for(int i = 0; i < length; i++){
        double data = _entityList[length - i - 1].airHeight < 0 ? 0 : _entityList[length - i - 1].airHeight;
        spots.add(FlSpot(i.toDouble(), data));
        if(data > _maxAirHeight)
          _maxAirHeight = data;
      }
    }
    return spots;
  }

  List<FlSpot> waterLevelSpot(){
    List<FlSpot> spots = new List<FlSpot>();

    if(_entityList.isNotEmpty && _entityList.length > 0){
      int length = _maxCount > _entityList.length ? _entityList.length : _maxCount;
      for(int i = 0; i < length; i++){
        double data = _entityList[length - i - 1].waterLevel < 0 ? 0 : _entityList[length - i - 1].waterLevel;
        spots.add(FlSpot(i.toDouble(), data));
        if(data > _maxWaterLevel)
          _maxWaterLevel = data;
      }
    }
    return spots;
  }

  List<FlSpot> flowVelocitySpot(){
    List<FlSpot> spots = new List<FlSpot>();

    if(_entityList.isNotEmpty && _entityList.length > 0){
      int length = _maxCount > _entityList.length ? _entityList.length : _maxCount;
      for(int i = 0; i < length; i++){
        double data = _entityList[length - i - 1].flowVelocity < 0 ? 0 : _entityList[length - i - 1].flowVelocity;
        spots.add(FlSpot(i.toDouble(), data));
        if(data > _maxFlowVelocity)
          _maxFlowVelocity = data;
      }
    }
    return spots;
  }

  List<FlSpot> flowVelSigIntensSpot(){
    List<FlSpot> spots = new List<FlSpot>();

    if(_entityList.isNotEmpty && _entityList.length > 0){
      int length = _maxCount > _entityList.length ? _entityList.length : _maxCount;
      for(int i = 0; i < length; i++){
        double data = _entityList[length - i - 1].flowVelSigIntens < 0 ? 0 : _entityList[length - i - 1].flowVelSigIntens;
        spots.add(FlSpot(i.toDouble(), data));
        if(data > _maxFlowVelSigIntens)
          _maxFlowVelSigIntens = data;
      }
    }
    return spots;
  }

  List<FlSpot> watLevSigIntensSpot(){
    List<FlSpot> spots = new List<FlSpot>();

    if(_entityList.isNotEmpty && _entityList.length > 0){
      int length = _maxCount > _entityList.length ? _entityList.length : _maxCount;
      for(int i = 0; i < length; i++){
        double data = _entityList[length - i - 1].watLevSigIntens < 0 ? 0 : _entityList[length - i - 1].watLevSigIntens;
        spots.add(FlSpot(i.toDouble(), data));
        if(data > _maxWatLevSigIntens)
          _maxWatLevSigIntens = data;
      }
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    List<Color> gradientColors = [
      Color(0xff23b6e6),
      Color(0xff02d39a),
    ];

    Widget chart(String head, String unit, double maxX, double maxY, List<FlSpot> spotList){
      return Padding(
        padding: const EdgeInsets.only(right: 1.0, left: 1.0, top: 10),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 18.0, left: 30.0, bottom: 12),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(head,
                    style: Theme.of(context).textTheme.subtitle.copyWith(color: Colors.black54),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(right: 18.0, left: 30.0, ),
              child: Row(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 2, right: 10, top: 0),
                    alignment: Alignment(0, 0),
                    height: 12,
                    width: 12,
                    decoration: new BoxDecoration(
                      color: Colors.blue,
                    ),
                  ),
                  Text(head,
                    style: Theme.of(context).textTheme.caption.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),

            AspectRatio(
              aspectRatio: 1.70,
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.only(right: 18.0, left: 12.0, top: 20, bottom: 12),
                  child: FlChart(
                    chart: LineChart(
                      LineChartData(
                        lineTouchData: LineTouchData(
                            getTouchedSpotIndicator: (List<TouchedSpot> spots) {
                              return spots.map((spot) {
                                return TouchedSpotIndicatorData(
                                  const FlLine(color: Colors.orange, strokeWidth: 1),
                                  const FlDotData(dotSize: 2, dotColor: Colors.orange),
                                );
                              }).toList();
                            },
                            touchTooltipData: TouchTooltipData(
                                tooltipBgColor: Colors.blueAccent,
                                getTooltipItems: (List<TouchedSpot> spots) {
                                  return spots.map((spot) {
                                    final flSpot = spot.spot;
                                    return TooltipItem(
                                      '${_entityList[maxX.toInt() - flSpot.x.toInt() - 1].collectTime.replaceAll(new RegExp(r'T'), ' ')} \n${flSpot.y} $unit',
                                      const TextStyle(color: Colors.white),
                                    );
                                  }).toList();
                                }
                            )
                        ),
                        gridData: FlGridData(
                          show: true,
                          checkToShowVerticalGrid: (double value) {
                            int v = value.toInt();
                            int m = (maxY / 4.0).round();
                            if(m <= 0)
                              return true;
                            else{
                              if(v % m == 0)
                                return true;
                            }
                            return false;
                          },
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 22,
                            textStyle: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.normal,
                                fontSize: 12
                            ),
                            getTitles: (value) {
                              int v = value.toInt();
                              int m = (maxX / 10.0).round();
                              if(m <= 0)
                                return '$v';
                              else{
                                if(v % m == 0)
                                  return '$v';
                              }
                              return '';
                            },
                            margin: 8,
                          ),
                          leftTitles: SideTitles(
                            showTitles: true,
                            textStyle: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.normal,
                              fontSize: 12,
                            ),
                            getTitles: (value) {
                              int v = value.toInt();
                              int m = (maxY / 4.0).round();
                              if(m <= 0)
                                return '$v';
                              else{
                                if(v % m == 0)
                                  return '$v';
                              }
                              return '';
                            },
                            reservedSize: 28,
                            margin: 12,
                          ),
                        ),
                        borderData: FlBorderData(
                            show: true,
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey,
                                width: 1,
                              ),
                              left: BorderSide(
                                color: Colors.grey,
                                width: 1,
                              ),
                              right: BorderSide(
                                color: Colors.transparent,
                              ),
                              top: BorderSide(
                                color: Colors.transparent,
                              ),
                            )
                        ),
                        minX: 0,
                        maxX: maxX,
                        minY: 0,
                        maxY: maxY <= 1 ? 1 : (maxY + (maxY / 5.0)),
                        lineBarsData: [
                          LineChartBarData(
                            spots: spotList,
                            isCurved: false,
                            colors: [
                              Colors.blue,
                            ],
                            barWidth: 1,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: false,
                            ),
                            belowBarData: BelowBarData(
                              show: false,
                              colors: gradientColors.map((color) => color.withOpacity(0.3)).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    List<Widget> child(){
      List<Widget> list = new List<Widget>();

      if(_type == MonitorType.RD300S){
        list.add(chart('空高(m)', 'm', _maxCount.toDouble(), _maxAirHeight, _airHeightSpot));
        list.add(Divider());
        list.add(chart('水位(m)', 'm', _maxCount.toDouble(), _maxWaterLevel, _waterLevelSpot));
      }
      else{
        list.add(chart('流速(m/s)', 'm/s', _maxCount.toDouble(), _maxFlowVelocity, _flowVelocitySpot));
        list.add(Divider());
        list.add(chart('空高(m)', 'm', _maxCount.toDouble(), _maxAirHeight, _airHeightSpot));
        list.add(Divider());
        list.add(chart('水位(m)', 'm', _maxCount.toDouble(), _maxWaterLevel, _waterLevelSpot));
        //list.add(Divider());
        //list.add(chart('流速信号强度', ' ', _maxCount.toDouble(), _maxFlowVelSigIntens, _flowVelSigIntensSpot));
        //list.add(Divider());
        //list.add(chart('水位信号强度', ' ', _maxCount.toDouble(), _maxWatLevSigIntens, _watLevSigIntensSpot));
      }
      return list;
    }

    return Column(
      children: child(),
    );
  }

}

class DataSource extends DataTableSource{
  List<Entity> _entityList;
  MonitorType _type;

  DataSource(MonitorType type, List<Entity> entityList){
    _type = type;
    _entityList = entityList.reversed.toList();
  }

  List<DataCell> cells(Entity data){
    List<DataCell> cellList = new List<DataCell>();

    cellList.add(DataCell(Text('${data.collectTime.replaceAll(new RegExp(r'T'), ' ')}')));

    if(_type == MonitorType.RD300S){
      cellList.add(DataCell(Text('${data.airHeight < 0 ? '-.-' : data.airHeight}')));
      cellList.add(DataCell(Text('${data.waterLevel < 0 ? '-.-' : data.waterLevel}')));
      cellList.add(DataCell(Text('${data.watLevSigIntens < 0 ? '-.-' : data.watLevSigIntens}')));
    }
    //else if(_type == MonitorType.RD600S){
    else{
      cellList.add(DataCell(Text('${data.flowVelocity < 0 ? '-.-' : data.flowVelocity}')));
      cellList.add(DataCell(Text('${data.airHeight < 0 ? '-.-' : data.airHeight}')));
      cellList.add(DataCell(Text('${data.waterLevel < 0 ? '-.-' : data.waterLevel}')));
      cellList.add(DataCell(Text('${data.flowVelSigIntens < 0 ? '-.-' : data.flowVelSigIntens}')));
      cellList.add(DataCell(Text('${data.watLevSigIntens < 0 ? '-.-' : data.watLevSigIntens}')));
      cellList.add(DataCell(Text('${data.flowRateInstant < 0 ? '-.-' : data.flowRateInstant}')));
      cellList.add(DataCell(Text('${data.flowRateTotal < 0 ? '-.-' : data.flowRateTotal}')));
    }

    cellList.add(DataCell(Text('${data.powerVol}')));

    return cellList;
  }

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= _entityList.length)
      return null;
    final Entity entity = _entityList[index];
    return DataRow.byIndex(
      index: index,
      cells: cells(entity),
    );
  }

  @override
  int get selectedRowCount => 0;

  @override
  int get rowCount => _entityList.length;

  @override
  bool get isRowCountApproximate => false;
}

class DataTablePage extends StatefulWidget{
  int _rtuId;
  MonitorType _type;
  List<Entity> _entityList;
  DataSource _dataSource;

  DataTablePage(int rtuId, MonitorType type, List<Entity> entityList){
    _rtuId = rtuId;
    _type = type;
    _entityList = entityList;
    _dataSource = DataSource(_type, _entityList);
  }
  _DataTablePageStatus createState() => _DataTablePageStatus();
}

class _DataTablePageStatus extends State<DataTablePage>{
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _rowsPerPage = 20;

  List<DataColumn> columns(){
    Entity data = widget._entityList[0];
    List<DataColumn> columnList = new List<DataColumn>();

    columnList.add(DataColumn(label: const Text('采集时间'),));

    if(widget._type == MonitorType.RD300S){
      columnList.add(DataColumn(label: const Text('空高(m)'),));
      columnList.add(DataColumn(label: const Text('水位(m)'),));
      columnList.add(DataColumn(label: const Text('水位信号强度'),));
    }
    //else if(widget._type == MonitorType.RD600S){
    else{
      columnList.add(DataColumn(label: const Text('流速(m/s)'),));
      columnList.add(DataColumn(label: const Text('空高(m)'),));
      columnList.add(DataColumn(label: const Text('水位(m)'),));
      columnList.add(DataColumn(label: const Text('流速信号强度'),));
      columnList.add(DataColumn(label: const Text('水位信号强度'),));
      columnList.add(DataColumn(label: const Text('瞬时流量(m³/s)'),));
      columnList.add(DataColumn(label: const Text('累计流量(m³)'),));
    }
    columnList.add(DataColumn(label: const Text('供电电压(V)'),));

    return columnList;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(widget._rtuId.toString()),
          bottom: TabBar(
            tabs: <Widget>[
              Padding(
                child: Text('曲线'),
                padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
              ),
              Padding(
                child: Text('列表'),
                padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
              ),
            ],
          ),
        ),
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(), //禁止左右滑动切换页面
          children: <Widget>[
            SafeArea(
              top: false,
              bottom: false,
              child: ListView(
                children: <Widget>[
                  LineChartView(widget._type, widget._entityList),
                ],
              ),
            ),
            SafeArea(
              top: false,
              bottom: false,
              child: ListView(
                children: <Widget>[
                  PaginatedDataTable(
                    header: const Text('历史数据'),
                    rowsPerPage: _rowsPerPage,
                    //onRowsPerPageChanged: (int value) { setState(() { _rowsPerPage = value; }); },
                    source: widget._dataSource,
                    columns: columns(),
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