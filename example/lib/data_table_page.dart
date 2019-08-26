import 'package:flutter/material.dart';
import 'entity.dart';
import 'monitor_data.dart';
import 'package:fl_chart/fl_chart.dart';


class LineChartView extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    List<Color> gradientColors = [
      Color(0xff23b6e6),
      Color(0xff02d39a),
    ];
    return AspectRatio(
      aspectRatio: 1.70,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(18)),
            color: Color(0xff232d37)
        ),
        child: Padding(
          padding: const EdgeInsets.only(right: 18.0, left: 12.0, top: 24, bottom: 12),
          child: FlChart(
            chart: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawHorizontalGrid: true,
                  getDrawingVerticalGridLine: (value) {
                    return const FlLine(
                      color: Color(0xff37434d),
                      strokeWidth:  1,
                    );
                  },
                  getDrawingHorizontalGridLine: (value) {
                    return const FlLine(
                      color: Color(0xff37434d),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    textStyle: TextStyle(
                        color: const Color(0xff68737d),
                        fontWeight: FontWeight.bold,
                        fontSize: 16
                    ),
                    getTitles: (value) {
                      switch(value.toInt()) {
                        case 2: return 'MAR';
                        case 5: return 'JUN';
                        case 8: return 'SEP';
                      }

                      return '';
                    },
                    margin: 8,
                  ),
                  leftTitles: SideTitles(
                    showTitles: true,
                    textStyle: TextStyle(
                      color: const Color(0xff67727d),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    getTitles: (value) {
                      switch(value.toInt()) {
                        case 1: return '10k';
                        case 3: return '30k';
                        case 5: return '50k';
                      }
                      return '';
                    },
                    reservedSize: 28,
                    margin: 12,
                  ),
                ),
                borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Color(0xff37434d), width: 1)
                ),
                minX: 0,
                maxX: 11,
                minY: 0,
                maxY: 6,
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      FlSpot(0, 3),
                      FlSpot(2.6, 2),
                      FlSpot(4.9, 5),
                      FlSpot(6.8, 3.1),
                      FlSpot(8, 4),
                      FlSpot(9.5, 3),
                      FlSpot(11, 4),
                    ],
                    isCurved: true,
                    colors: gradientColors,
                    barWidth: 5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: false,
                    ),
                    belowBarData: BelowBarData(
                      show: true,
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
                  LineChartView(),
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