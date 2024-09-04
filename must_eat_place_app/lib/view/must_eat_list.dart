import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:must_eat_place_app/view/add_must_eat.dart';
import 'package:must_eat_place_app/view/must_eat_location.dart';
import 'package:must_eat_place_app/view/update_must_eat.dart';
import 'package:must_eat_place_app/vm/must_eat_handler.dart';

class MustEatList extends StatefulWidget {
  const MustEatList({super.key});

  @override
  State<MustEatList> createState() => _MustEatListState();
}

class _MustEatListState extends State<MustEatList> {
  late MustEatHandler handler;

  @override
  void initState() {
    super.initState();
    handler = MustEatHandler();
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
                (value) => setState(() {}),
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: FutureBuilder(
        future: handler.queryMustEat(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Get.to(() => const MustEatLocation(), arguments: [
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
                          onPressed: (context) =>
                              deleteDialog(snapshot.data![index].seq),
                        ),
                      ],
                    ),
                    child: Card(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 130,
                            height: 130,
                            child: Image.memory(snapshot.data![index].image),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
