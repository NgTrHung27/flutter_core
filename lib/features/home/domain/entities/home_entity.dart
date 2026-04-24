import 'package:equatable/equatable.dart';

class HomeEntity extends Equatable {
  final String welcomeMessage;
  final List<DemoItem> availableDemos;
  final int totalDemos;

  const HomeEntity({
    required this.welcomeMessage,
    required this.availableDemos,
    required this.totalDemos,
  });

  @override
  List<Object?> get props => [welcomeMessage, availableDemos, totalDemos];
}

class DemoItem extends Equatable {
  final String id;
  final String title;
  final String description;
  final String routeName;
  final DemoCategory category;
  final bool isNew;

  const DemoItem({
    required this.id,
    required this.title,
    required this.description,
    required this.routeName,
    required this.category,
    this.isNew = false,
  });

  @override
  List<Object?> get props => [id, title, description, routeName, category, isNew];
}

enum DemoCategory {
  profiling,
  isolate,
  native,
  ui,
  permissions,
  other,
}

extension DemoCategoryExtension on DemoCategory {
  String get displayName {
    switch (this) {
      case DemoCategory.profiling:
        return 'Profiling';
      case DemoCategory.isolate:
        return 'Isolate';
      case DemoCategory.native:
        return 'Native';
      case DemoCategory.ui:
        return 'UI';
      case DemoCategory.permissions:
        return 'Permissions';
      case DemoCategory.other:
        return 'Other';
    }
  }
}
