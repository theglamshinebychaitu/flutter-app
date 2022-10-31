import 'package:flutter_map/infrastructure/providers/provider_registration.dart';
import 'package:flutter_map/ui/screen/location_distance_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class TapInLocationList extends ConsumerStatefulWidget {
  const TapInLocationList({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _TapInLocationListState();
}

class _TapInLocationListState extends ConsumerState<TapInLocationList> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      ref.watch(homeProvider).getLocationList();
    });

  }

  @override
  Widget build(BuildContext context) {
    final homeProviderRead = ref.read(homeProvider);
    final homeProviderWatch = ref.watch(homeProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tap in Location List"),
      ),
      body: Container(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
            itemCount: homeProviderWatch.locationList?.length ?? 0,
            itemBuilder: (context, index) {
              return Card(
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            homeProviderRead.tapOnListData(index, context);
                          },
                          child: Text(homeProviderWatch.locationList?[index].address ?? "", maxLines: 5,),
                        ),
                      ),
                      IconButton(icon: const Icon(Icons.delete), onPressed: () {
                        homeProviderRead.deleteLocationList(index);
                      }),
                    ],
                  ),
                ),
              );
            },),
      ),
    );
  }
}
