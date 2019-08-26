import 'package:flutter/material.dart';
import 'entity.dart';
import 'monitor_data.dart';

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
      cellList.add(DataCell(Text('${data.airHeight < 0 ? 'null' : data.airHeight}')));
      cellList.add(DataCell(Text('${data.waterLevel < 0 ? 'null' : data.waterLevel}')));
      cellList.add(DataCell(Text('${data.watLevSigIntens < 0 ? 'null' : data.watLevSigIntens}')));
    }
    //else if(_type == MonitorType.RD600S){
    else{
      cellList.add(DataCell(Text('${data.flowVelocity < 0 ? 'null' : data.flowVelocity}')));
      cellList.add(DataCell(Text('${data.airHeight < 0 ? 'null' : data.airHeight}')));
      cellList.add(DataCell(Text('${data.waterLevel < 0 ? 'null' : data.waterLevel}')));
      cellList.add(DataCell(Text('${data.flowVelSigIntens < 0 ? 'null' : data.flowVelSigIntens}')));
      cellList.add(DataCell(Text('${data.watLevSigIntens < 0 ? 'null' : data.watLevSigIntens}')));
      cellList.add(DataCell(Text('${data.flowRateInstant < 0 ? 'null' : data.flowRateInstant}')));
      cellList.add(DataCell(Text('${data.flowRateTotal < 0 ? 'null' : data.flowRateTotal}')));
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
      /*
      selected: dessert.selected,
      onSelectChanged: (bool value) {
        if (dessert.selected != value) {
          _selectedCount += value ? 1 : -1;
          assert(_selectedCount >= 0);
          dessert.selected = value;
          notifyListeners();
        }
      },
       */
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
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text(widget._rtuId.toString()),),
      body: ListView(
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
    );
  }
}