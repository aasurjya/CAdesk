import 'package:ca_app/features/e_verification/domain/models/verification_request.dart';
import 'package:ca_app/features/e_verification/domain/models/verification_status.dart';
import 'package:ca_app/features/e_verification/domain/models/signing_request.dart';

/// Abstract contract for e-verification data operations.
///
/// Concrete implementations can use Supabase (real) or in-memory data (mock).
abstract class EVerificationRepository {
  /// Insert a new [VerificationRequest] and return its generated ID.
  Future<String> insertVerificationRequest(VerificationRequest request);

  /// Retrieve all ITR e-verification requests.
  Future<List<VerificationRequest>> getAllVerificationRequests();

  /// Retrieve verification requests filtered by [status].
  Future<List<VerificationRequest>> getVerificationRequestsByStatus(
    VerificationStatus status,
  );

  /// Update an existing [VerificationRequest]. Returns true on success.
  Future<bool> updateVerificationRequest(VerificationRequest request);

  /// Delete the verification request identified by [id]. Returns true on success.
  Future<bool> deleteVerificationRequest(String id);

  /// Insert a new [SigningRequest] and return its generated ID.
  Future<String> insertSigningRequest(SigningRequest request);

  /// Retrieve all document signing requests.
  Future<List<SigningRequest>> getAllSigningRequests();

  /// Retrieve signing requests filtered by [status].
  Future<List<SigningRequest>> getSigningRequestsByStatus(SigningStatus status);

  /// Update an existing [SigningRequest]. Returns true on success.
  Future<bool> updateSigningRequest(SigningRequest request);

  /// Delete the signing request identified by [requestId]. Returns true on success.
  Future<bool> deleteSigningRequest(String requestId);
}
