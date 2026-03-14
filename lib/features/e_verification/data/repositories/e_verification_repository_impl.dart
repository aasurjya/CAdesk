import 'package:ca_app/features/e_verification/data/datasources/e_verification_local_source.dart';
import 'package:ca_app/features/e_verification/data/datasources/e_verification_remote_source.dart';
import 'package:ca_app/features/e_verification/data/mappers/e_verification_mapper.dart';
import 'package:ca_app/features/e_verification/domain/models/signing_request.dart';
import 'package:ca_app/features/e_verification/domain/models/verification_request.dart';
import 'package:ca_app/features/e_verification/domain/models/verification_status.dart';
import 'package:ca_app/features/e_verification/domain/repositories/e_verification_repository.dart';

/// Real implementation of [EVerificationRepository].
///
/// Attempts remote (Supabase) operations first; falls back to local cache
/// (Drift/SQLite) on any network error.
class EVerificationRepositoryImpl implements EVerificationRepository {
  const EVerificationRepositoryImpl({
    required this.remote,
    required this.local,
  });

  final EVerificationRemoteSource remote;
  final EVerificationLocalSource local;

  @override
  Future<String> insertVerificationRequest(VerificationRequest request) async {
    try {
      final json = await remote.insertVerificationRequest(
        EVerificationMapper.vreqToJson(request),
      );
      final created = EVerificationMapper.vreqFromJson(json);
      await local.insertVerificationRequest(created);
      return created.id;
    } catch (_) {
      return local.insertVerificationRequest(request);
    }
  }

  @override
  Future<List<VerificationRequest>> getAllVerificationRequests() async {
    try {
      final jsonList = await remote.fetchAllVerificationRequests();
      final requests = jsonList.map(EVerificationMapper.vreqFromJson).toList();
      for (final r in requests) {
        await local.insertVerificationRequest(r);
      }
      return List.unmodifiable(requests);
    } catch (_) {
      return local.getAllVerificationRequests();
    }
  }

  @override
  Future<List<VerificationRequest>> getVerificationRequestsByStatus(
    VerificationStatus status,
  ) async {
    try {
      final all = await getAllVerificationRequests();
      return List.unmodifiable(all.where((r) => r.status == status).toList());
    } catch (_) {
      final all = await local.getAllVerificationRequests();
      return List.unmodifiable(all.where((r) => r.status == status).toList());
    }
  }

  @override
  Future<bool> updateVerificationRequest(VerificationRequest request) async {
    try {
      await remote.updateVerificationRequest(
        request.id,
        EVerificationMapper.vreqToJson(request),
      );
      await local.updateVerificationRequest(request);
      return true;
    } catch (_) {
      return local.updateVerificationRequest(request);
    }
  }

  @override
  Future<bool> deleteVerificationRequest(String id) async {
    try {
      await remote.deleteVerificationRequest(id);
      await local.deleteVerificationRequest(id);
      return true;
    } catch (_) {
      return local.deleteVerificationRequest(id);
    }
  }

  @override
  Future<String> insertSigningRequest(SigningRequest request) async {
    try {
      final json = await remote.insertSigningRequest(
        EVerificationMapper.sreqToJson(request),
      );
      final created = EVerificationMapper.sreqFromJson(json);
      await local.insertSigningRequest(created);
      return created.requestId;
    } catch (_) {
      return local.insertSigningRequest(request);
    }
  }

  @override
  Future<List<SigningRequest>> getAllSigningRequests() async {
    try {
      final jsonList = await remote.fetchAllSigningRequests();
      final requests = jsonList.map(EVerificationMapper.sreqFromJson).toList();
      for (final r in requests) {
        await local.insertSigningRequest(r);
      }
      return List.unmodifiable(requests);
    } catch (_) {
      return local.getAllSigningRequests();
    }
  }

  @override
  Future<List<SigningRequest>> getSigningRequestsByStatus(
    SigningStatus status,
  ) async {
    try {
      final all = await getAllSigningRequests();
      return List.unmodifiable(all.where((r) => r.status == status).toList());
    } catch (_) {
      final all = await local.getAllSigningRequests();
      return List.unmodifiable(all.where((r) => r.status == status).toList());
    }
  }

  @override
  Future<bool> updateSigningRequest(SigningRequest request) async {
    try {
      await remote.updateSigningRequest(
        request.requestId,
        EVerificationMapper.sreqToJson(request),
      );
      await local.updateSigningRequest(request);
      return true;
    } catch (_) {
      return local.updateSigningRequest(request);
    }
  }

  @override
  Future<bool> deleteSigningRequest(String requestId) async {
    try {
      await remote.deleteSigningRequest(requestId);
      await local.deleteSigningRequest(requestId);
      return true;
    } catch (_) {
      return local.deleteSigningRequest(requestId);
    }
  }
}
