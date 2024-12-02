import '../entities/wine_by.dart';
import '../entities/carousel_item.dart';

abstract class WineRepository {
  Future<List<WineBy>> getWinesBy();
  Future<List<CarouselItem>> getCarouselItems();
}
