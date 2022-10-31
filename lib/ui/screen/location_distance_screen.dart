
import 'package:flutter/material.dart';
import 'package:flutter_map/infrastructure/providers/provider_registration.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocationDistanceScreen extends ConsumerStatefulWidget {
  const LocationDistanceScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _LocationDistanceScreenState();
}

class _LocationDistanceScreenState extends ConsumerState<LocationDistanceScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(homeProvider).clearData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeProviderRead = ref.read(homeProvider);
    final homeProviderWatch = ref.watch(homeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text("Location Page")),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Tap In Location"),
              Text('LAT: ${homeProviderWatch.tapLocationData?.lat ?? ""}'),
              Text('LNG: ${homeProviderWatch.tapLocationData?.lang ?? ""}'),
              Text('ADDRESS: ${homeProviderWatch.tapLocationData?.address ?? ""}'),
              Divider(),
              Text("Current Location"),
              Text('LAT: ${homeProviderWatch.currentPosition?.latitude ?? ""}'),
              Text('LNG: ${homeProviderWatch.currentPosition?.longitude ?? ""}'),
              Text('ADDRESS: ${homeProviderWatch.currentAddress ?? ""}'),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  homeProviderRead.getCurrentPosition(context);
                },
                child: const Text("Get Current Location"),
              ),

              if(homeProviderWatch.distance != null)
                Text("Distance:- ${homeProviderWatch.distance?.toStringAsFixed(2)} Km", style: const TextStyle(fontSize: 20.0),),
                Text(homeProviderWatch.msg ?? "", style: const TextStyle(fontSize: 20.0),),
            ],
          ),
        ),
      ),
    );
  }
}
