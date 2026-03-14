import 'package:ca_app/features/more/domain/models/menu_item_config.dart';
import 'package:ca_app/features/more/domain/repositories/more_repository.dart';

/// In-memory mock implementation of [MoreRepository].
class MockMoreRepository implements MoreRepository {
  static final List<MenuItemConfig> _seed = [
    const MenuItemConfig(
      id: 'menu-dashboard',
      title: 'Dashboard',
      subtitle: 'Overview & KPIs',
      route: '/dashboard',
      isPinned: true,
      sortOrder: 0,
    ),
    const MenuItemConfig(
      id: 'menu-tasks',
      title: 'Tasks',
      subtitle: 'Task management',
      route: '/tasks',
      sortOrder: 1,
    ),
    const MenuItemConfig(
      id: 'menu-clients',
      title: 'Clients',
      subtitle: 'Client directory',
      route: '/clients',
      sortOrder: 2,
    ),
    const MenuItemConfig(
      id: 'menu-settings',
      title: 'Settings',
      subtitle: 'App preferences',
      route: '/settings',
      sortOrder: 3,
    ),
  ];

  final List<MenuItemConfig> _state = List.of(_seed);

  @override
  Future<List<MenuItemConfig>> getMenuItems() async {
    return List.unmodifiable(
      _state.where((i) => i.isVisible).toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)),
    );
  }

  @override
  Future<bool> updateMenuItem(MenuItemConfig item) async {
    final idx = _state.indexWhere((i) => i.id == item.id);
    if (idx == -1) return false;
    final updated = List<MenuItemConfig>.of(_state)..[idx] = item;
    _state
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<void> saveOrder(List<MenuItemConfig> items) async {
    for (var i = 0; i < items.length; i++) {
      final idx = _state.indexWhere((s) => s.id == items[i].id);
      if (idx != -1) {
        _state[idx] = _state[idx].copyWith(sortOrder: i);
      }
    }
  }
}
