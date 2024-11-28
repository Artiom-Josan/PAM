// lib/controllers/wine_controller.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../models/carousel_item.dart';
import '../models/wine_by.dart';

class WineController extends GetxController {
  // Liste observabile
  var winesBy = <WineBy>[].obs;
  var carousel = <CarouselItem>[].obs;

  // Stare de încărcare
  var isLoading = true.obs;

  // Mesaj de eroare
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadWineData();
  }

  // Metodă pentru încărcarea datelor din JSON
  Future<void> loadWineData() async {
    try {
      isLoading(true);
      // Încarcă fișierul JSON
      final String response = await rootBundle.loadString('assets/v3.json');
      final data = json.decode(response);

      // Parsează "wines_by"
      var winesByFromJson = data['wines_by'] as List;
      winesBy.value = winesByFromJson.map((json) => WineBy.fromJson(json)).toList();

      // Parsează "carousel"
      var carouselFromJson = data['carousel'] as List;
      carousel.value = carouselFromJson.map((json) => CarouselItem.fromJson(json)).toList();
    } catch (e) {
      errorMessage('Eroare la încărcarea datelor: $e');
    } finally {
      isLoading(false);
    }
  }
}
