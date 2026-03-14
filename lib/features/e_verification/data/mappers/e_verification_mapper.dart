import 'package:ca_app/features/e_verification/domain/models/verification_request.dart';
import 'package:ca_app/features/e_verification/domain/models/verification_status.dart';
import 'package:ca_app/features/e_verification/domain/models/signing_request.dart';

/// Converts between domain models and JSON maps for e-verification.
class EVerificationMapper {
  const EVerificationMapper._();

  static VerificationRequest vreqFromJson(Map<String, dynamic> json) {
    return VerificationRequest(
      id: json['id'] as String,
      clientName: json['client_name'] as String,
      pan: json['pan'] as String,
      itrType: json['itr_type'] as String,
      assessmentYear: json['assessment_year'] as String,
      filingDate: DateTime.parse(json['filing_date'] as String),
      deadlineDate: DateTime.parse(json['deadline_date'] as String),
      status: VerificationStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'pending'),
        orElse: () => VerificationStatus.pending,
      ),
      acknowledgementNumber: json['acknowledgement_number'] as String?,
    );
  }

  static Map<String, dynamic> vreqToJson(VerificationRequest req) {
    return {
      'id': req.id,
      'client_name': req.clientName,
      'pan': req.pan,
      'itr_type': req.itrType,
      'assessment_year': req.assessmentYear,
      'filing_date': req.filingDate.toIso8601String(),
      'deadline_date': req.deadlineDate.toIso8601String(),
      'status': req.status.name,
      'acknowledgement_number': req.acknowledgementNumber,
    };
  }

  static SigningRequest sreqFromJson(Map<String, dynamic> json) {
    return SigningRequest(
      requestId: json['request_id'] as String,
      documentHash: json['document_hash'] as String,
      documentType: DocumentType.values.firstWhere(
        (e) => e.name == (json['document_type'] as String? ?? 'itrV'),
        orElse: () => DocumentType.itrV,
      ),
      signerPan: json['signer_pan'] as String,
      signerName: json['signer_name'] as String,
      status: SigningStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'pending'),
        orElse: () => SigningStatus.pending,
      ),
      signedAt: json['signed_at'] != null
          ? DateTime.parse(json['signed_at'] as String)
          : null,
      signature: json['signature'] as String?,
    );
  }

  static Map<String, dynamic> sreqToJson(SigningRequest req) {
    return {
      'request_id': req.requestId,
      'document_hash': req.documentHash,
      'document_type': req.documentType.name,
      'signer_pan': req.signerPan,
      'signer_name': req.signerName,
      'status': req.status.name,
      'signed_at': req.signedAt?.toIso8601String(),
      'signature': req.signature,
    };
  }
}
