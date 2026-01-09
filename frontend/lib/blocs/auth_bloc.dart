import 'package:dio/dio.dart' as dio_lib;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';

abstract class AuthEvent {}
class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  LoginRequested(this.email, this.password);
}
class GoogleLoginRequested extends AuthEvent {
  final String accessToken;
  GoogleLoginRequested(this.accessToken);
}
class UpdateProfileRequested extends AuthEvent {
  final String firstName;
  final String lastName;
  final String? bio;
  final String? profilePicture;
  final int? age;
  final String? address;
  final String? phoneNumber;
  final String? gender;

  UpdateProfileRequested({
    required this.firstName, 
    required this.lastName, 
    this.bio, 
    this.profilePicture,
    this.age,
    this.address,
    this.phoneNumber,
    this.gender,
  });
}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  RegisterRequested(this.email, this.password, this.firstName, this.lastName);
}
class LogoutRequested extends AuthEvent {}
class AuthCheckRequested extends AuthEvent {}


abstract class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class Authenticated extends AuthState {
  final User user;
  Authenticated(this.user);
}
class Unauthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc(this.authRepository) : super(AuthInitial()) {
    authRepository.apiClient.onUnauthorized = () {
      add(LogoutRequested());
    };

    on<AuthCheckRequested>((event, emit) async {
      try {
        if (authRepository.apiClient.hasToken) {
          final user = await authRepository.getProfile().timeout(const Duration(seconds: 10));
          emit(Authenticated(user));
        } else {
          emit(Unauthenticated());
        }
      } catch (e) {
        if (e is dio_lib.DioException && (e.response?.statusCode == 401 || e.response?.statusCode == 403)) {
          authRepository.apiClient.clearToken();
          emit(Unauthenticated());
        } else {
          emit(AuthError("Connection lost. Please check your internet."));
        }
      }
    });

    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.login(event.email, event.password);
        final user = await authRepository.getProfile();
        emit(Authenticated(user));
      } catch (e) {
        emit(AuthError(_handleError(e)));
      }
    });

    on<GoogleLoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.googleLogin(event.accessToken);
        final user = await authRepository.getProfile();
        emit(Authenticated(user));
      } catch (e) {
        emit(AuthError(_handleError(e)));
      }
    });

    on<RegisterRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.register(event.email, event.password, event.firstName, event.lastName);
        await authRepository.login(event.email, event.password);
        final user = await authRepository.getProfile();
        emit(Authenticated(user));
      } catch (e) {
        emit(AuthError(_handleError(e)));
      }
    });

    on<UpdateProfileRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await authRepository.getProfile();
        final updatedUser = user.copyWith(
          firstName: event.firstName, 
          lastName: event.lastName,
          bio: event.bio,
          profilePicture: event.profilePicture,
          age: event.age,
          address: event.address,
          phoneNumber: event.phoneNumber,
          gender: event.gender,
        );
        
        final confirmedUser = await authRepository.updateProfile(updatedUser);
        emit(Authenticated(confirmedUser));
      } catch (e) {
        try {
           final user = await authRepository.getProfile();
           emit(Authenticated(user));
        } catch (_) {
           emit(AuthError(_handleError(e)));
        }
      }
    });



    on<LogoutRequested>((event, emit) {
      authRepository.apiClient.clearToken();
      emit(Unauthenticated());
    });
  }

  String _handleError(Object e) {
    if (e is dio_lib.DioException) {
      if (e.response?.data != null && e.response?.data is Map) {
        final data = e.response?.data as Map;
        if (data.containsKey('detail')) return data['detail'].toString();
        if (data.containsKey('error')) return data['error'].toString();
        if (data.isNotEmpty) {
          final firstEntry = data.entries.first;
          return "${firstEntry.key}: ${firstEntry.value is List ? (firstEntry.value as List).join(', ') : firstEntry.value}";
        }
      }
      return e.message ?? "An unexpected error occurred";
    }
    return e.toString();
  }
}
