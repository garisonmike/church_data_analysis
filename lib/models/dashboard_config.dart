enum DashboardSection { kpiCards, quickActions, recentWeeks }

class DashboardConfig {
  final Map<DashboardSection, bool> visibility;
  final List<DashboardSection> order;

  const DashboardConfig({required this.visibility, required this.order});

  factory DashboardConfig.defaults() {
    return DashboardConfig(
      visibility: {
        for (final section in DashboardSection.values) section: true,
      },
      order: DashboardSection.values.toList(),
    );
  }

  bool isVisible(DashboardSection section) {
    return visibility[section] ?? true;
  }

  DashboardConfig copyWith({
    Map<DashboardSection, bool>? visibility,
    List<DashboardSection>? order,
  }) {
    return DashboardConfig(
      visibility: visibility ?? this.visibility,
      order: order ?? this.order,
    );
  }

  factory DashboardConfig.fromJson(Map<String, dynamic> json) {
    final defaultConfig = DashboardConfig.defaults();

    final visibilityJson = json['visibility'] as Map<String, dynamic>?;
    final visibility = <DashboardSection, bool>{
      for (final section in DashboardSection.values)
        section:
            (visibilityJson?[section.name] as bool?) ??
            defaultConfig.visibility[section] ??
            true,
    };

    final orderJson = json['order'] as List<dynamic>?;
    final order = <DashboardSection>[];
    if (orderJson != null) {
      for (final value in orderJson) {
        if (value is String) {
          final match = DashboardSection.values
              .where((section) => section.name == value)
              .toList();
          if (match.isNotEmpty) {
            order.add(match.first);
          }
        }
      }
    }

    if (order.isEmpty) {
      order.addAll(defaultConfig.order);
    }

    return DashboardConfig(visibility: visibility, order: order);
  }

  Map<String, dynamic> toJson() {
    return {
      'visibility': {
        for (final entry in visibility.entries) entry.key.name: entry.value,
      },
      'order': order.map((section) => section.name).toList(),
    };
  }
}
