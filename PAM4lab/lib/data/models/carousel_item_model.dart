import 'package:pam4lab/domain/entities/carousel_item.dart';

class CarouselItemModel extends CarouselItem {
  CarouselItemModel({
    required String name,
    required String image,
    required int criticScore,
    required String bottleSize,
    required double priceUsd,
    required String type,
    required String country,
    required String city,
  }) : super(
          name: name,
          image: image,
          criticScore: criticScore,
          bottleSize: bottleSize,
          priceUsd: priceUsd,
          type: type,
          country: country,
          city: city,
        );

  factory CarouselItemModel.fromJson(Map<String, dynamic> json) {
    return CarouselItemModel(
      name: json['name'],
      image: json['image'],
      criticScore: json['critic_score'],
      bottleSize: json['bottle_size'],
      priceUsd: (json['price_usd'] as num).toDouble(),
      type: json['type'],
      country: json['from']['country'],
      city: json['from']['city'],
    );
  }
}
