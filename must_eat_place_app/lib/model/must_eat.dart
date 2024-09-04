import 'dart:typed_data';

class MustEat{
  int? seq;
  Uint8List image;
  double lat;
  double long;
  String name;
  String tel;
  String review;

  MustEat({
    this.seq,
    required this.image,
    required this.lat,
    required this.long,
    required this.name,
    required this.tel,
    required this.review,
  });

  MustEat.fromMap(Map<String, dynamic> res):
    seq = res['seq'],
    image = res['image'],
    lat = res['lat'],
    long = res['long'],
    name = res['name'],
    tel = res['tel'],
    review = res['review'];
}