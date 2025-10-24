// domain/repositories/category_repository.dart
import '../../models/category.dart';

abstract class CategoryRepository {
  /// Si [type] no es null, filtra las categorías por tipo.
  Future<List<CategoryModel>> fetchAllCategories({required String? type});
}
