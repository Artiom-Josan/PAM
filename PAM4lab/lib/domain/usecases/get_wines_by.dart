import '../entities/wine_by.dart';
import '../repositories/wine_repository.dart';

class GetWinesBy {
  final WineRepository repository;

  GetWinesBy(this.repository);

  Future<List<WineBy>> call() async {
    return await repository.getWinesBy();
  }
}
