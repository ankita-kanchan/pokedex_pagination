class Pokemon {
  String name;
  double height;
  double weight;
  String image;

  Pokemon(
      {required this.name,
      required this.height,
      required this.weight,
      required this.image});

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
        name:
            "${json["name"].toString()[0].toUpperCase()}${json["name"].toString().substring(1)}",
        height: double.parse(json["height"].toString()),
        weight: double.parse(json["weight"].toString()),
        image: json["sprites"]["front_default"]);
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "height": height,
        "weight": weight,
        "image": image,
      };
}
