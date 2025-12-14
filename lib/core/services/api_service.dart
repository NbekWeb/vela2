import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';
import 'dart:typed_data';
import '../constants/navigator_key.dart';

class ApiService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://31.97.98.47:9000/api/',
      ),
      connectTimeout: const Duration(minutes: 10),
      receiveTimeout: const Duration(minutes: 10),
      sendTimeout: const Duration(minutes: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  static final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static String? _memoryToken; // Store token from memory

  // Get memory token for debugging
  static String? get memoryToken => _memoryToken;
  
  // Get base URL for debugging
  static String get baseUrl => _dio.options.baseUrl;

  // Set token from memory (called by AuthStore)
  static void setMemoryToken(String? token) {
    _memoryToken = token;
  }

  static void init() {
    _dio.interceptors.clear();
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            var token = await _storage.read(key: 'access_token');

            // If token not in storage, try to get from memory
            if (token == null &&
                _memoryToken != null &&
                !(options.extra['open'] == true)) {
              // Save token to storage for future use
              try {
                await _storage.write(key: 'access_token', value: _memoryToken);
                token = _memoryToken;
              } catch (e) {
                // If token already exists, delete it first then write
                if (e.toString().contains('already exists')) {
                  try {
                    await _storage.delete(key: 'access_token');
                    await _storage.write(
                      key: 'access_token',
                      value: _memoryToken,
                    );
                    token = _memoryToken;
                  } catch (deleteError) {
                    token = _memoryToken;
                  }
                } else {
                  token = _memoryToken;
                }
              }
            }

            if (token != null && !(options.extra['open'] == true)) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          } catch (e) {
            // Continue without token if there's an error
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            try {
              await _storage.delete(key: 'access_token');
            } catch (deleteError) {
              // Error deleting token
            }
            // Optionally, you can use a callback or event to trigger navigation to login
            if (navigatorKey.currentState != null) {
              navigatorKey.currentState!.pushNamedAndRemoveUntil(
                '/login',
                (route) => false,
              );
            }
          }

          return handler.next(e);
        },
      ),
    );
  }

  static Future<Response<T>> request<T>({
    required String url,
    bool open = false,
    String method = 'GET',
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    
    // Merge headers with default Content-Type
    final mergedHeaders = <String, dynamic>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?headers,
    };
    
    final options = Options(
      method: method,
      headers: mergedHeaders,
      extra: {'open': open},
    );
    
    try {
      // Debug: to'liq URL ni print qilish
      final fullUrl = '${_dio.options.baseUrl}$url';
      print('🔄 [ApiService.request] Method: $method');
      print('🔄 [ApiService.request] Base URL: ${_dio.options.baseUrl}');
      print('🔄 [ApiService.request] Endpoint: $url');
      print('🔄 [ApiService.request] Full URL: $fullUrl');
      
      final response = await _dio.request<T>(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      
      print('✅ [ApiService.request] Response status: ${response.statusCode}');
      return response;
    } catch (e) {
      print('❌ API Error: $e');
      if (e is DioException && e.response != null) {
        print('❌ Response status: ${e.response?.statusCode}');
        print('❌ Response data: ${e.response?.data}');
        print('❌ Request data: ${e.requestOptions.data}');
        print('❌ Request headers: ${e.requestOptions.headers}');
      }
      rethrow;
    }
  }

  // Method for file uploads
  static Future<Response<T>> uploadFile<T>({
    required String url,
    bool open = false,
    String method = 'POST',
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    print('🔄 [ApiService.uploadFile] Boshlanmoqda...');
    print('🔄 [ApiService.uploadFile] URL: $url');
    print('🔄 [ApiService.uploadFile] Method: $method');
    print('🔄 [ApiService.uploadFile] Data keys: ${data?.keys.toList() ?? 'null'}');
    
    final token = await _storage.read(key: 'access_token');
    print('🔄 [ApiService.uploadFile] Token mavjud: ${token != null}');

    // Dio FormData yuborganda Content-Type ni o'zi to'g'ri qo'shadi (multipart/form-data + boundary)
    // Shuning uchun Content-Type ni manual qo'ymaymiz
    final requestHeaders = <String, dynamic>{
      ...headers ?? {},
      if (token != null && !open) 'Authorization': 'Bearer $token',
    };

    final options = Options(
      method: method,
      headers: requestHeaders,
    );
    
    print('🔄 [ApiService.uploadFile] Headers: $requestHeaders');

    // Convert data to FormData if it contains file paths
    dynamic formData;
    if (data != null) {
      formData = FormData();
      print('🔄 [ApiService.uploadFile] FormData yaratilmoqda...');

      int fileCount = 0;
      int fieldCount = 0;
      
      for (var entry in data.entries) {
        if (entry.value is Uint8List) {
          // This is file bytes (image, audio, etc.), add as file
          // Determine file extension based on key name
          String filename = 'file';
          String extension = 'bin';
          
          if (entry.key == 'file_wav' || entry.key == 'wav') {
            filename = 'meditation.wav';
            extension = 'wav';
          } else if (entry.key == 'avatar' || entry.key == 'image') {
            filename = 'avatar.jpg';
            extension = 'jpg';
          } else {
            filename = '${entry.key}.$extension';
          }
          
          print('🔄 [ApiService.uploadFile] File qo\'shilmoqda: $entry.key -> $filename (${(entry.value as Uint8List).length} bytes)');
          
          formData.files.add(
            MapEntry(
              entry.key, // Use the key name from data
              MultipartFile.fromBytes(entry.value, filename: filename),
            ),
          );
          fileCount++;
        } else if (entry.value is String &&
            entry.value.toString().startsWith('/')) {
          // This is a file path, add as file
          final file = File(entry.value);
          if (await file.exists()) {
            print('🔄 [ApiService.uploadFile] File path qo\'shilmoqda: $entry.key -> ${file.path}');
            formData.files.add(
              MapEntry(
                entry.key,
                await MultipartFile.fromFile(
                  file.path,
                  filename: file.path.split('/').last,
                ),
              ),
            );
            fileCount++;
          }
        } else if (entry.value is String &&
            entry.value.toString().startsWith('blob:')) {
          // This is a blob URL, we need to convert it to bytes
          try {
            // For web, we need to fetch the blob data
            // This is a simplified approach - in a real app you might want to use a different method
            final response = await _dio.get(
              entry.value.toString(),
              options: Options(responseType: ResponseType.bytes),
            );

            if (response.data is Uint8List) {
              formData.files.add(
                MapEntry(
                  entry.key,
                  MultipartFile.fromBytes(
                    response.data,
                    filename: 'avatar.jpg',
                  ),
                ),
              );
              fileCount++;
            }
          } catch (e) {
            // If blob conversion fails, send as field
            formData.fields.add(MapEntry(entry.key, entry.value.toString()));
            fieldCount++;
          }
        } else {
          // This is regular data
          final key = entry.key;
          final value = entry.value.toString();
          print('🔄 [ApiService.uploadFile] Field qo\'shilmoqda: $key = $value');
          formData.fields.add(MapEntry(key, value));
          fieldCount++;
        }
      }
      
      print('✅ [ApiService.uploadFile] FormData tayyor: $fileCount file, $fieldCount field');
      print('🔄 [ApiService.uploadFile] FormData fields: ${formData.fields.map((e) => '${e.key}=${e.value}').join(', ')}');
      print('🔄 [ApiService.uploadFile] FormData files: ${formData.files.map((e) => '${e.key} (${e.value.filename})').join(', ')}');
    } else {
      print('⚠️ [ApiService.uploadFile] Data null, FormData yaratilmaydi');
      formData = FormData(); // Bo'sh FormData yaratish
    }

    print('🔄 [ApiService.uploadFile] Request yuborilmoqda...');
    print('🔄 [ApiService.uploadFile] Full URL: ${_dio.options.baseUrl}$url');
    print('🔄 [ApiService.uploadFile] FormData type: ${formData.runtimeType}');
    
    try {
      final response = await _dio.request<T>(
        url,
        data: formData,
        queryParameters: queryParameters,
        options: options,
      );
      
      print('✅ [ApiService.uploadFile] Response keldi: ${response.statusCode}');
      return response;
    } catch (e) {
      print('❌ [ApiService.uploadFile] Xatolik: $e');
      if (e is DioException) {
        print('❌ [ApiService.uploadFile] DioException type: ${e.type}');
        print('❌ [ApiService.uploadFile] Response: ${e.response?.data}');
      }
      rethrow;
    }
  }
}
