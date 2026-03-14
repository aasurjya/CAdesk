import 'package:ca_app/features/regulatory_trust/domain/models/security_control.dart';
import 'package:ca_app/features/regulatory_trust/domain/models/vapt_scan.dart';

/// Abstract contract for regulatory trust data operations.
///
/// Covers security controls and VAPT scans.
abstract class RegulatoryTrustRepository {
  // ---------------------------------------------------------------------------
  // SecurityControl
  // ---------------------------------------------------------------------------

  /// Returns all security controls.
  Future<List<SecurityControl>> getSecurityControls();

  /// Returns the security control for [id], or null if not found.
  Future<SecurityControl?> getSecurityControlById(String id);

  /// Returns all security controls matching [category].
  Future<List<SecurityControl>> getSecurityControlsByCategory(
    SecurityControlCategory category,
  );

  /// Returns all security controls matching [status].
  Future<List<SecurityControl>> getSecurityControlsByStatus(
    SecurityControlStatus status,
  );

  /// Inserts a new [SecurityControl] and returns its ID.
  Future<String> insertSecurityControl(SecurityControl control);

  /// Updates an existing [SecurityControl]. Returns true on success.
  Future<bool> updateSecurityControl(SecurityControl control);

  /// Deletes the security control identified by [id]. Returns true on success.
  Future<bool> deleteSecurityControl(String id);

  // ---------------------------------------------------------------------------
  // VaptScan
  // ---------------------------------------------------------------------------

  /// Returns all VAPT scans.
  Future<List<VaptScan>> getVaptScans();

  /// Returns the VAPT scan for [id], or null if not found.
  Future<VaptScan?> getVaptScanById(String id);

  /// Returns all VAPT scans matching [status].
  Future<List<VaptScan>> getVaptScansByStatus(VaptScanStatus status);

  /// Inserts a new [VaptScan] and returns its ID.
  Future<String> insertVaptScan(VaptScan scan);

  /// Updates an existing [VaptScan]. Returns true on success.
  Future<bool> updateVaptScan(VaptScan scan);

  /// Deletes the VAPT scan identified by [id]. Returns true on success.
  Future<bool> deleteVaptScan(String id);
}
