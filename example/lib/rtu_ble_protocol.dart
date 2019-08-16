import 'dart:core';

enum element_name{
  velocity,
  water_level,
  air_height,
}

enum element_unit{
  m_s,
  m,
  mm,
}

enum element_fun_code{
  code_03,
  code_04
}

class ElementParam{
  element_name name;
  element_unit unit;
  element_fun_code fun_code;
  int start_addr;
  int reg_count;
  int scaling;

  ElementParam({this.name = element_name.velocity,
                this.unit = element_unit.m_s,
                this.fun_code = element_fun_code.code_04,
                this.start_addr = 0,
                this.reg_count  = 1,
                this.scaling    = 0,
  });
}


class RtuBleProtocol{
  RtuBleProtocol();

  final _nameTextMap = {
    element_name.velocity : '流速',
    element_name.water_level : '水位',
    element_name.air_height : '空高'
  };

  final _unitTextMap = {
    element_unit.m_s : 'm/s',
    element_unit.m : 'm',
    element_unit.mm : 'mm',
  };

  final _funTextMap = {
    element_fun_code.code_03 : '0x03',
    element_fun_code.code_04 : '0x04',
  };

  final _nameCodeMap = {
    element_name.velocity : '0',
    element_name.water_level : '1',
    element_name.air_height : '2',
  };

  final _unitCodeMap = {
    element_unit.m_s : '0',
    element_unit.m : '1',
    element_unit.mm : '2',
  };

  final _funCodeMap = {
    element_fun_code.code_03 : '3',
    element_fun_code.code_04 : '4',
  };

  String getNameCode(element_name name){
    return _nameCodeMap[name];
  }

  String getNameText(element_name name){
    return _nameTextMap[name];
  }

  String getUnitText(element_unit unit){
    return _unitTextMap[unit];
  }

  String getFuncCodeText(element_fun_code fun_code){
    return _funTextMap[fun_code];
  }

  Map<element_name, String> getNameMap(){
    return _nameTextMap;
  }

  Map<element_unit, String> getUnitMap(){
    return _unitTextMap;
  }

  Map<element_fun_code, String> getFuncCodeMap(){
    return _funTextMap;
  }

  String encode(ElementParam param){
    String name = _nameCodeMap[param.name];
    String unit = _unitCodeMap[param.unit];
    String func_code = _funCodeMap[param.fun_code];
    String start_addr = param.start_addr.toString();
    String reg_count = param.reg_count.toString();
    String scaling = param.scaling.toString();

    return (name + ' ' + unit + ' ' + func_code + ' ' +
        start_addr + ' ' + reg_count + ' ' + scaling);
  }

  T _getKeyFromValue<T>(Map map, String value){
    T key;
    map.forEach((k, v){
      if(value == v){
        key = k;
      }
    });

    return key;
  }

  //cel: 0 0 4 2 3 -1000
  ElementParam decode(String packet){
    if(packet.isEmpty)
      return null;

    List<String> elements = packet.split(' ');

    print('elements:' + elements.toString());
    ElementParam param = ElementParam();
    param.name = _getKeyFromValue(_nameCodeMap, elements[1]);
    param.unit = _getKeyFromValue(_unitCodeMap, elements[2]);
    param.fun_code = _getKeyFromValue(_funCodeMap, elements[3]);
    param.start_addr = int.parse(elements[4]);
    param.reg_count  = int.parse(elements[5]);
    param.scaling    = int.parse(elements[6]);

    return param;
  }
}

