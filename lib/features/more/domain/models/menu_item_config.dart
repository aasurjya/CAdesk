/// Immutable model representing a configurable menu item in the More screen.
class MenuItemConfig {
  const MenuItemConfig({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.route,
    this.isPinned = false,
    this.isVisible = true,
    this.sortOrder = 0,
  });

  final String id;
  final String title;
  final String subtitle;
  final String route;
  final bool isPinned;
  final bool isVisible;
  final int sortOrder;

  MenuItemConfig copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? route,
    bool? isPinned,
    bool? isVisible,
    int? sortOrder,
  }) {
    return MenuItemConfig(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      route: route ?? this.route,
      isPinned: isPinned ?? this.isPinned,
      isVisible: isVisible ?? this.isVisible,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MenuItemConfig &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
