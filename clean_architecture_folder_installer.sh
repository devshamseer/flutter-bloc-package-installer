#!/bin/bash

# Create Assets directories
mkdir -p ./assets/images
mkdir -p ./assets/icons
mkdir -p ./assets/fonts

# Create Services
mkdir -p ./lib/services/apis
mkdir -p ./lib/services/apis/api_impl
touch ./lib/services/apis/api_impl/auth_api_impl.dart
mkdir -p ./lib/services/apis/api_service
touch ./lib/services/apis/api_service/auth_api_service.dart
mkdir -p ./lib/services/apis/dio_client
touch ./lib/services/apis/dio_client/dio_client.dart
touch ./lib/services/apis/api_end_points.dart

mkdir -p ./lib/services/blocservice
touch ./lib/services/blocservice/Mulit_bloc_provider_service.dart

# Create GoRouter
mkdir -p ./lib/router
touch  ./lib/router/app_router.dart

# Application & Domain Layer
mkdir -p ./lib/application
mkdir -p ./lib/domain
mkdir -p ./lib/domain/failures
touch ./lib/domain/failures/main_failures.dart

# Dependency Injection
mkdir -p ./lib/domain/core/dependencies_injection
mkdir -p ./lib/infrastructure
mkdir -p ./lib/presentation
mkdir -p ./lib/presentation/widgets

# Observers
mkdir -p ./lib/Observer
touch ./lib/Observer/bloc_observer.dart
touch ./lib/Observer/gorouter_observer.dart

# Injectable file
cat <<EOT > ./lib/domain/core/dependencies_injection/injectable.dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init', // default
  preferRelativeImports: true, // default
  asExtension: true, // default
)
configureDependencies() => getIt.init();
EOT

# API Endpoints
cat <<EOT > ./lib/services/apis/api_end_points.dart
abstract class ApiConfig {
  static const baseUrl = "";
}

class ApiEndPoints {
  static const test = ApiConfig.baseUrl;
}
EOT

# MultiBlocProvider Service
cat <<EOT > ./lib/services/blocservice/Mulit_bloc_provider_service.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Mulit_bloc_provider_service extends StatelessWidget {
  final Widget child;

  const Mulit_bloc_provider_service({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Add your BlocProviders here
        // BlocProvider(create: (context) => YourBloc()),
      ],
      child: child,
    );
  }
}
EOT

# Main Failures
cat <<'EOT' > ./lib/domain/failures/main_failures.dart
import 'package:freezed_annotation/freezed_annotation.dart';
part 'main_failures.freezed.dart';

@freezed
class MainFailures with _$MainFailures {
  const factory MainFailures.clientFailures() = _ClientFailures;
  const factory MainFailures.serverFailures() = _ServerFailures;
}
EOT

# GoRouter Observer
cat <<EOT > ./lib/Observer/gorouter_observer.dart
import 'dart:developer';
import 'package:flutter/material.dart';

class MyNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    log('did push route');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    log('did pop route');
  }
}
EOT

# Bloc Observer
cat <<'EOT' > ./lib/Observer/bloc_observer.dart
import 'package:flutter_bloc/flutter_bloc.dart';

class MyBlocObserver extends BlocObserver {
  @override
  void onTransition(Bloc bloc, Transition transition) {
    print('Transition: \$transition');
    super.onTransition(bloc, transition);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print('onError -- \${bloc.runtimeType}, \$error');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    print('onClose -- \${bloc.runtimeType}');
  }
}
EOT

# GoRouter Setup
cat > ./lib/router/app_router.dart <<EOL
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../Observer/gorouter_observer.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static const root = '/';
  static const expenseDetails = '/ExpenseDetails';
  static const expenseDetailsChartById = '/expenseDetailsChartById';
  static const singleArticle = '/article';

  static GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: root,
    observers: [MyNavigatorObserver()],
    redirect: (context, state) async {
      log("redirect \${state.fullPath}");
      return null;
    },
    routes: [
      GoRoute(
        name: root,
        path: root,
        builder: (context, state) {
          return const Placeholder(); // Replace with HomePage() widget
        },
      ),
    ],
  );

  static void closeBottomSheet() {
    if (navigatorKey.currentState?.canPop() ?? false) {
      navigatorKey.currentState?.pop();
    }
  }

  static void navigateTo(String route, {Object? extra}) {
    navigatorKey.currentState?.pushNamed(route, arguments: extra);
  }

  static void navigateIf(bool condition, String route, {Object? extra}) {
    if (condition) {
      navigateTo(route, extra: extra);
    }
  }

  static void goBack() {
    if (navigatorKey.currentState?.canPop() ?? false) {
      navigatorKey.currentState?.pop();
    }
  }

  static String? getCurrentRoute() {
    return navigatorKey.currentContext?.widget.toStringShort();
  }

  static void replaceWith(String route, {Object? extra}) {
    navigatorKey.currentState?.pushReplacementNamed(route, arguments: extra);
  }

  static void clearStackAndNavigate(String route, {Object? extra}) {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(route, (route) => false, arguments: extra);
  }

  static void showSnackbar({required SnackBar snackBar}) {
    ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(snackBar);
  }

  static Future<bool> showExitAppDilog({required String title, required String message}) async {
    return await showDialog(
          context: navigatorKey.currentContext!,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
              TextButton(onPressed: () => SystemNavigator.pop(), child: const Text("Confirm")),
            ],
          ),
        ) ??
        false;
  }

  static Future<bool> onWillPop() async {
    log("ExitApp Calling");
    bool shouldExit = await showExitAppDilog(
      title: "Exit App",
      message: "Are you sure you want to exit?",
    );
    return shouldExit;
  }

  static BuildContext? currentStateContext() {
    return navigatorKey.currentState?.context;
  }

  static void go({required String routerPath, Object? extra}) {
    log("Go Route \$routerPath extra \${extra.toString()}");
    navigatorKey.currentContext?.push(routerPath, extra: extra);
  }
}
EOL

echo "➡️ Clean architecture created successfully! ✅"

# Create files and code for DioClient and TokenStorage
mkdir -p ./lib/services/apis/dio_client

# dio_client.dart
cat <<EOL > ./lib/services/apis/dio_client/dio_client.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api_end_points.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late Dio dio;

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    _initializeInterceptors();
  }

  /// Sets Bearer token
  void setToken(String token) {
    dio.options.headers["Authorization"] = "Bearer \$token";
  }

  /// Removes token
  void clearToken() {
    dio.options.headers.remove("Authorization");
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      setToken(token);
    }
  }

  Dio get client => dio;

  void _initializeInterceptors() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (kDebugMode) {
            debugPrint('--> \${options.method} \${options.path}');
            debugPrint('Headers: \${options.headers}');
            debugPrint('Body: \${options.data}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            debugPrint('<-- \${response.statusCode} \${response.requestOptions.path}');
            debugPrint('Response: \${response.data}');
          }
          return handler.next(response);
        },
        onError: (DioError error, handler) {
          if (kDebugMode) {
            debugPrint('❌ Error: \${error.response?.statusCode} \${error.message}');
            debugPrint('Path: \${error.requestOptions.path}');
          }

          // Handle token expiration (401)
          if (error.response?.statusCode == 401) {
            // TODO: refresh token or redirect to login
          }

          return handler.next(error);
        },
      ),
    );
  }
}
EOL

# TokenStorage file
cat <<EOL > ./lib/services/apis/token_storage.dart
import 'package:shared_preferences/shared_preferences.dart';

abstract class TokenStorage {
  Future<void> saveToken(String token);
  Future<String?> loadToken();
  Future<void> clearToken();
}

class SharedPreferencesTokenStorage implements TokenStorage {
  @override
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  @override
  Future<String?> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  @override
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}
EOL

# AuthApiService
cat <<EOL > ./lib/services/apis/api_service/auth_api_service.dart
abstract class AuthApiService {
  Future login({required String email, required String password});
  Future logout();
}
EOL

# AuthApiServiceImpl
cat <<EOL > ./lib/services/apis/api_impl/auth_api_impl.dart
import 'package:dio/dio.dart';

import '../api_service/auth_api_service.dart';
import '../dio_client/dio_client.dart';
import '../token_storage.dart';

class AuthApiServiceImpl extends AuthApiService {
  final Dio _dio = DioClient().client;
  final TokenStorage _tokenStorage = SharedPreferencesTokenStorage();

  @override
  Future login({required String email, required String password}) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final token = response.data['token'];
      await _tokenStorage.saveToken(token);
      DioClient().setToken(token); // Set token for future calls

      return true;
    } on DioException catch (e) {
      print('Login failed: ${e.response?.data}');
      return false;
    }
  }

  @override
  Future logout() async {
    await _tokenStorage.clearToken();
    DioClient().clearToken();
  }
}
EOL

echo "➡️ API client, token storage, and authentication service implemented successfully! ✅"
