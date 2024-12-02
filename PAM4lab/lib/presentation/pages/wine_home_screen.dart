import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/wine_controller.dart';
import '../widgets/custom_filter_button.dart';
import '../widgets/wine_category_card.dart';

class WineHomeScreen extends StatelessWidget {
  const WineHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final WineController wineController = Get.find();

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
                  // Search Bar
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

                  // Filter Buttons din "wines_by"
                  Obx(() {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: wineController.winesBy.map((wineBy) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: CustomFilterButton(
                              label: wineBy.name,
                              isSelected: false, // Poți adăuga logica de selecție
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }),
                  const SizedBox(height: 30),

                  // Shop wines by
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

                  // Wine Section
                  const Text('Wine',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                  const SizedBox(height: 15),

                  // Wine items din "carousel" din JSON
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
                            isAvailable: true,
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
