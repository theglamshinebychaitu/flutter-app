

import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/infrastructure/models/location.model.dart';
import 'package:flutter_map/ui/screen/location_distance_screen.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class HomeScreenProvider extends ChangeNotifier {
  PickResult _selectedPlace = PickResult();
  PickResult get selectedPlace => _selectedPlace;

  List<LocationModel>? locationList;

  LocationModel? _tapLocationData;
  LocationModel? get tapLocationData => _tapLocationData;

  double? _distance;
  double? get distance => _distance;

  String? _msg;
  String? get msg => _msg;

  Box? _locationBox;

  void setSelectedPlace(PickResult pick) {
    _selectedPlace = pick;
    int lastIndex = (_locationBox?.toMap().length ?? 0) - 1;
    if (lastIndex < 0) {
      lastIndex = 0;
    }
    LocationModel locationModel = LocationModel(lastIndex, pick.formattedAddress ?? "", pick.geometry?.location.lat ?? 0.0, pick.geometry?.location.lng ?? 0.0);
    _locationBox?.add(locationModel);
  }

  Future openBox() async {
    var dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    _locationBox = await Hive.openBox('locationBox');
    return;
  }

  void getLocationList() {
    // Map<dynamic, dynamic>? raw = _locationBox?.values.;
    locationList = _locationBox?.values.cast<LocationModel>().toList();
    notifyListeners();
  }

  void deleteLocationList(int index) {
    _locationBox?.deleteAt(index);
    getLocationList();
  }

  String? _currentAddress;
  String? get currentAddress => _currentAddress;

  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;

  Future<bool> handleLocationPermission(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> getCurrentPosition(BuildContext context) async {
    final hasPermission = await handleLocationPermission(context);

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      _currentPosition = position;
      _getAddressFromLatLng(_currentPosition!);
      _distance = calculateDistance(currentPosition?.latitude, currentPosition?.longitude, tapLocationData?.lat, tapLocationData?.lang);
      if((_distance ?? 0.0) < 0.5) {
        _msg = "you are in location area";
      } else {
        _msg = "you are far from location area";
      }
      notifyListeners();
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
        _currentPosition!.latitude, _currentPosition!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
        _currentAddress =
        '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
        notifyListeners();
    }).catchError((e) {
      debugPrint(e);
    });
  }

  void tapOnListData(int index, BuildContext context) {
    _tapLocationData = locationList![index];
    notifyListeners();
    Navigator.push(context, MaterialPageRoute(builder: (context) => const LocationDistanceScreen(),));
  }

  double calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }

  void clearData() {
    _distance = null;
    _msg = "";
    notifyListeners();
  }

}