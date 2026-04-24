import '../../domain/entities/home_entity.dart';
import '../../domain/usecases/home_usecases.dart';

class HomeModel extends HomeEntity {
  const HomeModel({
    required super.welcomeMessage,
    required super.availableDemos,
    required super.totalDemos,
  });

  factory HomeModel.fromJson(Map<String, dynamic> json) {
    return HomeModel(
      welcomeMessage: json['welcomeMessage'] ?? 'Welcome to Flutter Core',
      availableDemos: (json['availableDemos'] as List<dynamic>?)
              ?.map((e) => DemoItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          defaultDemoItems,
      totalDemos: json['totalDemos'] ?? defaultDemoItems.length,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'welcomeMessage': welcomeMessage,
      'availableDemos': availableDemos
          .map((e) => (e as DemoItemModel).toJson())
          .toList(),
      'totalDemos': totalDemos,
    };
  }

  factory HomeModel.defaultHome() {
    return HomeModel(
      welcomeMessage: 'Welcome to Flutter Core',
      availableDemos: defaultDemoItems,
      totalDemos: defaultDemoItems.length,
    );
  }
}

class DemoItemModel extends DemoItem {
  const DemoItemModel({
    required super.id,
    required super.title,
    required super.description,
    required super.routeName,
    required super.category,
    super.isNew,
  });

  factory DemoItemModel.fromJson(Map<String, dynamic> json) {
    return DemoItemModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      routeName: json['routeName'] ?? '',
      category: _parseCategory(json['category']),
      isNew: json['isNew'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'routeName': routeName,
      'category': category.name,
      'isNew': isNew,
    };
  }

  static DemoCategory _parseCategory(String? category) {
    switch (category) {
      case 'profiling':
        return DemoCategory.profiling;
      case 'isolate':
        return DemoCategory.isolate;
      case 'native':
        return DemoCategory.native;
      case 'ui':
        return DemoCategory.ui;
      case 'permissions':
        return DemoCategory.permissions;
      default:
        return DemoCategory.other;
    }
  }
}
