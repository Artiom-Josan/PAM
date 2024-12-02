import '../entities/carousel_item.dart';
import '../repositories/wine_repository.dart';

class GetCarouselItems {
  final WineRepository repository;

  GetCarouselItems(this.repository);

  Future<List<CarouselItem>> call() async {
    return await repository.getCarouselItems();
  }
}
