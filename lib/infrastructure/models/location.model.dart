import 'package:hive/hive.dart';

part 'location.model.g.dart';

@HiveType(typeId: 1)
class LocationModel{

  @HiveField(0)
  int id;

  @HiveField(1)
  String address;

  @HiveField(2)
  double lat;

  @HiveField(3)
  double lang;

  LocationModel(this.id, this.address, this.lat, this.lang);
}