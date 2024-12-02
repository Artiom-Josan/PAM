// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'data/datasources/local_wine_data_source.dart';
import 'data/repositories/wine_repository_impl.dart';
import 'domain/usecases/get_carousel_items.dart';
import 'domain/usecases/get_wines_by.dart';
import 'presentation/controllers/wine_controller.dart';
import 'presentation/pages/wine_home_screen.dart';
import 'presentation/widgets/custom_filter_button.dart';
import 'presentation/widgets/wine_category_card.dart';

void main() {
  // Inițializează sursa de date locală și repository-ul
  final localDataSource = LocalWineDataSource();
  final wineRepository = WineRepositoryImpl(localDataSource);

  // Creează use case-urile
  final getWinesBy = GetWinesBy(wineRepository);
  final getCarouselItems = GetCarouselItems(wineRepository);

  // Injectează WineController folosind GetX
  Get.put(WineController(
    getWinesBy: getWinesBy,
    getCarouselItems: getCarouselItems,
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Wine Shop',
      debugShowCheckedModeBanner: false,
      home: const WineHomeScreen(),
    );
  }
}

class WineHomeScreen extends StatelessWidget {
  const WineHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Obține WineController
    final WineController wineController = Get.find<WineController>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.location_on, color: Colors.black),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Donnerville Drive', style: TextStyle(color: Colors.black)),
            Text(
              '6 Sommerville Mall, 6 Sommerville Drive, Athanasian...',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none, color: Colors.black),
              ),
              const Positioned(
                right: 12,
                top: 12,
                child: CircleAvatar(
                  radius: 8,
                  backgroundColor: Colors.red,
                  child: Text(
                    '8',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (wineController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (wineController.errorMessage.value.isNotEmpty) {
          return Center(child: Text(wineController.errorMessage.value));
        } else {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bara de căutare
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: const Icon(Icons.mic, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Butoane de filtrare din "wines_by" din JSON
                  Obx(() {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: wineController.winesBy.map((wineBy) {
                          bool isSelected = false; // Ajustează logica de selecție
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: CustomFilterButton(
                              label: wineBy.name,
                              isSelected: isSelected,
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }),
                  const SizedBox(height: 30),

                  // Secțiunea "Shop wines by"
                  const Text('Shop wines by',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 15),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        WineCategoryCard(
                          imagePath: 'assets/red_wine.png',
                          label: 'Red Wines',
                          badgeCount: '123',
                        ),
                        const SizedBox(width: 20),
                        WineCategoryCard(
                          imagePath: 'assets/white_wine.png',
                          label: 'White Wines',
                          badgeCount: '123',
                        ),
                        const SizedBox(width: 20),
                        // Adaugă mai multe categorii dacă este necesar
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Secțiunea "Wine"
                  const Text('Wine',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                  const SizedBox(height: 15),

                  // Articole de vin din "carousel" din JSON
                  Obx(() {
                    return Column(
                      children: wineController.carousel.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: buildWineCard(
                            imageUrl: item.image.startsWith('assets/')
                                ? item.image
                                : 'assets/${item.image}',
                            name: item.name,
                            type: _formatType(item.type),
                            region: 'From ${item.city}, ${item.country}',
                            price: '\$${item.priceUsd.toStringAsFixed(2)}',
                            criticsScore: '${item.criticScore} / 100',
                            isAvailable: true, // Ajustează logica de disponibilitate
                            capacity: item.bottleSize.replaceAll(' ml', ''),
                          ),
                        );
                      }).toList(),
                    );
                  }),
                ],
              ),
            ),
          );
        }
      }),
    );
  }

  // Funcție pentru a formata tipul vinului
  String _formatType(String type) {
    switch (type.toLowerCase()) {
      case 'red':
        return 'Red Wines';
      case 'white':
        return 'White Wines';
      case 'sparkling':
        return 'Sparkling Wines';
      case 'rosé':
        return 'Rosé Wines';
      default:
        return 'Wines';
    }
  }

  // Metodă pentru a construi cardul vinului
  Widget buildWineCard({
    required String imageUrl,
    required String name,
    required String type,
    required String region,
    required String price,
    required String criticsScore,
    required bool isAvailable,
    required String capacity,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 3,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imaginea vinului
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              imageUrl,
              width: 100,
              height: 150,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 15),
          // Detaliile vinului
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Numele vinului
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                // Tipul vinului
                Text(
                  type,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                // Regiunea
                Text(
                  region,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                // Prețul
                Text(
                  price,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                // Scorul criticilor și disponibilitatea
                Row(
                  children: [
                    Text(
                      'Critics Score: $criticsScore',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isAvailable ? 'Available' : 'Unavailable',
                      style: TextStyle(
                        color: isAvailable ? Colors.green : Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Capacitatea
                Text(
                  '$capacity ml',
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
