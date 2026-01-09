import 'package:dio/dio.dart';
import '../models/user.dart';
import '../services/api_client.dart';
import 'dart:convert';
import 'package:http_parser/http_parser.dart';

class AuthRepository {
  final ApiClient apiClient;

  AuthRepository(this.apiClient);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      apiClient.clearToken();
      final response = await apiClient.dio.post(
        'users/login/', 
        data: {
          'email': email,
          'password': password,
        },
        options: Options(contentType: 'application/json'),
      );
      final data = response.data;
      apiClient.setToken(data['access']);
      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> googleLogin(String accessToken) async {
    try {
      apiClient.clearToken();
      final response = await apiClient.dio.post(
        'users/google/', 
        data: {
          'access_token': accessToken,
        },
        options: Options(contentType: 'application/json'),
      );
      final data = response.data;
      // dj_rest_auth might return 'key' instead of 'access' depending on config, but with SimpleJWT it returns 'access' and 'refresh'
      apiClient.setToken(data['access_token'] ?? data['access'] ?? data['key']);
      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<User> register(String email, String password, String firstName, String lastName) async {
    try {
      apiClient.clearToken();
      final response = await apiClient.dio.post(
        'users/register/', 
        data: {
          'email': email,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
        },
        options: Options(contentType: 'application/json'),
      );
      return User.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<User> getProfile() async {
    try {
      final response = await apiClient.dio.get('users/me/');
      return User.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<User> updateProfile(User user) async {
    try {
      Map<String, dynamic> data = {
        'first_name': user.firstName,
        'last_name': user.lastName,
        'bio': user.bio,
        'age': user.age,
        'address': user.address,
        'phone_number': user.phoneNumber,
        'gender': user.gender,
      };

      if (user.profilePicture != null) {
        if (user.profilePicture!.startsWith('data:image')) {
          final commaIndex = user.profilePicture!.indexOf(',');
          if (commaIndex != -1) {
            final base64Content = user.profilePicture!.substring(commaIndex + 1);
            final bytes = base64.decode(base64Content);
            data['profile_picture'] = MultipartFile.fromBytes(
              bytes,
              filename: 'profile_pic.jpg',
              contentType: DioMediaType.parse('image/jpeg'),
            );
          }
        } else if (user.profilePicture!.isEmpty) {
          // If empty string is passed, we might want to tell the server to clear it
          // In some APIs you send null or a specific value. For Django ImageField, 
          // sending an empty value in multipart often clears it or we need a separate flag.
          data['profile_picture'] = null;
        }
      }

      final response = await apiClient.dio.patch(
        'users/me/', 
        data: FormData.fromMap(data),
      );
      return User.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
