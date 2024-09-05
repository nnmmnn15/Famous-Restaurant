import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:must_eat_place_app/model/must_eat.dart';
import 'package:must_eat_place_app/vm/category_handler.dart';
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
  late TextEditingController scoreController;
  late String errorNameText;
  late String errorTelText;
  late String errorReviewText;
  late String errorScoreText;

  late List<String> category;
  late String dropdownCategoryValue;

  // 전화번호 정규식
  late RegExp telRegExp;

  late int firstDisp; // 0 이면 처음화면 1 이면 이미지 선택후

  late MustEatHandler handler;
  late CategoryHandler categoryHandler;

  MustEat mustEatData = Get.arguments ?? "__";

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    telController = TextEditingController();
    reviewController = TextEditingController();
    scoreController = TextEditingController();
    errorNameText = '';
    errorTelText = '';
    errorReviewText = '';
    errorScoreText = '';

    lat = mustEatData.lat;
    long = mustEatData.long;
    nameController.text = mustEatData.name;
    telController.text = mustEatData.tel;
    reviewController.text = mustEatData.review;
    scoreController.text = mustEatData.score.toString();

    telRegExp = RegExp(r'010-\d{4}-\d{4}');

    firstDisp = 0;

    errorNameText = '';
    errorTelText = '';
    errorReviewText = '';
    handler = MustEatHandler();
    categoryHandler = CategoryHandler();
    dropdownCategoryValue = '';
    category = [];
    
    getCategory();
  }

  getCategory() async {
    List<dynamic> temp = await categoryHandler.queryCategory();
    for (int i = 0; i < temp.length; i++) {
      category.add(temp[i].name);
    }
    dropdownCategoryValue = mustEatData.category;
    setState(() {});
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          DropdownButton(
                            dropdownColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            iconEnabledColor:
                                Theme.of(context).colorScheme.secondary,
                            value: dropdownCategoryValue, // 현재 값
                            icon: const Icon(Icons.keyboard_arrow_down),
                            items: category.map((String category) {
                              return DropdownMenuItem(
                                value: category,
                                child: SizedBox(
                                  width: 100,
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.tertiary,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              dropdownCategoryValue = value!;
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('위도'),
                            Text(lat.toString()),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('경도'),
                            Text(long.toString()),
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
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.error,
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
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.error,
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
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                        width: 1,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                      )),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                        width: 1,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                      )),
                                    ),
                                  ),
                                ),
                                Text(
                                  errorReviewText,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.error,
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
                          const Text('점수 : '),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 1.67,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(3),
                                  ],
                                  keyboardType: TextInputType.number,
                                  controller: scoreController,
                                ),
                                Text(
                                  errorScoreText,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.error,
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
                    firstDisp == 0 ? checkData() : checkDataAll();
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
        dropdownCategoryValue.isNotEmpty &&
        scoreController.text.trim().isNotEmpty &&
        !(int.parse(scoreController.text.trim()) > 100 ||
            int.parse(scoreController.text.trim()) < 0) &&
        imageFile != null) {
      errorNameText = '';
      errorTelText = '';
      errorReviewText = '';
      // update
      File imageFile1 = File(imageFile!.path);
      Uint8List getImage = await imageFile1.readAsBytes();
      MustEat mustEat = MustEat(
          seq: mustEatData.seq,
          image: getImage,
          lat: lat,
          long: long,
          name: nameController.text.trim(),
          tel: telController.text.trim(),
          review: reviewController.text.trim(),
          category: dropdownCategoryValue,
          score: int.parse(scoreController.text.trim()));
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

      if (scoreController.text.trim().isEmpty) {
        errorScoreText = '값을 입력해주세요';
      } else if (int.parse(scoreController.text.trim()) > 100 ||
          int.parse(scoreController.text.trim()) < 0) {
        errorScoreText = '입력이 올바르지 않습니다';
      } else {
        errorScoreText = '';
      }
    }
    setState(() {});
  }

  // 이미지 수정 X
  checkData() async {
    if (nameController.text.trim().isNotEmpty &&
        telController.text.trim().isNotEmpty &&
        telRegExp.hasMatch(telController.text.trim()) &&
        reviewController.text.trim().isNotEmpty &&
        dropdownCategoryValue.isNotEmpty &&
        scoreController.text.trim().isNotEmpty &&
        !(int.parse(scoreController.text.trim()) > 100 ||
            int.parse(scoreController.text.trim()) < 0)) {
      errorNameText = '';
      errorTelText = '';
      errorReviewText = '';
      // update
      MustEat mustEat = MustEat(
          seq: mustEatData.seq,
          image: mustEatData.image,
          lat: lat,
          long: long,
          name: nameController.text.trim(),
          tel: telController.text.trim(),
          review: reviewController.text.trim(),
          category: dropdownCategoryValue,
          score: int.parse(scoreController.text.trim()));
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

      if (scoreController.text.trim().isEmpty) {
        errorScoreText = '값을 입력해주세요';
      } else if (int.parse(scoreController.text.trim()) > 100 ||
          int.parse(scoreController.text.trim()) < 0) {
        errorScoreText = '입력이 올바르지 않습니다';
      } else {
        errorScoreText = '';
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
