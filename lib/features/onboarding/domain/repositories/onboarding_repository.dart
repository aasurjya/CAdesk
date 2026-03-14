import 'package:ca_app/features/onboarding/domain/models/document_expiry.dart';
import 'package:ca_app/features/onboarding/domain/models/kyc_record.dart';
import 'package:ca_app/features/onboarding/domain/models/onboarding_checklist.dart';

/// Abstract contract for onboarding data operations.
///
/// Covers KYC records, onboarding checklists, and document expiry tracking.
abstract class OnboardingRepository {
  // ---------------------------------------------------------------------------
  // KYC Records
  // ---------------------------------------------------------------------------

  /// Returns all KYC records.
  Future<List<KycRecord>> getKycRecords();

  /// Returns the KYC record for [id], or null if not found.
  Future<KycRecord?> getKycRecordById(String id);

  /// Returns all KYC records matching [status].
  Future<List<KycRecord>> getKycRecordsByStatus(KycStatus status);

  /// Inserts a new [KycRecord] and returns its ID.
  Future<String> insertKycRecord(KycRecord record);

  /// Updates an existing [KycRecord]. Returns true on success.
  Future<bool> updateKycRecord(KycRecord record);

  /// Deletes the KYC record identified by [id]. Returns true on success.
  Future<bool> deleteKycRecord(String id);

  // ---------------------------------------------------------------------------
  // Onboarding Checklists
  // ---------------------------------------------------------------------------

  /// Returns all onboarding checklists.
  Future<List<OnboardingChecklist>> getChecklists();

  /// Returns all checklists for [clientId].
  Future<List<OnboardingChecklist>> getChecklistsByClient(String clientId);

  /// Inserts a new [OnboardingChecklist] and returns its ID.
  Future<String> insertChecklist(OnboardingChecklist checklist);

  /// Updates an existing [OnboardingChecklist]. Returns true on success.
  Future<bool> updateChecklist(OnboardingChecklist checklist);

  /// Deletes the checklist identified by [id]. Returns true on success.
  Future<bool> deleteChecklist(String id);

  // ---------------------------------------------------------------------------
  // Document Expiry
  // ---------------------------------------------------------------------------

  /// Returns all document expiry records.
  Future<List<DocumentExpiry>> getDocumentExpiries();

  /// Returns all document expiry records for [clientId].
  Future<List<DocumentExpiry>> getDocumentExpiriesByClient(String clientId);

  /// Returns all document expiry records matching [status].
  Future<List<DocumentExpiry>> getDocumentExpiriesByStatus(ExpiryStatus status);

  /// Inserts a new [DocumentExpiry] record and returns its ID.
  Future<String> insertDocumentExpiry(DocumentExpiry expiry);

  /// Updates an existing [DocumentExpiry]. Returns true on success.
  Future<bool> updateDocumentExpiry(DocumentExpiry expiry);

  /// Deletes the document expiry record identified by [id].
  /// Returns true on success.
  Future<bool> deleteDocumentExpiry(String id);
}
