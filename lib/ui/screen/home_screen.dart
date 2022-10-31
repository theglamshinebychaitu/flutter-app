import 'dart:math';

import 'package:flutter_map/infrastructure/models/location.model.dart';
import 'package:flutter_map/infrastructure/providers/provider_registration.dart';
import 'package:flutter_map/ui/screen/tap_in_loaction_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {

  static final kInitialPosition = LatLng(-33.8567844, 151.213108);

  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      ref.watch(homeProvider).openBox();
      ref.read(homeProvider).handleLocationPermission(context);
      Hive.registerAdapter(LocationModelAdapter());
    });
  }



  @override
  Widget build(BuildContext context) {
    final homeProviderRead = ref.read(homeProvider);
    final homeProviderWatch = ref.watch(homeProvider);
    return Scaffold(
        appBar: AppBar(
          title: const Text("Google Map Demo"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                child: const Text("Load Google Map"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return PlacePicker(
                          apiKey: "AIzaSyAiwLuNcfF3dhlxr9LwMoVxUGR9VeHAUyI",
                          initialPosition: HomeScreen.kInitialPosition,
                          useCurrentLocation: true,
                          selectInitialPosition: true,

                          //usePlaceDetailSearch: true,
                          onPlacePicked: (result) {
                            homeProviderRead.setSelectedPlace(result);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const TapInLocationList(),));
                          },
                        );
                      },
                    ),
                  );
                },
              ),
              homeProviderWatch.selectedPlace == null ? Container() : Text(homeProviderWatch.selectedPlace.formattedAddress ?? ""),
            ],
          ),
        ));
  }
}
