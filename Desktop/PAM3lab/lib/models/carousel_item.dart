// lib/models/carousel_item.dart
class CarouselItem {
  final String name;
  final String image;
  final int criticScore;
  final String bottleSize;
  final double priceUsd;
  final String type;
  final From from;

  CarouselItem({
    required this.name,
    required this.image,
    required this.criticScore,
    required this.bottleSize,
    required this.priceUsd,
    required this.type,
    required this.from,
  });

  factory CarouselItem.fromJson(Map<String, dynamic> json) {
    return CarouselItem(
      name: json['name'],
      image: json['image'],
      criticScore: json['critic_score'],
      bottleSize: json['bottle_size'],
      priceUsd: (json['price_usd'] as num).toDouble(),
      type: json['type'],
      from: From.fromJson(json['from']),
    );
  }
}

class From {
  final String country;
  final String city;

  From({required this.country, required this.city});

  factory From.fromJson(Map<String, dynamic> json) {
    return From(
      country: json['country'],
      city: json['city'],
    );
  }
}
