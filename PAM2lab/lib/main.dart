import 'package:flutter/material.dart';

void main() {
  runApp(const MyWineApp());
}

class MyWineApp extends StatelessWidget {
  const MyWineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WineHomeScreen(),
    );
  }
}

class WineHomeScreen extends StatelessWidget {
  const WineHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
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

              // Filter Buttons
              const SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    CustomFilterButton(label: 'Type', isSelected: true),
                    SizedBox(width: 10),
                    CustomFilterButton(label: 'Style', isSelected: false),
                    SizedBox(width: 10),
                    CustomFilterButton(label: 'Countries', isSelected: false),
                    SizedBox(width: 10),
                    CustomFilterButton(label: 'Grape', isSelected: false),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              const Text('Shop wines by',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              const SizedBox(height: 15),
              const SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    WineCategoryCard(
                      imagePath: 'assets/red_wine.png',
                      label: 'Red wines',
                      badgeCount: '123',
                    ),
                    SizedBox(width: 20),
                    WineCategoryCard(
                      imagePath: 'assets/white_wine.png',
                      label: 'White wines',
                      badgeCount: '123',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              const Text('Wine',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
              const SizedBox(height: 15),

              // Wine items with sequential images
              buildWineCard(
                imageUrl: "assets/img_1.png",
                name: 'Ocene Bozzovich Beneventano Bianco IGT',
                type: 'Red Wine (Green and Flinty)',
                region: 'From Champagne Blanc',
                price: '₹23,256,596',
                criticsScore: '94 / 100',
                isAvailable: true,
                countryFlagUrl:
                    'https://upload.wikimedia.org/wikipedia/commons/6/62/Flag_of_France.png',
                capacity: '750',
              ),
              const SizedBox(height: 60),
              buildWineCard(
                imageUrl: "assets/img_2.png",
                name: '2021 Petit Chablis - Passy Le Clou',
                type: 'White Wine (Green and Flinty)',
                region: 'From Champagne Blanc',
                price: '₹23,256,596',
                criticsScore: '94 / 100',
                isAvailable: true,
                countryFlagUrl:
                    'https://upload.wikimedia.org/wikipedia/commons/6/62/Flag_of_France.png',
                capacity: '750',
              ),
              const SizedBox(height: 60),
              buildWineCard(
                imageUrl: "assets/img_3.png",
                name:
                    'Philippe Fontaine Champagne Brut Rosé, Rosé de Saignée',
                type: 'Sparkling Wine (Green and Flinty)',
                region: 'From Champagne Blanc',
                price: '₹23,256,596',
                criticsScore: '94 / 100',
                isAvailable: false,
                countryFlagUrl:
                    'https://upload.wikimedia.org/wikipedia/commons/6/62/Flag_of_France.png',
                capacity: '750',
              ),
              const SizedBox(height: 60),
              buildWineCard(
                imageUrl: "assets/img_4.png",
                name: '2021 Cicada\'s Song Rosé',
                type: 'Rosé Wine (Green and Flinty)',
                region: 'From Champagne Blanc',
                price: '₹23,256,596',
                criticsScore: '94 / 100',
                isAvailable: true,
                countryFlagUrl:
                    'https://upload.wikimedia.org/wikipedia/commons/6/62/Flag_of_France.png',
                capacity: '750',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildWineCard({
    required String imageUrl,
    required String name,
    required String type,
    required String region,
    required String price,
    required String criticsScore,
    required bool isAvailable,
    required String countryFlagUrl,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  type,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  region,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  price,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
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
                Row(
                  children: [
                    Image.network(
                      countryFlagUrl,
                      width: 20,
                      height: 15,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '$capacity ml',
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Filter Button Widget
class CustomFilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;

  const CustomFilterButton({
    super.key,
    required this.label,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isSelected ? Colors.red[100] : Colors.grey[200],
        border: Border.all(color: isSelected ? Colors.red : Colors.grey, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.red : Colors.grey[700],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// Wine Category Card Widget
class WineCategoryCard extends StatelessWidget {
  final String imagePath;
  final String label;
  final String badgeCount;

  const WineCategoryCard({
    super.key,
    required this.imagePath,
    required this.label,
    required this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 145,
          height: 189,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 3,
                blurRadius: 6,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: Image.asset(imagePath, fit: BoxFit.cover),
              ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                padding: const EdgeInsets.all(10.0),
                child: Center(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              badgeCount,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
