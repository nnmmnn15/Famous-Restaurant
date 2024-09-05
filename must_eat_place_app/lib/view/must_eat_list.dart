import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:must_eat_place_app/view/add_must_eat.dart';
import 'package:must_eat_place_app/view/must_eat_location.dart';
import 'package:must_eat_place_app/view/update_must_eat.dart';
import 'package:must_eat_place_app/vm/category_handler.dart';
import 'package:must_eat_place_app/vm/must_eat_handler.dart';

class MustEatList extends StatefulWidget {
  const MustEatList({super.key});

  @override
  State<MustEatList> createState() => _MustEatListState();
}

class _MustEatListState extends State<MustEatList> {
  late MustEatHandler handler;
  late CategoryHandler categoryHandler;
  //  0 일때 라이트 1일때 다크
  late int darkmodeCheck;
  final GetStorage box = GetStorage();

  late List<String> category;
  late String dropdownCategoryValue;

  late List<String> orderBy;
  late String dropdownOrderByValue;

  @override
  void initState() {
    super.initState();

    handler = MustEatHandler();
    categoryHandler = CategoryHandler();
    darkmodeCheck = 0;
    category = ['전체'];
    dropdownCategoryValue = '전체';
    orderBy = ['이름순', '점수 높은 순', '점수 낮은 순'];
    dropdownOrderByValue = '이름순';
    getCategory();
  }

  getCategory() async {
    category = ['전체'];
    List<dynamic> temp = await categoryHandler.queryCategory();
    for (int i = 0; i < temp.length; i++) {
      category.add(temp[i].name);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내가 경험한 맛집 리스트'),
        actions: [
          IconButton(
            onPressed: () {
              Get.to(
                () => const AddMustEat(),
              )?.then(
                (value) => getCategory(),
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('라이트 모드'),
                  darkmodeCheck == 0
                      ? const Icon(Icons.check)
                      : const SizedBox.shrink(),
                ],
              ),
              onTap: () {
                darkmodeCheck = 0;
                Get.changeTheme(ThemeData.light());
                setState(() {});
              },
            ),
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('다크 모드'),
                  darkmodeCheck == 1
                      ? const Icon(Icons.check)
                      : const SizedBox.shrink(),
                ],
              ),
              onTap: () {
                darkmodeCheck = 1;
                Get.changeTheme(ThemeData.dark());
                setState(() {});
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton(
                  dropdownColor: Theme.of(context).colorScheme.primaryContainer,
                  iconEnabledColor: Theme.of(context).colorScheme.secondary,
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
                // DropdownButton(
                //   dropdownColor: Theme.of(context).colorScheme.primaryContainer,
                //   iconEnabledColor: Theme.of(context).colorScheme.secondary,
                //   value: dropdownOrderByValue, // 현재 값
                //   icon: const Icon(Icons.keyboard_arrow_down),
                //   items: orderBy.map((String orderBy) {
                //     return DropdownMenuItem(
                //       value: orderBy,
                //       child: SizedBox(
                //         width: 100,
                //         child: Text(
                //           orderBy,
                //           style: TextStyle(
                //             color: Theme.of(context).colorScheme.tertiary,
                //           ),
                //         ),
                //       ),
                //     );
                //   }).toList(),
                //   onChanged: (value) {
                //     dropdownOrderByValue = value!;
                //     setState(() {});
                //   },
                // ),
              ],
            ),
          ),
          dropdownCategoryValue == '전체'
              ? Flexible(
                  child: FutureBuilder(
                    future: handler.queryMustEat(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Get.to(() => const MustEatLocation(),
                                    arguments: [
                                      snapshot.data![index].lat,
                                      snapshot.data![index].long,
                                      snapshot.data![index].name,
                                    ]);
                              },
                              child: Slidable(
                                // 왼쪽에서 오른쪽 수정
                                startActionPane: ActionPane(
                                  extentRatio: .3,
                                  motion: const BehindMotion(),
                                  children: [
                                    SlidableAction(
                                      backgroundColor: Colors.green,
                                      icon: Icons.edit,
                                      label: '수정',
                                      onPressed: (context) {
                                        Get.to(
                                          () => const UpdateMustEat(),
                                          arguments: snapshot.data![index],
                                        )?.then(
                                          (value) => setState(() {}),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                // 오른쪽에서 왼쪽으로 슬라이드 삭제
                                endActionPane: ActionPane(
                                  extentRatio: .3, // 사이즈 최대 1
                                  motion: const BehindMotion(),
                                  children: [
                                    SlidableAction(
                                      backgroundColor: Colors.red,
                                      icon: Icons.delete,
                                      label: '삭제',
                                      onPressed: (context) => deleteDialog(
                                          snapshot.data![index].seq),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Card(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(15.0),
                                          child: SizedBox(
                                            width: 130,
                                            height: 130,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              child: Image.memory(
                                                  snapshot.data![index].image),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text('이름'),
                                              Text(
                                                snapshot.data![index].name,
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                ),
                                              ),
                                              const Text('전화번호'),
                                              Text(
                                                snapshot.data![index].tel,
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                ),
                                              ),
                                              const Text('점수'),
                                              Text(
                                                snapshot.data![index].score
                                                    .toString(),
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        return const Center(
                          child: Text('저장한 맛집이 없습니다'),
                        );
                      }
                    },
                  ),
                )
              : Flexible(
                  child: FutureBuilder(
                    future: handler.queryCategoryMustEat(dropdownCategoryValue),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Get.to(() => const MustEatLocation(),
                                    arguments: [
                                      snapshot.data![index].lat,
                                      snapshot.data![index].long,
                                      snapshot.data![index].name,
                                    ]);
                              },
                              child: Slidable(
                                // 왼쪽에서 오른쪽 수정
                                startActionPane: ActionPane(
                                  extentRatio: .3,
                                  motion: const BehindMotion(),
                                  children: [
                                    SlidableAction(
                                      backgroundColor: Colors.green,
                                      icon: Icons.edit,
                                      label: '수정',
                                      onPressed: (context) {
                                        Get.to(
                                          () => const UpdateMustEat(),
                                          arguments: snapshot.data![index],
                                        )?.then(
                                          (value) => setState(() {}),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                // 오른쪽에서 왼쪽으로 슬라이드 삭제
                                endActionPane: ActionPane(
                                  extentRatio: .3, // 사이즈 최대 1
                                  motion: const BehindMotion(),
                                  children: [
                                    SlidableAction(
                                      backgroundColor: Colors.red,
                                      icon: Icons.delete,
                                      label: '삭제',
                                      onPressed: (context) => deleteDialog(
                                          snapshot.data![index].seq),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Card(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(15.0),
                                          child: SizedBox(
                                            width: 130,
                                            height: 130,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              child: Image.memory(
                                                  snapshot.data![index].image),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text('이름'),
                                              Text(
                                                snapshot.data![index].name,
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                ),
                                              ),
                                              const Text('전화번호'),
                                              Text(
                                                snapshot.data![index].tel,
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        return const Center(
                          child: Text('저장한 맛집이 없습니다'),
                        );
                      }
                    },
                  ),
                )
        ],
      ),
    );
  }

  // --- Function ---
  deleteDialog(int? seq) {
    Get.defaultDialog(
      title: '삭제',
      middleText: '정말로 삭제하시겠습니까?',
      actions: [
        TextButton(
          onPressed: () async {
            int result = await handler.deleteMustEat(seq);
            Get.back();
            if (result != 1) {
              errorDialog();
            }
            setState(() {});
          },
          child: const Text('예'),
        ),
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('아니오'),
        ),
      ],
    );
  }

  errorDialog() {
    Get.defaultDialog(
      title: '오류',
      middleText: '삭제에 실패했습니다',
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('확인'))
      ],
    );
  }
} // End
