import 'package:ca_app/features/dsc_vault/data/datasources/dsc_vault_local_source.dart';
import 'package:ca_app/features/dsc_vault/data/datasources/dsc_vault_remote_source.dart';
import 'package:ca_app/features/dsc_vault/data/mappers/dsc_vault_mapper.dart';
import 'package:ca_app/features/dsc_vault/domain/models/dsc_certificate.dart';
import 'package:ca_app/features/dsc_vault/domain/models/portal_credential.dart';
import 'package:ca_app/features/dsc_vault/domain/repositories/dsc_vault_repository.dart';

/// Real implementation of [DscVaultRepository].
///
/// Attempts remote (Supabase) operations first; falls back to local cache
/// (Drift/SQLite) on any network error.
class DscVaultRepositoryImpl implements DscVaultRepository {
  const DscVaultRepositoryImpl({required this.remote, required this.local});

  final DscVaultRemoteSource remote;
  final DscVaultLocalSource local;

  @override
  Future<String> insertCertificate(DscCertificate certificate) async {
    try {
      final json = await remote.insertCertificate(
        DscVaultMapper.certToJson(certificate),
      );
      final created = DscVaultMapper.certFromJson(json);
      await local.insertCertificate(created);
      return created.id;
    } catch (_) {
      return local.insertCertificate(certificate);
    }
  }

  @override
  Future<List<DscCertificate>> getAllCertificates() async {
    try {
      final jsonList = await remote.fetchAllCertificates();
      final certs = jsonList.map(DscVaultMapper.certFromJson).toList();
      for (final c in certs) {
        await local.insertCertificate(c);
      }
      return List.unmodifiable(certs);
    } catch (_) {
      return local.getAllCertificates();
    }
  }

  @override
  Future<List<DscCertificate>> getCertificatesByClient(String clientId) async {
    try {
      final all = await getAllCertificates();
      return List.unmodifiable(
        all.where((c) => c.clientId == clientId).toList(),
      );
    } catch (_) {
      final all = await local.getAllCertificates();
      return List.unmodifiable(
        all.where((c) => c.clientId == clientId).toList(),
      );
    }
  }

  @override
  Future<List<DscCertificate>> getCertificatesByStatus(DscStatus status) async {
    try {
      final all = await getAllCertificates();
      return List.unmodifiable(all.where((c) => c.status == status).toList());
    } catch (_) {
      final all = await local.getAllCertificates();
      return List.unmodifiable(all.where((c) => c.status == status).toList());
    }
  }

  @override
  Future<bool> updateCertificate(DscCertificate certificate) async {
    try {
      await remote.updateCertificate(
        certificate.id,
        DscVaultMapper.certToJson(certificate),
      );
      await local.updateCertificate(certificate);
      return true;
    } catch (_) {
      return local.updateCertificate(certificate);
    }
  }

  @override
  Future<bool> deleteCertificate(String id) async {
    try {
      await remote.deleteCertificate(id);
      await local.deleteCertificate(id);
      return true;
    } catch (_) {
      return local.deleteCertificate(id);
    }
  }

  @override
  Future<String> insertCredential(PortalCredential credential) async {
    try {
      final json = await remote.insertCredential(
        DscVaultMapper.credToJson(credential),
      );
      final created = DscVaultMapper.credFromJson(json);
      await local.insertCredential(created);
      return created.id;
    } catch (_) {
      return local.insertCredential(credential);
    }
  }

  @override
  Future<List<PortalCredential>> getAllCredentials() async {
    try {
      final jsonList = await remote.fetchAllCredentials();
      final creds = jsonList.map(DscVaultMapper.credFromJson).toList();
      for (final c in creds) {
        await local.insertCredential(c);
      }
      return List.unmodifiable(creds);
    } catch (_) {
      return local.getAllCredentials();
    }
  }

  @override
  Future<List<PortalCredential>> getCredentialsByClient(String clientId) async {
    try {
      final all = await getAllCredentials();
      return List.unmodifiable(
        all.where((c) => c.clientId == clientId).toList(),
      );
    } catch (_) {
      final all = await local.getAllCredentials();
      return List.unmodifiable(
        all.where((c) => c.clientId == clientId).toList(),
      );
    }
  }

  @override
  Future<bool> updateCredential(PortalCredential credential) async {
    try {
      await remote.updateCredential(
        credential.id,
        DscVaultMapper.credToJson(credential),
      );
      await local.updateCredential(credential);
      return true;
    } catch (_) {
      return local.updateCredential(credential);
    }
  }

  @override
  Future<bool> deleteCredential(String id) async {
    try {
      await remote.deleteCredential(id);
      await local.deleteCredential(id);
      return true;
    } catch (_) {
      return local.deleteCredential(id);
    }
  }
}
