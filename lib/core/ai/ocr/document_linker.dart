import 'package:ca_app/core/ai/ocr/document_classifier.dart';
import 'package:ca_app/features/clients/domain/models/client.dart';
import 'package:ca_app/features/gst/domain/models/gst_client.dart';

// ---------------------------------------------------------------------------
// DocumentCategory enum
// ---------------------------------------------------------------------------

/// High-level storage category for an uploaded document.
enum DocumentCategory {
  /// TDS certificates and 26AS statements.
  tdsDocuments,

  /// GST invoices and supporting records.
  gstDocuments,

  /// Bank statements and transaction records.
  bankingDocuments,

  /// KYC documents (PAN, Aadhaar, etc.).
  kycDocuments,

  /// Statutory financial statements.
  financialStatements,

  /// Payroll-related documents.
  payrollDocuments,

  /// Catch-all for documents that don't fit above categories.
  generalDocuments,
}

// ---------------------------------------------------------------------------
// DocumentLinker
// ---------------------------------------------------------------------------

/// Links OCR-extracted documents to existing domain entities.
///
/// All methods are asynchronous to allow future extension to database lookups
/// without changing the API. Current implementations are pure in-memory.
///
/// This is a pure-Dart domain service — no Flutter or platform imports.
///
/// Usage:
/// ```dart
/// final linker = DocumentLinker();
/// final clientId = await linker.findClientByPan('ABCDE1234F', clients);
/// final category = linker.suggestCategory(DocumentType.form16);
/// ```
class DocumentLinker {
  const DocumentLinker();

  // ---------------------------------------------------------------------------
  // findClientByPan
  // ---------------------------------------------------------------------------

  /// Finds the [Client.id] whose [Client.pan] matches [pan] (case-insensitive).
  ///
  /// Returns `null` when no client is found.
  Future<String?> findClientByPan(String pan, List<Client> clients) async {
    if (pan.trim().isEmpty) return null;

    final normalised = pan.trim().toUpperCase();
    for (final client in clients) {
      if (client.pan.toUpperCase() == normalised) {
        return client.id;
      }
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // findGstClientByGstin
  // ---------------------------------------------------------------------------

  /// Finds the [GstClient.id] whose [GstClient.gstin] matches [gstin].
  ///
  /// Returns `null` when no GST client is found.
  Future<String?> findGstClientByGstin(
    String gstin,
    List<GstClient> clients,
  ) async {
    if (gstin.trim().isEmpty) return null;

    final normalised = gstin.trim().toUpperCase();
    for (final client in clients) {
      if (client.gstin.toUpperCase() == normalised) {
        return client.id;
      }
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // findClientByPanOrGstin
  // ---------------------------------------------------------------------------

  /// Convenience method that tries PAN matching first, then GSTIN derivation.
  ///
  /// GSTIN embeds the PAN at characters 3–12 (0-indexed), so if a GSTIN is
  /// provided the PAN is extracted and used to search [clients].
  ///
  /// Returns the first matching [Client.id], or `null`.
  Future<String?> findClientByPanOrGstin(
    String identifier,
    List<Client> clients,
  ) async {
    final normalised = identifier.trim().toUpperCase();

    // Direct PAN match
    final byPan = await findClientByPan(normalised, clients);
    if (byPan != null) return byPan;

    // Try extracting PAN from GSTIN (positions 2..11, 0-indexed)
    if (normalised.length == 15) {
      final panFromGstin = normalised.substring(2, 12);
      return findClientByPan(panFromGstin, clients);
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // suggestCategory
  // ---------------------------------------------------------------------------

  /// Returns the most appropriate [DocumentCategory] for a [DocumentType].
  DocumentCategory suggestCategory(DocumentType docType) {
    switch (docType) {
      case DocumentType.form16:
      case DocumentType.form26as:
        return DocumentCategory.tdsDocuments;

      case DocumentType.gstInvoice:
        return DocumentCategory.gstDocuments;

      case DocumentType.bankStatement:
        return DocumentCategory.bankingDocuments;

      case DocumentType.panCard:
      case DocumentType.aadhaarCard:
        return DocumentCategory.kycDocuments;

      case DocumentType.balanceSheet:
        return DocumentCategory.financialStatements;

      case DocumentType.salarySlip:
        return DocumentCategory.payrollDocuments;

      case DocumentType.unknown:
        return DocumentCategory.generalDocuments;
    }
  }

  // ---------------------------------------------------------------------------
  // buildDocumentTag
  // ---------------------------------------------------------------------------

  /// Returns a canonical tag string combining [docType] and [clientId] for
  /// storage metadata. Useful as a database index key.
  ///
  /// Example: `'form16::client_abc123'`
  String buildDocumentTag(DocumentType docType, String? clientId) {
    final typeTag = docType.name;
    if (clientId == null || clientId.isEmpty) return typeTag;
    return '$typeTag::$clientId';
  }
}
