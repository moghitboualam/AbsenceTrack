import 'package:dio/dio.dart';
import '../../services/api_service.dart';
import 'admin_endpoints.dart';
import '../../dto/semestre/semestre_dto.dart';

class AdminSemestreService {
  final Dio _dio = ApiService().dio;

  Future<List<SemestreDto>> getAllSemestres() async {
    try {
      final response = await _dio.get('${AdminEndpoints.semestreBase}'); // Assuming generic get all exists
      // If the API returns a page, we might need to handle content. 
      // Based on typical spring boot, if it returns list:
      if (response.data is List) {
        return (response.data as List).map((e) => SemestreDto.fromJson(e)).toList();
      } else if (response.data is Map && response.data['content'] != null) {
         return (response.data['content'] as List).map((e) => SemestreDto.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      // Fallback or rethrow
      return [];
    }
  }
  
  // Helper to find ID by name (S1) and maybe current year logic?
  // implementation depends on what getAllSemestres returns.
}
