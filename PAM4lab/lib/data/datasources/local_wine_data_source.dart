import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:pam4lab/data/models/carousel_item_model.dart';
import 'package:pam4lab/data/models/wine_by_model.dart';

class LocalWineDataSource {
  Future<List<WineByModel>> getWinesBy() async {
    final jsonString = await rootBundle.loadString('assets/v3.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    final List<dynamic> winesByJson = jsonData['wines_by'];
    return winesByJson.map((item) => WineByModel.fromJson(item)).toList();
  }

  Future<List<CarouselItemModel>> getCarouselItems() async {
    final jsonString = await rootBundle.loadString('assets/v3.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    final List<dynamic> carouselJson = jsonData['carousel'];
    return carouselJson.map((item) => CarouselItemModel.fromJson(item)).toList();
  }
}
