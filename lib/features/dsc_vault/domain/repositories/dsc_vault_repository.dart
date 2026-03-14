import 'package:ca_app/features/dsc_vault/domain/models/dsc_certificate.dart';
import 'package:ca_app/features/dsc_vault/domain/models/portal_credential.dart';

/// Abstract contract for DSC vault data operations.
///
/// Concrete implementations can use Supabase (real) or in-memory data (mock).
abstract class DscVaultRepository {
  /// Insert a new [DscCertificate] and return its generated ID.
  Future<String> insertCertificate(DscCertificate certificate);

  /// Retrieve all DSC certificates.
  Future<List<DscCertificate>> getAllCertificates();

  /// Retrieve certificates for a specific [clientId].
  Future<List<DscCertificate>> getCertificatesByClient(String clientId);

  /// Retrieve certificates filtered by [status].
  Future<List<DscCertificate>> getCertificatesByStatus(DscStatus status);

  /// Update an existing [DscCertificate]. Returns true on success.
  Future<bool> updateCertificate(DscCertificate certificate);

  /// Delete the certificate identified by [id]. Returns true on success.
  Future<bool> deleteCertificate(String id);

  /// Insert a new [PortalCredential] and return its generated ID.
  Future<String> insertCredential(PortalCredential credential);

  /// Retrieve all portal credentials.
  Future<List<PortalCredential>> getAllCredentials();

  /// Retrieve credentials for a specific [clientId].
  Future<List<PortalCredential>> getCredentialsByClient(String clientId);

  /// Update an existing [PortalCredential]. Returns true on success.
  Future<bool> updateCredential(PortalCredential credential);

  /// Delete the credential identified by [id]. Returns true on success.
  Future<bool> deleteCredential(String id);
}
