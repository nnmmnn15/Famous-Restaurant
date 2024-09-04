import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:must_eat_place_app/model/must_eat.dart';
import 'package:must_eat_place_app/view/location_picker.dart';
import 'package:must_eat_place_app/vm/must_eat_handler.dart';

class AddMustEat extends StatefulWidget {
  const AddMustEat({super.key});

  @override
  State<AddMustEat> createState() => _AddMustEatState();
}

class _AddMustEatState extends State<AddMustEat> {
  // Property
  XFile? imageFile;
  final ImagePicker picker = ImagePicker();
  late TextEditingController latController;
  late TextEditingController longController;
  late TextEditingController nameController;
  late TextEditingController telController;
  late TextEditingController reviewController;
  late String errorNameText;
  late String errorTelText;
  late String errorReviewText;
  late Position currentPosition;

  late RegExp telRegExp;

  late MustEatHandler handler;

  @override
  void initState() {
    super.initState();
    latController = TextEditingController();
    longController = TextEditingController();
    nameController = TextEditingController();
    telController = TextEditingController();
    reviewController = TextEditingController();
    errorNameText = '';
    errorTelText = '';
    errorReviewText = '';
    telRegExp = RegExp(r'010-\d{4}-\d{4}');
    handler = MustEatHandler();
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
    print("${position.latitude}, ${position.longitude}");
    latController.text = position.latitude.toString();
    longController.text = position.longitude.toString();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('맛집 추가'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => getImageFromDevice(ImageSource.gallery),
              child: const Text('이미지 선택'),
            ),
            SizedBox(
              // 현재 기기의 width 크기를 가져옴
              width: MediaQuery.of(context).size.width,
              height: 200,
              child: Center(
                  // imageFile 은 null 값이 있을 수 있으므로
                  child: imageFile == null
                      ? const Text('이미지를 추가해주세요')
                      : Image.file(File(imageFile!.path))),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 1.2,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('위도 : '),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 4,
                        child: TextField(
                          readOnly: true,
                          controller: latController,
                        ),
                      ),
                      const Text('경도 : '),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 4,
                        child: TextField(
                          readOnly: true,
                          controller: longController,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Get.to(() => const LocationPicker()),
                        icon: const Icon(Icons.location_on),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('이름 : '),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 1.67,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: nameController,
                            ),
                            Text(
                              errorNameText,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.red,
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('전화 : '),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 1.67,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: telController,
                            ),
                            Text(
                              errorTelText,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.red,
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('평가 : '),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 1.67,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: reviewController,
                            ),
                            Text(
                              errorReviewText,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.red,
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                checkData();
              },
              child: const Text('입력'),
            ),
          ],
        ),
      ),
    );
  }

  // --- Functions ---
  getImageFromDevice(imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile == null) {
      imageFile = null;
    } else {
      imageFile = XFile(pickedFile.path);
    }
    setState(() {});
  }

  checkData() async {
    if (nameController.text.trim().isNotEmpty &&
        telController.text.trim().isNotEmpty &&
        telRegExp.hasMatch(telController.text.trim()) &&
        reviewController.text.trim().isNotEmpty &&
        imageFile != null) {
      errorNameText = '';
      errorTelText = '';
      errorReviewText = '';
      // insert
      File imageFile1 = File(imageFile!.path);
      Uint8List getImage = await imageFile1.readAsBytes();
      MustEat mustEat = MustEat(
        image: getImage,
        lat: double.parse(latController.text),
        long: double.parse(longController.text),
        name: nameController.text.trim(),
        tel: telController.text.trim(),
        review: reviewController.text.trim(),
      );
      int result = await handler.insertMustEat(mustEat);
      if (result != 0) {
        insertDialog();
      }
    } else {
      if (nameController.text.trim().isEmpty) {
        errorNameText = '값을 입력해주세요';
      } else {
        errorNameText = '';
      }

      if (telController.text.trim().isEmpty) {
        errorTelText = '값을 입력해주세요';
      } else if (!telRegExp.hasMatch(telController.text.trim())) {
        errorTelText = '입력이 올바르지 않습니다';
      } else {
        errorTelText = '';
      }

      if (reviewController.text.trim().isEmpty) {
        errorReviewText = '값을 입력해주세요';
      } else {
        errorReviewText = '';
      }
    }
    setState(() {});
  }

  insertDialog() {
    Get.defaultDialog(
      title: "성공",
      middleText: '입력이 정상적으로 완료되었습니다.',
      barrierDismissible: false,
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
            Get.back();
          },
          child: const Text('닫기'),
        )
      ],
    );
  }
} // END
