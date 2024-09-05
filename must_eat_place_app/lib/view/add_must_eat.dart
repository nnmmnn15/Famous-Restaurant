import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:must_eat_place_app/model/must_eat.dart';
import 'package:must_eat_place_app/view/location_picker.dart';
import 'package:must_eat_place_app/vm/category_handler.dart';
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
  late double lat;
  late double long;
  late TextEditingController nameController;
  late TextEditingController telController;
  late TextEditingController reviewController;
  late TextEditingController categoryController;
  late TextEditingController scoreController;
  late String errorNameText;
  late String errorTelText;
  late String errorReviewText;
  late String errorCategoryText;
  late String errorScoreText;
  late Position currentPosition;

  late List<String> category;
  late String dropdownCategoryValue;

  // 전화번호 정규식
  late RegExp telRegExp;

  late MustEatHandler handler;
  late CategoryHandler categoryHandler;

  @override
  void initState() {
    super.initState();
    lat = 0;
    long = 0;
    nameController = TextEditingController();
    telController = TextEditingController();
    reviewController = TextEditingController();
    categoryController = TextEditingController();
    scoreController = TextEditingController();
    errorNameText = '';
    errorTelText = '';
    errorReviewText = '';
    errorCategoryText = '';
    errorScoreText = '';
    telRegExp = RegExp(r'010-\d{4}-\d{4}');
    handler = MustEatHandler();
    categoryHandler = CategoryHandler();

    category = [];
    dropdownCategoryValue = '';
    getCategory();
    checkLocationPermission();
  }

  getCategory() async {
    category = [];
    List<dynamic> temp = await categoryHandler.queryCategory();
    for (int i = 0; i < temp.length; i++) {
      category.add(temp[i].name);
    }
    if (temp.isNotEmpty) {
      dropdownCategoryValue = category[0];
    }
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
    lat = position.latitude;
    long = position.longitude;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('맛집 추가'),
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
                      child: imageFile == null
                          ? Text(
                              '이미지를 추가해주세요',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.error),
                            )
                          : Image.file(File(imageFile!.path))),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 1.1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () async {
                                var returnValues = await Get.to(
                                    () => const LocationPicker(),
                                    arguments: [lat, long]);
                                if (returnValues != null) {
                                  lat = returnValues[0];
                                  long = returnValues[1];
                                }
                                setState(() {});
                              },
                              icon: const Icon(
                                Icons.location_on,
                              ),
                              label: const Text('위치 변경'),
                            ),
                            Row(
                              children: [
                                DropdownButton(
                                  dropdownColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
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
                                            color: Theme.of(context)
                                                .colorScheme
                                                .tertiary,
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
                                IconButton(
                                  onPressed: () {
                                    addCategory();
                                  },
                                  icon: const Icon(Icons.add),
                                ),
                              ],
                            ),
                          ],
                        ),
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
                    checkData();
                  },
                  child: const Text('입력'),
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
        dropdownCategoryValue.isNotEmpty &&
        scoreController.text.trim().isNotEmpty &&
        !(int.parse(scoreController.text.trim()) > 100 ||
            int.parse(scoreController.text.trim()) < 0) &&
        imageFile != null) {
      errorNameText = '';
      errorTelText = '';
      errorReviewText = '';

      // insert

      File imageFile1 = File(imageFile!.path);
      Uint8List getImage = await imageFile1.readAsBytes();
      MustEat mustEat = MustEat(
          image: getImage,
          lat: lat,
          long: long,
          name: nameController.text.trim(),
          tel: telController.text.trim(),
          review: reviewController.text.trim(),
          category: dropdownCategoryValue,
          score: int.parse(scoreController.text.trim()));
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

  addCategory() {
    Get.dialog(barrierDismissible: false, Builder(
      builder: (context) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return AlertDialog(
              title: const Text('카테고리 추가'),
              content: SizedBox(
                height: MediaQuery.of(context).size.height / 11,
                child: Column(
                  children: [
                    TextField(
                      controller: categoryController,
                      decoration: const InputDecoration(
                        labelText: '카테고리 명을 입력하세요',
                      ),
                    ),
                    Text(
                      errorCategoryText,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    if (categoryController.text.trim() == '') {
                      errorCategoryText = '카테고리를 입력해주세요';
                    } else {
                      int result = await categoryHandler
                          .insertCategory(categoryController.text.trim());
                      if (result == 0) {
                        errorCategoryText = '카테고리가 중복됩니다';
                      } else {
                        insertDialog();
                        getCategory();
                      }
                    }
                    errorCategoryText = '';
                    dialogSetState(() {});
                    setState(() {});
                  },
                  child: const Text('추가'),
                ),
                TextButton(
                  onPressed: () {
                    categoryController.text = '';
                    errorCategoryText = '';
                    Get.back();
                  },
                  child: const Text('취소'),
                ),
              ],
            );
          },
        );
      },
    ));
  }
} // END
