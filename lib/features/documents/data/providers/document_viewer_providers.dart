import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/documents/data/providers/documents_providers.dart';
import 'package:ca_app/features/documents/domain/models/document.dart';

// ---------------------------------------------------------------------------
// Selected document for the viewer
// ---------------------------------------------------------------------------

final selectedDocumentProvider = Provider.family<Document?, String>((ref, id) {
  final docs = ref.watch(allDocumentsProvider).asData?.value ?? [];
  final matches = docs.where((d) => d.id == id);
  return matches.isEmpty ? null : matches.first;
});

// ---------------------------------------------------------------------------
// OCR extraction results (mock data)
// ---------------------------------------------------------------------------

/// Represents a single field extracted by OCR.
class OcrField {
  const OcrField({
    required this.label,
    required this.value,
    required this.confidence,
    this.source = 'Page 1',
  });

  final String label;
  final String value;
  final double confidence;
  final String source;

  OcrField copyWith({
    String? label,
    String? value,
    double? confidence,
    String? source,
  }) {
    return OcrField(
      label: label ?? this.label,
      value: value ?? this.value,
      confidence: confidence ?? this.confidence,
      source: source ?? this.source,
    );
  }
}

final ocrResultProvider = NotifierProvider<OcrResultNotifier, List<OcrField>>(
  OcrResultNotifier.new,
);

class OcrResultNotifier extends Notifier<List<OcrField>> {
  @override
  List<OcrField> build() => List.unmodifiable(_mockOcrFields);

  void updateField(int index, String newValue) {
    final updated = [
      for (int i = 0; i < state.length; i++)
        if (i == index) state[i].copyWith(value: newValue) else state[i],
    ];
    state = List.unmodifiable(updated);
  }
}

const _mockOcrFields = <OcrField>[
  OcrField(label: 'PAN Number', value: 'ABCPK1234F', confidence: 0.97),
  OcrField(label: 'Name', value: 'Rajesh Kumar Sharma', confidence: 0.95),
  OcrField(label: 'Assessment Year', value: '2025-26', confidence: 0.99),
  OcrField(label: 'Total Income', value: '12,45,000', confidence: 0.88),
  OcrField(
    label: 'Tax Payable',
    value: '1,24,500',
    confidence: 0.85,
    source: 'Page 2',
  ),
  OcrField(label: 'Date', value: '25-07-2025', confidence: 0.72),
  OcrField(
    label: 'Address',
    value: '42, MG Road, Pune 411001',
    confidence: 0.68,
    source: 'Page 1',
  ),
];

// ---------------------------------------------------------------------------
// Upload progress tracking
// ---------------------------------------------------------------------------

/// Tracks upload state for a single file.
class UploadFileState {
  const UploadFileState({
    required this.fileName,
    required this.fileSize,
    this.progress = 0.0,
    this.isComplete = false,
    this.error,
  });

  final String fileName;
  final int fileSize;
  final double progress;
  final bool isComplete;
  final String? error;

  UploadFileState copyWith({
    String? fileName,
    int? fileSize,
    double? progress,
    bool? isComplete,
    String? error,
  }) {
    return UploadFileState(
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      progress: progress ?? this.progress,
      isComplete: isComplete ?? this.isComplete,
      error: error ?? this.error,
    );
  }
}

final uploadProgressProvider =
    NotifierProvider<UploadProgressNotifier, List<UploadFileState>>(
      UploadProgressNotifier.new,
    );

class UploadProgressNotifier extends Notifier<List<UploadFileState>> {
  @override
  List<UploadFileState> build() => const [];

  void addFiles(List<UploadFileState> files) {
    state = List.unmodifiable([...state, ...files]);
  }

  void updateProgress(int index, double progress) {
    final updated = [
      for (int i = 0; i < state.length; i++)
        if (i == index)
          state[i].copyWith(progress: progress, isComplete: progress >= 1.0)
        else
          state[i],
    ];
    state = List.unmodifiable(updated);
  }

  void clear() => state = const [];
}

// ---------------------------------------------------------------------------
// Document version history (mock)
// ---------------------------------------------------------------------------

/// Represents a historical version of a document.
class DocumentVersion {
  const DocumentVersion({
    required this.version,
    required this.uploadedBy,
    required this.uploadedAt,
    required this.fileSize,
    this.remarks,
  });

  final int version;
  final String uploadedBy;
  final DateTime uploadedAt;
  final int fileSize;
  final String? remarks;
}

final documentVersionsProvider = Provider.family<List<DocumentVersion>, String>(
  (ref, documentId) {
    // Mock version history for documents with version > 1.
    final doc = ref.watch(selectedDocumentProvider(documentId));
    if (doc == null || doc.version <= 1) return const [];

    return List.unmodifiable([
      DocumentVersion(
        version: doc.version,
        uploadedBy: doc.uploadedBy,
        uploadedAt: doc.uploadedAt,
        fileSize: doc.fileSize,
        remarks: doc.remarks,
      ),
      DocumentVersion(
        version: doc.version - 1,
        uploadedBy: doc.uploadedBy,
        uploadedAt: doc.uploadedAt.subtract(const Duration(days: 30)),
        fileSize: (doc.fileSize * 0.9).round(),
        remarks: 'Draft version',
      ),
    ]);
  },
);
