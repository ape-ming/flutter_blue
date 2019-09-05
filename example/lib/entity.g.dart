// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Entity _$EntityFromJson(Map<String, dynamic> json) {
  return Entity(
      json['id'] as int,
      json['rtu_id'] as String,
      (json['water_level'] as num)?.toDouble(),
      (json['wat_lev_sig_intens'] as num)?.toDouble(),
      (json['flow_velocity'] as num)?.toDouble(),
      (json['flow_vel_sig_intens'] as num)?.toDouble(),
      (json['flow_rate_instant'] as num)?.toDouble(),
      (json['flow_rate_total'] as num)?.toDouble(),
      (json['air_height'] as num)?.toDouble(),
      (json['equip_temp'] as num)?.toDouble(),
      (json['rtu_sig_intens'] as num)?.toDouble(),
      (json['power_vol'] as num)?.toDouble(),
      json['collect_time'] as String,
      (json['rainfall_five_min'] as num)?.toDouble(),
      (json['wind_speed'] as num)?.toDouble(),
      (json['wind_ori'] as num)?.toDouble(),
      json['note'] as String);
}

Map<String, dynamic> _$EntityToJson(Entity instance) => <String, dynamic>{
      'id': instance.id,
      'rtu_id': instance.rtuId,
      'water_level': instance.waterLevel,
      'wat_lev_sig_intens': instance.watLevSigIntens,
      'flow_velocity': instance.flowVelocity,
      'flow_vel_sig_intens': instance.flowVelSigIntens,
      'flow_rate_instant': instance.flowRateInstant,
      'flow_rate_total': instance.flowRateTotal,
      'air_height': instance.airHeight,
      'equip_temp': instance.equipTemp,
      'rtu_sig_intens': instance.rtuSigIntens,
      'power_vol': instance.powerVol,
      'collect_time': instance.collectTime,
      'rainfall_five_min': instance.rainfallFiveMin,
      'wind_speed': instance.windSpeed,
      'wind_ori': instance.windOri,
      'note': instance.note
    };
