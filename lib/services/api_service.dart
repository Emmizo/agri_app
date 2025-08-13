import 'dart:io';
import 'package:dio/dio.dart';
import '../models/classification_result.dart';
import '../models/history_response.dart';

class ApiService {
  static const String baseUrl = 'https://hilaire01.pythonanywhere.com/api';
  final Dio _dio = Dio();

  ApiService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);

    // Add interceptors for better error handling
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          print('API Error: ${error.message}');
          handler.next(error);
        },
        onRequest: (options, handler) {
          print('API Request: ${options.method} ${options.path}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          print('API Response: ${response.statusCode}');
          handler.next(response);
        },
      ),
    );
  }

  // Classify image endpoint
  Future<ClassificationResult> classifyImage(File imageFile) async {
    try {
      String fileName = imageFile.path.split('/').last;

      FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      Response response = await _dio.post('/classify/', data: formData);
      return ClassificationResult.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['error'] ?? 'Upload failed');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Get history endpoint
  Future<HistoryResponse> getHistory({int page = 1, int limit = 20}) async {
    try {
      Response response = await _dio.get(
        '/history/',
        queryParameters: {'page': page, 'limit': limit},
      );
      return HistoryResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['error'] ?? 'Failed to fetch history');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Get classification detail endpoint
  Future<ClassificationResult> getClassificationDetail(String classificationId) async {
    try {
      Response response = await _dio.get('/classification/$classificationId/');
      return ClassificationResult.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['error'] ?? 'Failed to fetch classification detail');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
