import '../../domain/entities/wine_by.dart';
import '../../domain/entities/carousel_item.dart';
import '../../domain/repositories/wine_repository.dart';
import '../datasources/local_wine_data_source.dart';

class WineRepositoryImpl implements WineRepository {
  final LocalWineDataSource localWineDataSource;

  WineRepositoryImpl(this.localWineDataSource);

  @override
  Future<List<WineBy>> getWinesBy() async {
    return await localWineDataSource.getWinesBy();
  }

  @override
  Future<List<CarouselItem>> getCarouselItems() async {
    final carouselItemsModel = await localWineDataSource.getCarouselItems();
    return carouselItemsModel.map((item) => CarouselItem(
      name: item.name,
      image: item.image,
      criticScore: item.criticScore,
      bottleSize: item.bottleSize,
      priceUsd: item.priceUsd,
      type: item.type,
      country: item.country,
      city: item.city,
    )).toList();
  }
}
