class Laptop {
  final int id;
  final String name;
  final double price;

  const Laptop({
    required this.id,
    required this.name,
    required this.price,
  });

  factory Laptop.fromJson(Map<String, dynamic> json) {
    return Laptop(
      id: json["id"],
      name: json["name"],
      price: json["price"],
    );
  }
}
