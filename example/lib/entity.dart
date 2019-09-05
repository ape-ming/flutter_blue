import 'package:json_annotation/json_annotation.dart';

part 'entity.g.dart';


List<Entity> getEntityList(List<dynamic> list){
  List<Entity> result = [];
  list.forEach((item){
    result.add(Entity.fromJson(item));
  });
  return result;
}
@JsonSerializable()
class Entity extends Object {

  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'rtu_id')
  String rtuId;

  @JsonKey(name: 'water_level')
  double waterLevel;

  @JsonKey(name: 'wat_lev_sig_intens')
  double watLevSigIntens;

  @JsonKey(name: 'flow_velocity')
  double flowVelocity;

  @JsonKey(name: 'flow_vel_sig_intens')
  double flowVelSigIntens;

  @JsonKey(name: 'flow_rate_instant')
  double flowRateInstant;

  @JsonKey(name: 'flow_rate_total')
  double flowRateTotal;

  @JsonKey(name: 'air_height')
  double airHeight;

  @JsonKey(name: 'equip_temp')
  double equipTemp;

  @JsonKey(name: 'rtu_sig_intens')
  double rtuSigIntens;

  @JsonKey(name: 'power_vol')
  double powerVol;

  @JsonKey(name: 'collect_time')
  String collectTime;

  @JsonKey(name: 'rainfall_five_min')
  double rainfallFiveMin;

  @JsonKey(name: 'wind_speed')
  double windSpeed;

  @JsonKey(name: 'wind_ori')
  double windOri;

  @JsonKey(name: 'note')
  String note;

  Entity(this.id,this.rtuId,this.waterLevel,this.watLevSigIntens,this.flowVelocity,this.flowVelSigIntens,this.flowRateInstant,this.flowRateTotal,this.airHeight,this.equipTemp,this.rtuSigIntens,this.powerVol,this.collectTime,this.rainfallFiveMin,this.windSpeed,this.windOri,this.note,);

  factory Entity.fromJson(Map<String, dynamic> srcJson) => _$EntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$EntityToJson(this);

}


