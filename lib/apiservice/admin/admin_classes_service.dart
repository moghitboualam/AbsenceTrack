import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dashboard_app/services/api_service.dart';
import 'package:flutter_dashboard_app/apiservice/admin/admin_endpoints.dart';
import 'package:flutter_dashboard_app/dto/classes/classes_dto.dart';
import 'package:flutter_dashboard_app/dto/classes/classes_request.dart';

class AdminClassesService {
  final Dio _dio = ApiService().dio;
  // Note: We might need to add CLASSES endpoints to admin_endpoints.dart if not present,
  // or use raw strings/interpolation if it's easier right now.
  // The provided code used raw strings. I'll stick to raw strings or define them.
  // Let's check adminEndpoints.dart in frontend -> It had CLASSES.
  // Did I update admin_endpoints.dart in Flutter? Not yet.
  // So I will use hardcoded paths matching the React service for now or use AdminEndpoints if available?
  // AdminEndpoints in Flutter likely doesn't have CLASSES yet.
  // I will use raw paths to avoid another file edit cycle if possible, or check AdminEndpoints.
  
  final String _baseEndpoint = "/admin/classess";

  // Get All Classes
  Future<Map<String, dynamic>> getAllClasses({
    int page = 0,
    int size = 10,
    String sort = 'id,asc',
  }) async {
    final response = await _dio.get(
      _baseEndpoint,
      queryParameters: {
        'page': page,
        'size': size,
        'sort': sort,
      },
    );
    // Dio returns the data object directly, usually as Map or List depending on implementation.
    // admin_etudiant_service expects response.data to have content.
    return response.data; 
  }

  // Create Class
  Future<ClassesDto> createClass(ClassesRequest request) async {
    final response = await _dio.post(
      _baseEndpoint,
      data: request.toJson(),
    );
    return ClassesDto.fromJson(response.data);
  }

  // Get Class By ID
  Future<ClassesDto> getClassById(int id) async {
    final response = await _dio.get("$_baseEndpoint/$id");
    return ClassesDto.fromJson(response.data);
  }

  // Update Class
  Future<ClassesDto> updateClass(int id, ClassesRequest request) async {
    final response = await _dio.put(
      "$_baseEndpoint/$id",
      data: request.toJson(),
    );
    return ClassesDto.fromJson(response.data);
  }

  // Delete Class
  Future<void> deleteClass(int id) async {
    await _dio.delete("$_baseEndpoint/$id");
  }

  // Get Classes by Promotion ID
  Future<List<ClassesDto>> getClassesByPromotionId(int promotionId) async {
    final response = await _dio.get("$_baseEndpoint/byPromotion/$promotionId");
    final List<dynamic> data = response.data;
    return data.map((e) => ClassesDto.fromJson(e)).toList();
  }

  // Assign Students to Classes
  Future<String> assignStudentsToClasses(int promotionId) async {
    final response = await _dio.post("$_baseEndpoint/assign-students/$promotionId");
    return response.data.toString();
  }
}
