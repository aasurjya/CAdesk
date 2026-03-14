import 'package:ca_app/features/more/domain/models/menu_item_config.dart';
import 'package:ca_app/features/more/domain/repositories/more_repository.dart';

/// Real implementation of [MoreRepository].
///
/// Full Drift/Supabase wiring is deferred until a later phase.
class MoreRepositoryImpl implements MoreRepository {
  const MoreRepositoryImpl();

  @override
  Future<List<MenuItemConfig>> getMenuItems() async => const [];

  @override
  Future<bool> updateMenuItem(MenuItemConfig item) async => true;

  @override
  Future<void> saveOrder(List<MenuItemConfig> items) async {}
}
