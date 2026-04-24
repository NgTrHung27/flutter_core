# Flutter Core

A production-ready Flutter application demonstrating **Clean Architecture**, **BLoC pattern**, and **best practices** for Flutter development.

## 📋 Mục lục

- [Giới thiệu](#giới-thiệu)
- [Kiến trúc](#kiến-trúc)
- [Cấu trúc thư mục](#cấu-trúc-thư-mục)
- [Tính năng](#tính-năng)
- [Dependencies](#dependencies)
- [Setup & Run](#setup--run)
- [Testing](#testing)
- [Performance Monitoring](#performance-monitoring)
- [Error Handling](#error-handling)
- [Dependency Injection](#dependency-injection)
- [Thêm tính năng mới](#thêm-tính-năng-mới)

---

## Giới thiệu

Flutter Core là một ứng dụng Flutter minh họa cách xây dựng ứng dụng theo **Clean Architecture** với các best practices:

- **State Management**: BLoC pattern với `flutter_bloc`
- **Dependency Injection**: `get_it` cho DI container
- **Error Handling**: Functional programming với `fpdart` (Either type)
- **Data Layer**: Repository pattern, local/remote data sources
- **Testing**: Unit tests, BLoC tests, Integration tests

---

## Kiến trúc

### Clean Architecture Layers

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                    │
│         (Pages, Widgets, BLoCs, Events, States)         │
├─────────────────────────────────────────────────────────┤
│                      Domain Layer                        │
│         (Entities, Repositories, Use Cases)              │
├─────────────────────────────────────────────────────────┤
│                       Data Layer                         │
│   (Models, Data Sources, Repository Implementations)     │
├─────────────────────────────────────────────────────────┤
│                      Core Layer                          │
│    (API, Cache, Network, Routes, Themes, Utils)         │
└─────────────────────────────────────────────────────────┘
```

### Error Handling Pattern

```
┌──────────┐     ┌──────────────┐     ┌───────────┐
│ DataSource│────▶│  Repository  │────▶│  UseCase  │────▶ BLoC
│  (throws) │     │  (catches)   │     │(Either<T>)│     (fold)
└──────────┘     └──────────────┘     └───────────┘
     │                  │                    │
     ▼                  ▼                    ▼
 Exceptions       Failures (Left)      Success (Right)
```

---

## Cấu trúc thư mục

```
flutter_core/
├── lib/
│   ├── core/                          # Shared utilities
│   │   ├── api/                      # HTTP client, exceptions, interceptors
│   │   │   ├── api_helper.dart
│   │   │   ├── api_exception.dart
│   │   │   ├── api_interceptor.dart
│   │   │   └── api_url.dart
│   │   ├── blocs/                    # Global BLoCs
│   │   │   ├── theme/
│   │   │   └── translate/
│   │   ├── cache/                    # Local storage
│   │   │   ├── hive_local_storage.dart
│   │   │   └── secure_local_storage.dart
│   │   ├── configs/injector/         # DI configuration
│   │   │   ├── injector_conf.dart
│   │   │   └── injector.dart
│   │   ├── errors/                   # Error classes
│   │   │   ├── failures.dart
│   │   │   └── exceptions.dart
│   │   ├── monitoring/               # Performance monitoring
│   │   │   ├── performance_monitor.dart
│   │   │   ├── performance_overlay.dart
│   │   │   └── devtools_panel.dart
│   │   ├── network/                  # Network utilities
│   │   ├── routes/                  # Navigation
│   │   │   ├── app_route_path.dart
│   │   │   └── app_route_conf.dart
│   │   ├── themes/                  # App themes
│   │   └── utils/                   # Utilities
│   │       ├── failure_converter.dart
│   │       ├── logger.dart
│   │       └── native_*.dart
│   │
│   ├── features/                    # Feature modules
│   │   ├── auth/                    # Authentication
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   ├── exceptions/
│   │   │   │   ├── models/
│   │   │   │   └── repositories/
│   │   │   ├── di/                 # Feature DI
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   ├── failures/
│   │   │   │   ├── repositories/
│   │   │   │   └── usecases/
│   │   │   └── presentation/
│   │   │       ├── bloc/
│   │   │       ├── pages/
│   │   │       └── widgets/
│   │   │
│   │   ├── home/                   # Home feature
│   │   │   ├── data/
│   │   │   ├── di/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   ├── isolate_demo/           # Isolate demo
│   │   │   ├── data/
│   │   │   ├── di/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   └── profiling/              # Profiling & monitoring
│   │       ├── data/
│   │       ├── di/
│   │       ├── domain/
│   │       └── presentation/
│   │
│   ├── widgets/                    # Shared widgets
│   └── main.dart
│
├── test/                            # Unit & widget tests
│   ├── features/
│   │   ├── auth/
│   │   ├── home/
│   │   ├── isolate_demo/
│   │   └── profiling/
│   ├── mocks/
│   └── widgets/
│
├── integration_test/               # E2E tests
│   ├── app_test.dart
│   ├── navigation_flow_test.dart
│   └── feature_flows_test.dart
│
└── pubspec.yaml
```

---

## Tính năng

### 1. Authentication (`/features/auth`)
- **Login/Logout**: Email/password authentication
- **Session Management**: Persistent login with secure storage
- **BLoC Pattern**: `AuthBloc` for authentication state management

### 2. Home (`/features/home`)
- **Dashboard**: User welcome screen with demo links
- **Repository Pattern**: Full clean architecture implementation
- **BLoC Pattern**: `HomeBloc` with events and states

### 3. Isolate Demo (`/features/isolate_demo`)
- **Main Thread vs Isolate**: Performance comparison
- **Error Handling**: Detailed error handling with `Either` type
- **Visual Testing**: Radar animation to detect UI freeze

### 4. Profiling (`/features/profiling`)
- **CPU Benchmark**: Fibonacci computation testing
- **Memory Leak Demo**: Memory management demonstration
- **Performance Monitoring**: Real-time FPS monitoring

### 5. Native Integration
- **Method Channel**: Android/iOS native communication
- **Battery Info**: Get device battery level
- **Device Info**: Get device information
- **Haptic Feedback**: Device vibration

### 6. Permissions (`/features/home/presentation/pages/permission_page.dart`)
- **Permission Handler**: Request and manage app permissions
- **42+ Permission Types**: Camera, location, storage, etc.

---

## Dependencies

### State Management & DI
```yaml
flutter_bloc: ^9.1.0          # BLoC state management
hydrated_bloc: ^11.0.0         # Persistent BLoC
equatable: ^2.0.7               # Value equality
get_it: ^9.0.5                 # Dependency injection
```

### Networking
```yaml
dio: ^5.8.0+1                 # HTTP client
internet_connection_checker: ^3.0.1  # Network status
```

### Storage
```yaml
hive_flutter: ^1.1.0          # Local database
flutter_secure_storage: ^10.0.0  # Secure storage
```

### Firebase
```yaml
firebase_core: ^4.2.0
firebase_auth: ^6.0.2
cloud_firestore: ^6.0.3
firebase_analytics: ^12.0.2
firebase_messaging: ^16.0.1
```

### Utilities
```yaml
fpdart: ^1.2.0                # Functional programming (Either)
go_router: ^17.0.0             # Navigation
logger: ^2.6.2                 # Logging
easy_localization: ^3.0.7+1    # i18n
```

### Testing
```yaml
mocktail: ^1.0.5               # Mocking
bloc_test: ^10.0.0              # BLoC testing
integration_test:              # E2E testing (SDK)
```

---

## Setup & Run

### 1. Clone & Install Dependencies
```bash
flutter pub get
```

### 2. Firebase Setup (Optional)
```bash
# Place google-services.json (Android) and GoogleService-Info.plist (iOS)
# in the respective platform folders
```

### 3. Run the App
```bash
# Development
flutter run

# Profile mode
flutter run --profile

# Release mode
flutter run --release
```

### 4. Run Tests
```bash
# Unit tests
flutter test

# Widget tests
flutter test integration_test/app_test.dart

# Integration tests
flutter test integration_test/
```

---

## Testing

### Test Structure

```
test/
├── mocks/                         # Mock classes
│   └── repository_mocks.dart
├── features/
│   ├── auth/
│   │   └── presentation/bloc/
│   │       └── auth_login_form_bloc_test.dart
│   ├── home/
│   │   ├── data/repositories/
│   │   │   └── home_repository_impl_test.dart
│   │   └── presentation/bloc/
│   │       └── home_bloc_test.dart
│   ├── isolate_demo/
│   │   ├── data/repositories/
│   │   │   └── isolate_repository_impl_test.dart
│   │   └── presentation/bloc/
│   │       └── isolate_bloc_test.dart
│   └── profiling/
│       └── presentation/bloc/
│           └── profiling_bloc_test.dart
└── widgets/
    └── button_widget_test.dart
```

### Writing Tests

#### Unit Test Example (Repository)
```dart
group('IsolateRepositoryImpl', () {
  test('returns Right on success', () async {
    when(() => mockDataSource.fetchHeavyPayload(useIsolate: false))
        .thenAnswer((_) async => testPayload);

    final result = await repository.getHeavyPayload(useIsolate: false);

    expect(result.isRight(), true);
    result.fold(
      (l) => fail('Should not return Left'),
      (r) => expect(r.totalRecords, 100),
    );
  });

  test('returns Left on server error', () async {
    when(() => mockDataSource.fetchHeavyPayload(useIsolate: false))
        .thenThrow(FetchDataException('Network error'));

    final result = await repository.getHeavyPayload(useIsolate: false);

    expect(result.isLeft(), true);
    result.fold(
      (l) => expect(l, isA<IsolateServerFailure>()),
      (r) => fail('Should not return Right'),
    );
  });
});
```

#### BLoC Test Example
```dart
blocTest<IsolateBloc, IsolateState>(
  'emits [Loading, Loaded] when fetch succeeds',
  build: () {
    when(() => mockRepository.getHeavyPayload(useIsolate: false))
        .thenAnswer((_) async => const Right(testPayload));
    return isolateBloc;
  },
  act: (bloc) => bloc.add(const FetchPayloadEvent(useIsolate: false)),
  expect: () => [
    isA<IsolateLoading>(),
    isA<IsolateLoaded>()
        .having((s) => s.data, 'data', testPayload)
        .having((s) => s.usedIsolate, 'usedIsolate', false),
  ],
);
```

#### Integration Test Example
```dart
testWidgets('Login flow succeeds', (tester) async {
  app.main();
  await tester.pumpAndSettle();

  // Enter credentials
  await tester.enterText(find.byType(TextFormField).at(0), 'test@gmail.com');
  await tester.enterText(find.byType(TextFormField).at(1), 'password123');

  // Tap login
  await tester.tap(find.text('Đăng nhập'));
  await tester.pumpAndSettle();

  // Verify home page
  expect(find.text('Home'), findsOneWidget);
});
```

---

## Performance Monitoring

### PerformanceMonitor

```dart
final monitor = PerformanceMonitor();

// Start monitoring
monitor.startMonitoring();

// Record FPS
monitor.recordFrame(fps);

// Record custom metrics
monitor.recordMetric(PerformanceMetricType.memory, bytes);
monitor.recordMetric(PerformanceMetricType.cpu, percentage);

// Listen to updates
monitor.snapshotStream.listen((snapshot) {
  print('FPS: ${snapshot.currentFps}');
});

// Stop monitoring
monitor.stopMonitoring();
```

### PerformanceOverlay

```dart
PerformanceOverlay(
  enabled: true,
  child: MyApp(),
)
```

### DevToolsPanel

```dart
DevToolsPanel(
  monitor: performanceMonitor,
  onClose: () => setState(() => _showPanel = false),
)
```

### MonitoringDemoPage

Navigate to `Profiling Lab` → `Monitoring Demo` for a complete demo with:
- Real-time FPS monitoring
- Simulation controls (Normal, High Load, Janky)
- Live DevTools panel
- FPS history chart

---

## Error Handling

### Failure Types

Each feature defines its own sealed `Failure` class:

```dart
// Auth failures
class CredentialFailure extends Failure {}
class DuplicateEmailFailure extends Failure {}

// Isolate failures
class IsolateServerFailure extends Failure {
  final String? message;
  IsolateServerFailure([this.message]);
}
class IsolateTimeoutFailure extends Failure {}
class IsolateParseFailure extends Failure {}

// Home failures
class HomeCacheFailure extends Failure {}
class HomeNetworkFailure extends Failure {}

// Profiling failures
class ProfilingComputeFailure extends Failure {}
class ProfilingMemoryFailure extends Failure {}
```

### Using Either in BLoC

```dart
result.fold(
  (failure) => emit(ErrorState(mapFailureToMessage(failure))),
  (data) => emit(LoadedState(data)),
);
```

### Mapping Failures to Messages

```dart
String mapFailureToMessage(Failure failure) {
  switch (failure) {
    case CredentialFailure _:
      return "Wrong email or password";
    case IsolateServerFailure _:
      return "Server error: ${failure.message}";
    case IsolateTimeoutFailure _:
      return "Request timed out";
    default:
      return "Unexpected error";
  }
}
```

---

## Dependency Injection

### Global Setup (`lib/core/configs/injector/injector_conf.dart`)

```dart
final getIt = GetIt.I;

void configureDepedencies() {
  // Initialize feature dependencies
  AuthDepedency.init();
  HomeDependency.init();
  ProfilingDependency.init();
  IsolateDependency.init();

  // Global singletons
  getIt.registerLazySingleton(() => ThemeBloc());
  getIt.registerLazySingleton(() => ApiHelper(getIt<Dio>()));
  getIt.registerLazySingleton(() => HiveLocalStorage());
  getIt.registerLazySingleton(() => SecureLocalStorage(...));
}
```

### Feature Dependency (`lib/features/{feature}/di/`)

```dart
class HomeDependency {
  HomeDependency._();

  static void init() {
    // Data Sources
    getIt.registerLazySingleton<HomeLocalDataSource>(
      () => HomeLocalDataSourceImpl(),
    );

    // Repository
    getIt.registerLazySingleton<HomeRepository>(
      () => HomeRepositoryImpl(localDataSource: getIt<HomeLocalDataSource>()),
    );

    // Use Cases
    getIt.registerLazySingleton(
      () => GetHomeDataUseCase(getIt<HomeRepository>()),
    );

    // BLoC (Factory - new instance each time)
    getIt.registerFactory(
      () => HomeBloc(getHomeDataUseCase: getIt<GetHomeDataUseCase>()),
    );
  }
}
```

---

## Thêm tính năng mới

### 1. Tạo cấu trúc feature

```
lib/features/my_feature/
├── data/
│   ├── datasources/
│   │   ├── my_feature_local_datasource.dart
│   │   └── my_feature_remote_datasource.dart
│   ├── exceptions/
│   │   └── my_feature_exceptions.dart
│   ├── models/
│   │   └── my_feature_model.dart
│   └── repositories/
│       └── my_feature_repository_impl.dart
├── di/
│   └── my_feature_dependency.dart
├── domain/
│   ├── entities/
│   │   └── my_feature_entity.dart
│   ├── failures/
│   │   └── my_feature_failures.dart
│   ├── repositories/
│   │   └── my_feature_repository.dart
│   └── usecases/
│       ├── get_my_feature_usecase.dart
│       └── save_my_feature_usecase.dart
└── presentation/
    ├── bloc/
    │   ├── my_feature_bloc.dart
    │   ├── my_feature_event.dart
    │   └── my_feature_state.dart
    ├── pages/
    │   └── my_feature_page.dart
    └── widgets/
        └── my_feature_widget.dart
```

### 2. Domain Layer

```dart
// entities/my_feature_entity.dart
class MyFeatureEntity extends Equatable {
  final String id;
  final String name;
  // ...
}

// failures/my_feature_failures.dart
sealed class MyFeatureFailure extends Equatable {
  @override
  List<Object?> get props => [];
}

class MyFeatureCacheFailure extends MyFeatureFailure {
  final String? message;
  MyFeatureCacheFailure([this.message]);
}

// repositories/my_feature_repository.dart
abstract class MyFeatureRepository {
  Future<Either<MyFeatureFailure, MyFeatureEntity>> getMyFeature();
}

// usecases/get_my_feature_usecase.dart
class GetMyFeatureUseCase {
  final MyFeatureRepository repository;

  Future<Either<MyFeatureFailure, MyFeatureEntity>> call() async {
    return repository.getMyFeature();
  }
}
```

### 3. Data Layer

```dart
// models/my_feature_model.dart
class MyFeatureModel extends MyFeatureEntity {
  const MyFeatureModel({required super.id, required super.name});

  factory MyFeatureModel.fromJson(Map<String, dynamic> json) {
    return MyFeatureModel(
      id: json['id'],
      name: json['name'],
    );
  }
}

// repositories/my_feature_repository_impl.dart
class MyFeatureRepositoryImpl implements MyFeatureRepository {
  final MyFeatureLocalDataSource localDataSource;

  Future<Either<MyFeatureFailure, MyFeatureEntity>> getMyFeature() async {
    try {
      final result = await localDataSource.getMyFeature();
      return Right(result);
    } on CacheException catch (e) {
      return Left(MyFeatureCacheFailure(e.message));
    } catch (e) {
      return Left(MyFeatureCacheFailure(e.toString()));
    }
  }
}
```

### 4. Presentation Layer

```dart
// bloc/my_feature_bloc.dart
class MyFeatureBloc extends Bloc<MyFeatureEvent, MyFeatureState> {
  final GetMyFeatureUseCase getMyFeatureUseCase;

  MyFeatureBloc({required this.getMyFeatureUseCase}) : super(MyFeatureInitial()) {
    on<LoadMyFeatureEvent>(_onLoad);
  }

  Future<void> _onLoad(LoadMyFeatureEvent event, Emitter emit) async {
    emit(MyFeatureLoading());

    final result = await getMyFeatureUseCase();

    result.fold(
      (failure) => emit(MyFeatureError(failure.toString())),
      (data) => emit(MyFeatureLoaded(data)),
    );
  }
}
```

### 5. Dependency Injection

```dart
// di/my_feature_dependency.dart
class MyFeatureDependency {
  static void init() {
    getIt.registerLazySingleton<MyFeatureLocalDataSource>(
      () => MyFeatureLocalDataSourceImpl(),
    );

    getIt.registerLazySingleton<MyFeatureRepository>(
      () => MyFeatureRepositoryImpl(getIt<MyFeatureLocalDataSource>()),
    );

    getIt.registerLazySingleton(
      () => GetMyFeatureUseCase(getIt<MyFeatureRepository>()),
    );

    getIt.registerFactory(
      () => MyFeatureBloc(getMyFeatureUseCase: getIt<GetMyFeatureUseCase>()),
    );
  }
}
```

### 6. Thêm tests

```dart
// test/features/my_feature/presentation/bloc/my_feature_bloc_test.dart
class MockMyFeatureRepository extends Mock implements MyFeatureRepository {}

blocTest<MyFeatureBloc, MyFeatureState>(
  'emits [Loading, Loaded] when getMyFeature succeeds',
  build: () {
    when(() => mockRepository.getMyFeature())
        .thenAnswer((_) async => Right(testEntity));
    return myFeatureBloc;
  },
  act: (bloc) => bloc.add(LoadMyFeatureEvent()),
  expect: () => [
    isA<MyFeatureLoading>(),
    isA<MyFeatureLoaded>(),
  ],
);
```

### 7. Thêm route

```dart
// lib/core/routes/app_route_path.dart
enum AppRoute {
  // ... existing routes
  myFeature(path: "my-feature");
}

// lib/core/routes/app_route_conf.dart
GoRoute(
  path: AppRoute.myFeature.path,
  name: AppRoute.myFeature.name,
  builder: (_, _) => BlocProvider(
    create: (_) => getIt<MyFeatureBloc>()..add(LoadMyFeatureEvent()),
    child: const MyFeaturePage(),
  ),
),
```

---

## Navigation

Uses `go_router` for declarative routing:

```dart
// Navigate by name
context.pushNamed(AppRoute.myFeature.name);

// Navigate with extra data
context.pushNamed(
  AppRoute.profile.name,
  extra: userEntity,
);

// Go back
context.pop();

// Replace current route
context.pushReplacementNamed(AppRoute.home.name);
```

---

## License

MIT License - See LICENSE file for details.
