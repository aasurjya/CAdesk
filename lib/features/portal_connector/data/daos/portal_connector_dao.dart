// Re-export the core DAO so feature-layer code can reference it from
// lib/features/portal_connector/data/daos/ without depending on the core
// database package path directly.
export 'package:ca_app/core/database/daos/portal_connector_dao.dart';
