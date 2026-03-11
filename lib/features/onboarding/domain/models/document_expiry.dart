import 'package:flutter/foundation.dart';

/// Type of document being tracked for expiry.
enum DocumentType {
  gstCertificate(label: 'GST Certificate'),
  insurance(label: 'Insurance'),
  license(label: 'License'),
  panCard(label: 'PAN Card'),
  aadhaar(label: 'Aadhaar'),
  dsc(label: 'DSC'),
  professionalTax(label: 'Professional Tax');

  const DocumentType({required this.label});

  final String label;
}

/// Current validity status of a document.
enum ExpiryStatus {
  valid(label: 'Valid'),
  expiringSoon(label: 'Expiring Soon'),
  expired(label: 'Expired');

  const ExpiryStatus({required this.label});

  final String label;
}

/// Immutable model representing a document expiry tracker.
@immutable
class DocumentExpiry {
  const DocumentExpiry({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.documentType,
    required this.expiryDate,
    this.reminderSentAt,
    required this.status,
  });

  final String id;
  final String clientId;
  final String clientName;
  final DocumentType documentType;
  final DateTime expiryDate;
  final DateTime? reminderSentAt;
  final ExpiryStatus status;

  /// Days remaining until expiry (negative if already expired).
  int get daysRemaining => expiryDate.difference(DateTime.now()).inDays;

  /// Returns a new [DocumentExpiry] with the given fields replaced.
  DocumentExpiry copyWith({
    String? id,
    String? clientId,
    String? clientName,
    DocumentType? documentType,
    DateTime? expiryDate,
    DateTime? reminderSentAt,
    ExpiryStatus? status,
  }) {
    return DocumentExpiry(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      documentType: documentType ?? this.documentType,
      expiryDate: expiryDate ?? this.expiryDate,
      reminderSentAt: reminderSentAt ?? this.reminderSentAt,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentExpiry &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          clientId == other.clientId &&
          documentType == other.documentType &&
          expiryDate == other.expiryDate &&
          status == other.status;

  @override
  int get hashCode => Object.hash(
        id,
        clientId,
        documentType,
        expiryDate,
        status,
      );

  @override
  String toString() =>
      'DocumentExpiry(id: $id, client: $clientName, type: ${documentType.label}, status: ${status.label})';
}
