import 'package:flutter/material.dart';
import 'entity.dart';
import 'monitor_data.dart';
import 'package:fl_chart/fl_chart.dart';


class LineChartView extends StatelessWidget {
  List<Entity> _entityList;
  MonitorType _type;
  final int _maxCount = 100;
  double maxX = 100;
  double maxY = 10;

  LineChartView(MonitorType type, List<Entity> entityList){
    _type = type;
    _entityList = entityList.reversed.toList();
  }

  List<FlSpot> airHeightSpot(){
    List<FlSpot> spots = new List<FlSpot>();

    if(_entityList.isNotEmpty && _entityList.length > 0){
      int length = _maxCount > _entityList.length ? _entityList.length : _maxCount;
      for(int i = 0; i < length; i++){
        double data = _entityList[length - i - 1].airHeight < 0 ? 0 : _entityList[length - i - 1].airHeight;
        spots.add(FlSpot(i.toDouble(), data));
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
    return AspectRatio(
      aspectRatio: 1.70,
      child: Container(
        child: Padding(
          padding: const EdgeInsets.only(right: 18.0, left: 12.0, top: 24, bottom: 12),
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
                              '${_entityList[maxX.toInt() - flSpot.x.toInt() - 1].collectTime.replaceAll(new RegExp(r'T'), ' ')} \n${flSpot.y} m',
                              const TextStyle(color: Colors.white),
                            );
                          }).toList();
                        }
                    )
                ),
                gridData: FlGridData(
                  show: true,
                  checkToShowVerticalGrid: (double value) {
                    return (value % 2 == 0);
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
                      if(v % 10 == 0){
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
                      if(v % 2 == 0){
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
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: airHeightSpot(),
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