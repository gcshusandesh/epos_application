class Employee {
  final String name;
  final String email;
  final String phone;
  final String gender;
  bool status;

  Employee({
    required this.name,
    required this.email,
    required this.phone,
    required this.gender,
    required this.status,
  });
}

class Specials {
  final String name;
  final String image;
  bool status;

  Specials({
    required this.name,
    required this.image,
    required this.status,
  });
}

class Category {
  final String name;
  final String image;
  bool status;

  Category({
    required this.name,
    required this.image,
    required this.status,
  });
}

class CategoryItems {
  final String name;
  final String image;
  final String description;
  final String ingredients;
  final String price;
  bool status;

  CategoryItems({
    required this.name,
    required this.image,
    required this.description,
    required this.ingredients,
    required this.price,
    required this.status,
  });
}
