import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart' as latlng;

class MustEatLocation extends StatefulWidget {
  const MustEatLocation({super.key});

  @override
  State<MustEatLocation> createState() => _MustEatLocationState();
}

class _MustEatLocationState extends State<MustEatLocation> {

  late double latData; // 위도데이터
  late double longData; // 경도데이터
  late MapController mapController;

  var mustEatData = Get.arguments ?? '__';

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    latData = mustEatData[0];
    longData = mustEatData[1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('맛집 위치'),
      ),
      body: flutterMap()
    );
  }

  // --- Function ---
  Widget flutterMap() {
  return FlutterMap(
    mapController: mapController,
    options: MapOptions(
        initialCenter: latlng.LatLng(latData, longData), initialZoom: 17.0),
    children: [
      TileLayer(
        urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
      ),
      MarkerLayer(
        markers: [
          Marker(
            width: 80,
            height: 80,
            point: latlng.LatLng(latData, longData),
            child: Column(
              children: [
                SizedBox(
                  child: Text(
                    mustEatData[2],
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const Icon(
                  Icons.pin_drop,
                  size: 50,
                  color: Colors.red,
                )
              ],
            ),
          )
        ],
      )
    ],
  );
}
} // End
