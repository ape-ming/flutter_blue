import 'main.dart';
import 'entity.dart';

enum MonitorType{
  RD200,
  RD300S,
  RD600S,
  others,
}

class MonitorData{
  int _rtuId;
  MonitorType _type;
  Entity _lastEntity;
  List<Entity> _entityList = new List<Entity>();

  MonitorData(List<Entity> entityList){
    update(entityList);
    _rtuId = int.parse(_lastEntity.rtuId);
    if(_rtuId.toString().startsWith('2')){
      _type = MonitorType.RD200;
    }
    else if(_rtuId.toString().startsWith('3')){
      _type = MonitorType.RD300S;
    }
    else if(_rtuId.toString().startsWith('6')){
      _type = MonitorType.RD600S;
    }
    else{
      _type = MonitorType.others;
    }
  }

  update(List<Entity> entityList){
    _lastEntity = entityList[entityList.length - 1];
    _entityList.clear();
    _entityList.addAll(entityList);
  }

  int getRtuId(){
    return _rtuId;
  }

  MonitorType getType(){
    return _type;
  }

  Entity getLastEntity(){
    return _lastEntity;
  }

  List<Entity> getEntityList(){
    return _entityList;
  }
}