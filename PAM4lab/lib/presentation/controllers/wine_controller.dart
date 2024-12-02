import 'package:get/get.dart';
import '../../domain/usecases/get_wines_by.dart';
import '../../domain/usecases/get_carousel_items.dart';
import '../../domain/entities/carousel_item.dart';
import '../../domain/entities/wine_by.dart';

class WineController extends GetxController {
  final GetWinesBy getWinesBy;
  final GetCarouselItems getCarouselItems;

  RxList<WineBy> winesBy = <WineBy>[].obs;
  RxList<CarouselItem> carousel = <CarouselItem>[].obs;
  RxBool isLoading = true.obs;
  RxString errorMessage = ''.obs;

  WineController({
    required this.getWinesBy,
    required this.getCarouselItems,
  });

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  Future<void> fetchData() async {
  try {
    isLoading.value = true;
    errorMessage.value = '';

    final fetchedWinesBy = await getWinesBy();
    winesBy.assignAll(fetchedWinesBy);

    final fetchedCarousel = await getCarouselItems();
    carousel.assignAll(fetchedCarousel);

    print('Număr de vinuri încărcate: ${carousel.length}');
    for (var item in carousel) {
      print('Vin: ${item.name}, Imagine: ${item.image}');
    }
  } catch (e) {
    errorMessage.value = 'Failed to load data: $e';
    print('Eroare la încărcarea datelor: $e');
  } finally {
    isLoading.value = false;
  }
}

}