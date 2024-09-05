import 'dart:typed_data';

class MustEat{
  int? seq;
  Uint8List image;
  double lat;
  double long;
  String name;
  String tel;
  String review;
  String category;
  int score;

  MustEat({
    this.seq,
    required this.image,
    required this.lat,
    required this.long,
    required this.name,
    required this.tel,
    required this.review,
    required this.category,
    required this.score,
  });

  MustEat.fromMap(Map<String, dynamic> res):
    seq = res['seq'],
    image = res['image'],
    lat = res['lat'],
    long = res['long'],
    name = res['name'],
    tel = res['tel'],
    review = res['review'],
    category = res['category'],
    score = res['score'];
}