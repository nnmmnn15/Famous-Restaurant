class Category{
  String name;

  Category({required this.name});

  Category.fromMap(Map<String, dynamic> res):
    name = res['name'];
}