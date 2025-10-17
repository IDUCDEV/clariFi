import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/category.dart';
import 'category_repository.dart';

class SupabaseCategoryRepository implements CategoryRepository {
  final SupabaseClient _supabase;

  SupabaseCategoryRepository(this._supabase);

  @override
  Future<List<CategoryModel>> fetchAllCategories({required String? type}) async {
    try {
      final user = _supabase.auth.currentUser;

      if (user == null) {
        print('⚠️ Usuario no autenticado. No se puede obtener categorías.');
        return [];
      }

      print('✅ Usuario autenticado: ${user.id}');

      var query = _supabase.from('categories').select();

      if (type != null) {
        query = query.eq('type', type);
      }

      final response = await query.order('name', ascending: true);

      // Imprime lo que devuelve la DB
      print('📝 Response categories: $response');

      return (response as List)
          .map((e) => CategoryModel.fromJson(e))
          .toList();
    } on PostgrestException catch (e) {
      print('❌ PostgrestException: ${e.message}');
      return [];
    } on Exception catch (e) {
      print('❌ Exception al obtener categorías: $e');
      return [];
    }
  }
}
