# Install Flutter packages
flutter pub add flutter_bloc
flutter pub add freezed_annotation
flutter pub add json_annotation
flutter pub add get_it
flutter pub add dartz
flutter pub add dio
flutter pub add injectable
flutter pub add go_router
flutter pub add google_fonts
flutter pub add shared_preferences
dart pub add dev:build_runner
flutter pub add --dev build_runner freezed json_serializable injectable_generator

Write-Host "➡️ Packages Installed successfully! ✅"

# Create necessary directories
mkdir -p ./assets/images
mkdir -p ./assets/icons
mkdir -p ./assets/fonts
mkdir -p ./lib/services/apis
mkdir -p ./lib/services/blocservice
mkdir -p ./lib/GoRouter
mkdir -p ./lib/application
mkdir -p ./lib/domain
mkdir -p ./lib/domain/failures
mkdir -p ./lib/domain/core/dependencies_injection
mkdir -p ./lib/infrastructure
mkdir -p ./lib/presentation
mkdir -p ./lib/presentation/widgets
mkdir -p ./lib/Observer

Write-Host "➡️ Directories Created successfully! ✅"

# Create and populate the necessary files
Set-Content ./lib/services/apis/api_end_points.dart @'
abstract class ApiConfig {
  static const baseUrl ="";
}

class ApiEndPoints {
static const test = ApiConfig.baseUrl;
}
'@

Set-Content ./lib/services/blocservice/Mulit_bloc_provider_service.dart @'
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Mulit_bloc_provider_service extends StatelessWidget {
  Widget child;

  Mulit_bloc_provider_service({
    super.key,
    required  this.child
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ,
        ),
        BlocProvider(create: (context) => ,)
      ],
      child: child,
    );
  }
}
'@

Set-Content ./lib/domain/failures/main_failures.dart @'
import 'package:freezed_annotation/freezed_annotation.dart';
part 'main_failures.freezed.dart';

@freezed
class MainFailures with _$MainFailures {
  const factory MainFailures.clientFailures() = _ClientFailures;
  const factory MainFailures.serverFailures() = _ServerFailures;
}
'@

Set-Content ./lib/domain/core/dependencies_injection/injectable.dart @'
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init', // default
  preferRelativeImports: true, // default
  asExtension: true, // default
)
configureDependencies() => getIt.init();
'@

Set-Content ./lib/Observer/gorouter_observer.dart @'
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
'@

Set-Content ./lib/Observer/bloc_observer.dart @'
import 'package:flutter_bloc/flutter_bloc.dart';

class MyBlocObserver extends BlocObserver {
  @override
  void onTransition(Bloc bloc, Transition transition) {
    print('Transition: $transition');
    super.onTransition(bloc, transition);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print('onError -- ${bloc.runtimeType}, $error');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    print('onClose -- ${bloc.runtimeType}');
  }
}
'@

Set-Content ./lib/GoRouter/gorouter.dart @'
import 'package:go_router/go_router.dart';
import '../Observer/gorouter_observer.dart';

class AppRouter {
  static const root = '/';
  static const allBlogs = '/blogs';
  static const favoriteBlogs = '/favorite';
  static const singleArticle = '/article';

  static GoRouter router = GoRouter(
    initialLocation: '/',
    observers: [MyNavigatorObserver()],
    routes: [
      GoRoute(
        name: 'Home',
        path: root,
        builder: (context, state) {
          return HomePage();
        },
      ),
      GoRoute(
        name: 'Blog',
        path: allBlogs,
        builder: (context, state) {
          return blogs();
        },
      ),
    ],
  );
}
'@

# Run build_runner to generate code
flutter pub run build_runner build --delete-conflicting-outputs

Write-Host "➡️ Clean architecture created successfully! ✅"
