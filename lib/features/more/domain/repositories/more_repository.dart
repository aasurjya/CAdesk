import 'package:ca_app/features/more/domain/models/menu_item_config.dart';

/// Abstract contract for More screen configuration data operations.
abstract class MoreRepository {
  /// Retrieve all visible menu item configurations.
  Future<List<MenuItemConfig>> getMenuItems();

  /// Update the configuration for a menu item. Returns true on success.
  Future<bool> updateMenuItem(MenuItemConfig item);

  /// Persist the display order for all menu items.
  Future<void> saveOrder(List<MenuItemConfig> items);
}
