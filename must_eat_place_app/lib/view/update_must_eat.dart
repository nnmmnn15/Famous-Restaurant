import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:must_eat_place_app/model/must_eat.dart';
import 'package:must_eat_place_app/vm/must_eat_handler.dart';

class UpdateMustEat extends StatefulWidget {
  const UpdateMustEat({super.key});

  @override
  State<UpdateMustEat> createState() => _UpdateMustEatState();
}

class _UpdateMustEatState extends State<UpdateMustEat> {
  // Property
  XFile? imageFile;
  final ImagePicker picker = ImagePicker();
  late double lat;
  late double long;
  late TextEditingController nameController;
  late TextEditingController telController;
  late TextEditingController reviewController;
  late String errorNameText;
  late String errorTelText;
  late String errorReviewText;

  // 전화번호 정규식
  late RegExp telRegExp;

  late int firstDisp; // 0 이면 처음화면 1 이면 이미지 선택후

  late MustEatHandler handler;

  MustEat mustEatData = Get.arguments ?? "__";

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    telController = TextEditingController();
    reviewController = TextEditingController();

    lat = mustEatData.lat;
    long = mustEatData.long;
    nameController.text = mustEatData.name;
    telController.text = mustEatData.tel;
    reviewController.text = mustEatData.review;

    telRegExp = RegExp(r'010-\d{4}-\d{4}');

    firstDisp = 0;

    errorNameText = '';
    errorTelText = '';
    errorReviewText = '';
    handler = MustEatHandler();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('맛집 수정'),
        ),
        body: SingleChildScrollView(
          child: Center(
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
                      child: firstDisp == 0
                          ? Image.memory(mustEatData.image)
                          : imageFile == null
                              ? const Text('이미지를 추가해주세요')
                              : Image.file(File(imageFile!.path))),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 1.2,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              const Icon(
                                Icons.location_on, size: 40,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('위도'),
                                  Text(lat.toString()),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('경도'),
                                  Text(long.toString()),
                                ],
                              ),
                            ],
                          ),
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
                                  keyboardType: TextInputType.text,
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
                                  keyboardType: TextInputType.text,
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
                                SizedBox(
                                    height: 100,
                                    child: TextField(
                                      minLines: null,
                                      maxLines: null,
                                      expands: true,
                                      keyboardType: TextInputType.text,
                                      controller: reviewController,
                                      decoration: const InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.black, width: 1)),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.black, width: 1)),
                                      ),
                                    ),
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
                    firstDisp == 0
                    ? checkData() 
                    : checkDataAll();
                  },
                  child: const Text('수정'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Functions ---
  getImageFromDevice(imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile == null) {
      return null;
    } else {
      imageFile = XFile(pickedFile.path);
      firstDisp += 1;
    }
    setState(() {});
  }

  // 이미지 수정 O
  checkDataAll() async {
    if (nameController.text.trim().isNotEmpty &&
        telController.text.trim().isNotEmpty &&
        telRegExp.hasMatch(telController.text.trim()) &&
        reviewController.text.trim().isNotEmpty &&
        imageFile != null) {
      errorNameText = '';
      errorTelText = '';
      errorReviewText = '';
      // update
      File imageFile1 = File(imageFile!.path);
      Uint8List getImage = await imageFile1.readAsBytes();
      MustEat mustEat = MustEat(
        seq : mustEatData.seq,
        image: getImage,
        lat: lat,
        long: long,
        name: nameController.text.trim(),
        tel: telController.text.trim(),
        review: reviewController.text.trim(),
      );
      int result = await handler.updateMustEat(mustEat);
      if (result == 1) {
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

  // 이미지 수정 X
  checkData() async {
    if (nameController.text.trim().isNotEmpty &&
        telController.text.trim().isNotEmpty &&
        telRegExp.hasMatch(telController.text.trim()) &&
        reviewController.text.trim().isNotEmpty) {
      errorNameText = '';
      errorTelText = '';
      errorReviewText = '';
      // update
      MustEat mustEat = MustEat(
        seq : mustEatData.seq,
        image: mustEatData.image,
        lat: lat,
        long: long,
        name: nameController.text.trim(),
        tel: telController.text.trim(),
        review: reviewController.text.trim(),
      );
      int result = await handler.updateMustEat(mustEat);
      if (result == 1) {
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
      middleText: '수정이 정상적으로 완료되었습니다.',
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
