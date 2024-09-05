import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart' as latlng;

class MustEatLocation extends StatefulWidget {
  const MustEatLocation({super.key});

  @override
  State<MustEatLocation> createState() => _MustEatLocationState();
}

class _MustEatLocationState extends State<MustEatLocation> {
  late Position currentPosition;
  late double latData; // 위도데이터
  late double longData; // 경도데이터
  late double userLat;
  late double userLong;
  late MapController mapController;
  late bool canRun;
  late double distance;

  var mustEatData = Get.arguments ?? '__';

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    latData = mustEatData[0];
    longData = mustEatData[1];
    canRun = false;
    distance = 0;
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
    // 학원 위치 : 37.4973294 / 127.0293198
    Position position = await Geolocator.getCurrentPosition();
    currentPosition = position;
    canRun = true;
    userLat = currentPosition.latitude;
    userLong = currentPosition.longitude;
    calcDis();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('맛집 위치'),
      ),
      body: canRun
          ? Column(
              children: [
                SizedBox(
                  child: Text(
                    '${distance}m 거리입니다',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                Flexible(child: flutterMap()),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
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
                    Icons.location_on,
                    size: 50,
                    color: Colors.red,
                  )
                ],
              ),
            ),
            Marker(
              width: 80,
              height: 80,
              point: latlng.LatLng(userLat, userLong),
              child: const Column(
                children: [
                  SizedBox(
                    child: Text(
                      '사용자',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.blue,
                  )
                ],
              ),
            )
          ],
        )
      ],
    );
  }

  // --- Functions ---
  calcDis() {
    // 거리 계산
    const latlng.Distance distanceCalc = latlng.Distance();
    distance = distanceCalc.as(
      latlng.LengthUnit.Meter,
      latlng.LatLng(userLat, userLong),
      latlng.LatLng(latData, longData),
    );
  }
} // End
