import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart' as latlng;

class LocationPicker extends StatefulWidget {
  const LocationPicker({super.key});

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  late Position currentPosition;
  late double latData; // 위도데이터
  late double longData; // 경도데이터
  late MapController mapController;
  late bool canRun;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    canRun = false;
    checkLocationPermission();
  }

  checkLocationPermission() async {
    // 사용자가 권한 선택 전까지 대기
    LocationPermission permission = await Geolocator.checkPermission();
    // 거부 시
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }
    // 사용하는 동안, 항상 허용
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      getCurrentLocation();
    }
  }

  getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    currentPosition = position;
    canRun = true;
    latData = currentPosition.latitude;
    longData = currentPosition.longitude;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('위치 선택'),
        automaticallyImplyLeading: false,
      ),
      body: canRun
          ? flutterMap()
          : const Center(
              child: CircularProgressIndicator(),
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.location_on),
        onPressed: () {
          Get.back(
            result: [latData, longData]
          );
        },
      ),
    );
  }

  // ---Function---
  Widget flutterMap() {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: latlng.LatLng(latData, longData),
        initialZoom: 17.0,
        onTap: (tapPosition, point) {
          latData = point.latitude;
          longData = point.longitude;
          setState(() {});
        },
      ),
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
              child: const Column(
                children: [
                  SizedBox(
                    child: Text(
                      '위치',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Icon(
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
}
