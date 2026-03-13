import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/documents/data/providers/document_repository_providers.dart';
import 'package:ca_app/features/documents/domain/models/document.dart';
import 'package:ca_app/features/documents/domain/models/document_folder.dart';
import 'package:ca_app/features/documents/domain/repositories/document_repository.dart';

// ---------------------------------------------------------------------------
// Mock data — 20 documents across 8 clients
// ---------------------------------------------------------------------------

final _mockDocuments = <Document>[
  Document(
    id: 'd1',
    clientId: '3',
    clientName: 'ABC Infra Pvt Ltd',
    title: 'ITR-6 AY 2024-25',
    category: DocumentCategory.taxReturns,
    fileType: DocumentFileType.pdf,
    fileSize: 1245184,
    uploadedBy: 'CA Ramesh Iyer',
    uploadedAt: DateTime(2025, 8, 20),
    tags: ['ITR', 'AY2024-25'],
    isSharedWithClient: true,
    downloadCount: 3,
    version: 1,
    remarks: 'Filed successfully. Acknowledgment attached.',
  ),
  Document(
    id: 'd2',
    clientId: '3',
    clientName: 'ABC Infra Pvt Ltd',
    title: 'GSTR-9 FY 2024-25',
    category: DocumentCategory.gstReturns,
    fileType: DocumentFileType.pdf,
    fileSize: 890112,
    uploadedBy: 'CA Ramesh Iyer',
    uploadedAt: DateTime(2025, 12, 31),
    tags: ['GST', 'Annual Return'],
    isSharedWithClient: false,
    downloadCount: 1,
    version: 1,
  ),
  Document(
    id: 'd3',
    clientId: '3',
    clientName: 'ABC Infra Pvt Ltd',
    title: 'Audited Balance Sheet FY 2024-25',
    category: DocumentCategory.financialStatements,
    fileType: DocumentFileType.pdf,
    fileSize: 2097152,
    uploadedBy: 'CA Ramesh Iyer',
    uploadedAt: DateTime(2025, 9, 30),
    tags: ['Audit', 'Balance Sheet', 'P&L'],
    isSharedWithClient: true,
    downloadCount: 5,
    version: 2,
    remarks: 'Final signed copy.',
  ),
  Document(
    id: 'd4',
    clientId: '8',
    clientName: 'Bharat Electronics Ltd',
    title: 'Form 16A Q3 FY 2024-25',
    category: DocumentCategory.tdsCertificates,
    fileType: DocumentFileType.pdf,
    fileSize: 512000,
    uploadedBy: 'CA Priya Nair',
    uploadedAt: DateTime(2025, 1, 15),
    tags: ['TDS', 'Form 16A', 'Q3'],
    isSharedWithClient: true,
    downloadCount: 2,
    version: 1,
  ),
  Document(
    id: 'd5',
    clientId: '8',
    clientName: 'Bharat Electronics Ltd',
    title: 'Statutory Audit Report FY 2024-25',
    category: DocumentCategory.auditReports,
    fileType: DocumentFileType.pdf,
    fileSize: 3145728,
    uploadedBy: 'CA Priya Nair',
    uploadedAt: DateTime(2025, 10, 5),
    tags: ['Statutory Audit', 'CARO'],
    isSharedWithClient: true,
    downloadCount: 7,
    version: 1,
    remarks: 'Signed audit report with UDIN.',
  ),
  Document(
    id: 'd6',
    clientId: '1',
    clientName: 'Rajesh Kumar Sharma',
    title: 'ITR-2 AY 2025-26',
    category: DocumentCategory.taxReturns,
    fileType: DocumentFileType.pdf,
    fileSize: 768000,
    uploadedBy: 'CA Ramesh Iyer',
    uploadedAt: DateTime(2025, 7, 25),
    tags: ['ITR-2', 'Capital Gains'],
    isSharedWithClient: true,
    downloadCount: 4,
    version: 1,
  ),
  Document(
    id: 'd7',
    clientId: '1',
    clientName: 'Rajesh Kumar Sharma',
    title: 'Aadhaar & PAN Copy',
    category: DocumentCategory.identity,
    fileType: DocumentFileType.image,
    fileSize: 204800,
    uploadedBy: 'Rajesh Kumar Sharma',
    uploadedAt: DateTime(2024, 1, 12),
    tags: ['KYC', 'Identity'],
    isSharedWithClient: false,
    downloadCount: 0,
    version: 1,
  ),
  Document(
    id: 'd8',
    clientId: '4',
    clientName: 'Mehta & Sons',
    title: 'Partnership Deed 2020',
    category: DocumentCategory.agreements,
    fileType: DocumentFileType.pdf,
    fileSize: 1048576,
    uploadedBy: 'CA Ramesh Iyer',
    uploadedAt: DateTime(2020, 4, 1),
    tags: ['Partnership', 'Deed'],
    isSharedWithClient: true,
    downloadCount: 2,
    version: 1,
    remarks: 'Registered partnership deed.',
  ),
  Document(
    id: 'd9',
    clientId: '4',
    clientName: 'Mehta & Sons',
    title: 'GSTR-3B Apr 2025',
    category: DocumentCategory.gstReturns,
    fileType: DocumentFileType.excel,
    fileSize: 163840,
    uploadedBy: 'CA Ramesh Iyer',
    uploadedAt: DateTime(2025, 5, 20),
    tags: ['GSTR-3B', 'Apr 2025'],
    isSharedWithClient: false,
    downloadCount: 1,
    version: 1,
  ),
  Document(
    id: 'd10',
    clientId: '6',
    clientName: 'TechVista Solutions LLP',
    title: 'LLP Agreement 2019',
    category: DocumentCategory.agreements,
    fileType: DocumentFileType.pdf,
    fileSize: 1310720,
    uploadedBy: 'CA Ramesh Iyer',
    uploadedAt: DateTime(2019, 9, 15),
    tags: ['LLP', 'Agreement'],
    isSharedWithClient: true,
    downloadCount: 3,
    version: 1,
  ),
  Document(
    id: 'd11',
    clientId: '6',
    clientName: 'TechVista Solutions LLP',
    title: 'Bank Statement Apr–Sep 2025',
    category: DocumentCategory.bankStatements,
    fileType: DocumentFileType.pdf,
    fileSize: 614400,
    uploadedBy: 'CA Priya Nair',
    uploadedAt: DateTime(2025, 10, 1),
    tags: ['Bank', 'H1 FY2026'],
    isSharedWithClient: false,
    downloadCount: 0,
    version: 1,
  ),
  Document(
    id: 'd12',
    clientId: '2',
    clientName: 'Priya Mehta',
    title: 'ITR-2 AY 2025-26',
    category: DocumentCategory.taxReturns,
    fileType: DocumentFileType.pdf,
    fileSize: 409600,
    uploadedBy: 'CA Ramesh Iyer',
    uploadedAt: DateTime(2025, 7, 30),
    tags: ['ITR-2', 'Equity Capital Gains'],
    isSharedWithClient: true,
    downloadCount: 2,
    version: 1,
  ),
  Document(
    id: 'd13',
    clientId: '2',
    clientName: 'Priya Mehta',
    title: 'Income Tax Notice AY 2023-24',
    category: DocumentCategory.notices,
    fileType: DocumentFileType.pdf,
    fileSize: 307200,
    uploadedBy: 'CA Ramesh Iyer',
    uploadedAt: DateTime(2025, 3, 10),
    tags: ['Notice', 'Section 143(1)'],
    isSharedWithClient: true,
    downloadCount: 6,
    version: 1,
    remarks: 'Defective return notice. Response filed.',
  ),
  Document(
    id: 'd14',
    clientId: '13',
    clientName: 'GreenLeaf Organics LLP',
    title: 'GSTR-1 Jul 2025',
    category: DocumentCategory.gstReturns,
    fileType: DocumentFileType.excel,
    fileSize: 245760,
    uploadedBy: 'CA Priya Nair',
    uploadedAt: DateTime(2025, 8, 11),
    tags: ['GSTR-1', 'Jul 2025'],
    isSharedWithClient: false,
    downloadCount: 0,
    version: 1,
  ),
  Document(
    id: 'd15',
    clientId: '13',
    clientName: 'GreenLeaf Organics LLP',
    title: 'Form 26AS AY 2025-26',
    category: DocumentCategory.tdsCertificates,
    fileType: DocumentFileType.pdf,
    fileSize: 358400,
    uploadedBy: 'CA Priya Nair',
    uploadedAt: DateTime(2025, 6, 20),
    tags: ['Form 26AS', 'TDS'],
    isSharedWithClient: true,
    downloadCount: 1,
    version: 1,
  ),
  Document(
    id: 'd16',
    clientId: '9',
    clientName: 'Deepak Patel',
    title: 'GST Registration Certificate',
    category: DocumentCategory.identity,
    fileType: DocumentFileType.pdf,
    fileSize: 204800,
    uploadedBy: 'CA Ramesh Iyer',
    uploadedAt: DateTime(2024, 9, 5),
    tags: ['GST Reg', 'GSTIN'],
    isSharedWithClient: true,
    downloadCount: 2,
    version: 1,
  ),
  Document(
    id: 'd17',
    clientId: '9',
    clientName: 'Deepak Patel',
    title: 'Professional Tax Challan FY 2025-26',
    category: DocumentCategory.miscellaneous,
    fileType: DocumentFileType.pdf,
    fileSize: 102400,
    uploadedBy: 'CA Ramesh Iyer',
    uploadedAt: DateTime(2025, 4, 30),
    tags: ['Challan', 'PT'],
    isSharedWithClient: false,
    downloadCount: 0,
    version: 1,
  ),
  Document(
    id: 'd18',
    clientId: '8',
    clientName: 'Bharat Electronics Ltd',
    title: 'Payroll Register Sep 2025',
    category: DocumentCategory.miscellaneous,
    fileType: DocumentFileType.excel,
    fileSize: 532480,
    uploadedBy: 'CA Priya Nair',
    uploadedAt: DateTime(2025, 10, 7),
    tags: ['Payroll', 'Sep 2025'],
    isSharedWithClient: false,
    downloadCount: 0,
    version: 1,
  ),
  Document(
    id: 'd19',
    clientId: '3',
    clientName: 'ABC Infra Pvt Ltd',
    title: 'Income Tax Demand Notice AY 2022-23',
    category: DocumentCategory.notices,
    fileType: DocumentFileType.pdf,
    fileSize: 245760,
    uploadedBy: 'CA Ramesh Iyer',
    uploadedAt: DateTime(2024, 11, 20),
    tags: ['Demand', '143(3)'],
    isSharedWithClient: true,
    downloadCount: 9,
    version: 1,
    remarks: 'Appeal filed before CIT(A).',
  ),
  Document(
    id: 'd20',
    clientId: '6',
    clientName: 'TechVista Solutions LLP',
    title: 'Employee NDA Template',
    category: DocumentCategory.agreements,
    fileType: DocumentFileType.word,
    fileSize: 81920,
    uploadedBy: 'CA Ramesh Iyer',
    uploadedAt: DateTime(2025, 2, 14),
    tags: ['NDA', 'HR'],
    isSharedWithClient: false,
    downloadCount: 4,
    version: 3,
  ),
];

// ---------------------------------------------------------------------------
// Mock folders — 10 folders
// ---------------------------------------------------------------------------

final _mockFolders = <DocumentFolder>[
  DocumentFolder(
    id: 'f1',
    clientId: '3',
    clientName: 'ABC Infra Pvt Ltd',
    folderName: 'Tax Returns',
    documentCount: 3,
    lastModified: DateTime(2025, 8, 20),
    createdBy: 'CA Ramesh Iyer',
  ),
  DocumentFolder(
    id: 'f2',
    clientId: '3',
    clientName: 'ABC Infra Pvt Ltd',
    folderName: 'Legal Notices',
    documentCount: 2,
    lastModified: DateTime(2024, 11, 20),
    createdBy: 'CA Ramesh Iyer',
  ),
  DocumentFolder(
    id: 'f3',
    clientId: '8',
    clientName: 'Bharat Electronics Ltd',
    folderName: 'Audit Documents',
    documentCount: 4,
    lastModified: DateTime(2025, 10, 7),
    createdBy: 'CA Priya Nair',
  ),
  DocumentFolder(
    id: 'f4',
    clientId: '8',
    clientName: 'Bharat Electronics Ltd',
    folderName: 'TDS Certificates',
    documentCount: 2,
    lastModified: DateTime(2025, 1, 15),
    createdBy: 'CA Priya Nair',
  ),
  DocumentFolder(
    id: 'f5',
    clientId: '6',
    clientName: 'TechVista Solutions LLP',
    folderName: 'Agreements & Deeds',
    documentCount: 3,
    lastModified: DateTime(2025, 2, 14),
    createdBy: 'CA Ramesh Iyer',
  ),
  DocumentFolder(
    id: 'f6',
    clientId: '4',
    clientName: 'Mehta & Sons',
    folderName: 'GST Returns',
    documentCount: 2,
    lastModified: DateTime(2025, 5, 20),
    createdBy: 'CA Ramesh Iyer',
  ),
  DocumentFolder(
    id: 'f7',
    clientId: '1',
    clientName: 'Rajesh Kumar Sharma',
    folderName: 'KYC Documents',
    documentCount: 2,
    lastModified: DateTime(2025, 7, 25),
    createdBy: 'CA Ramesh Iyer',
  ),
  DocumentFolder(
    id: 'f8',
    clientId: '2',
    clientName: 'Priya Mehta',
    folderName: 'Income Tax',
    documentCount: 2,
    lastModified: DateTime(2025, 7, 30),
    createdBy: 'CA Ramesh Iyer',
  ),
  DocumentFolder(
    id: 'f9',
    clientId: '13',
    clientName: 'GreenLeaf Organics LLP',
    folderName: 'GST & TDS',
    documentCount: 2,
    lastModified: DateTime(2025, 8, 11),
    createdBy: 'CA Priya Nair',
  ),
  DocumentFolder(
    id: 'f10',
    clientId: '9',
    clientName: 'Deepak Patel',
    folderName: 'Registrations & Challans',
    documentCount: 2,
    lastModified: DateTime(2025, 4, 30),
    createdBy: 'CA Ramesh Iyer',
  ),
];

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final allDocumentsProvider =
    AsyncNotifierProvider<AllDocumentsNotifier, List<Document>>(
      AllDocumentsNotifier.new,
    );

class AllDocumentsNotifier extends AsyncNotifier<List<Document>> {
  @override
  Future<List<Document>> build() async {
    final repo = ref.watch(documentRepositoryProvider);
    return _load(repo);
  }

  Future<List<Document>> _load(DocumentRepository repo) async {
    try {
      final results = await repo.searchDocuments('');
      if (results.isEmpty) return List.unmodifiable(_mockDocuments);
      return List.unmodifiable(results);
    } catch (_) {
      return List.unmodifiable(_mockDocuments);
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    final repo = ref.read(documentRepositoryProvider);
    state = await AsyncValue.guard(() => _load(repo));
  }

  void setDocuments(List<Document> value) {
    state = AsyncData(List.unmodifiable(value));
  }
}

final allFoldersProvider =
    NotifierProvider<AllFoldersNotifier, List<DocumentFolder>>(
      AllFoldersNotifier.new,
    );

class AllFoldersNotifier extends Notifier<List<DocumentFolder>> {
  @override
  List<DocumentFolder> build() => List.unmodifiable(_mockFolders);

  void update(List<DocumentFolder> value) => state = List.unmodifiable(value);
}

// Filter: search query
final docSearchQueryProvider = NotifierProvider<DocSearchQueryNotifier, String>(
  DocSearchQueryNotifier.new,
);

class DocSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String value) => state = value;
}

// Filter: selected category
final docCategoryFilterProvider =
    NotifierProvider<DocCategoryFilterNotifier, DocumentCategory?>(
      DocCategoryFilterNotifier.new,
    );

class DocCategoryFilterNotifier extends Notifier<DocumentCategory?> {
  @override
  DocumentCategory? build() => null;

  void update(DocumentCategory? value) => state = value;
}

// Filter: selected client id
final docClientFilterProvider =
    NotifierProvider<DocClientFilterNotifier, String?>(
      DocClientFilterNotifier.new,
    );

class DocClientFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void update(String? value) => state = value;
}

/// Computed list of filtered documents.
final filteredDocumentsProvider = Provider<List<Document>>((ref) {
  final docs = ref.watch(allDocumentsProvider).asData?.value ?? [];
  final query = ref.watch(docSearchQueryProvider).toLowerCase().trim();
  final category = ref.watch(docCategoryFilterProvider);
  final clientId = ref.watch(docClientFilterProvider);

  return List.unmodifiable(
    docs.where((doc) {
      if (category != null && doc.category != category) return false;
      if (clientId != null && doc.clientId != clientId) return false;
      if (query.isNotEmpty) {
        final matchesTitle = doc.title.toLowerCase().contains(query);
        final matchesClient = doc.clientName.toLowerCase().contains(query);
        final matchesTags = doc.tags.any(
          (t) => t.toLowerCase().contains(query),
        );
        return matchesTitle || matchesClient || matchesTags;
      }
      return true;
    }).toList()..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt)),
  );
});

/// Filtered folders matching current client filter and search query.
final filteredFoldersProvider = Provider<List<DocumentFolder>>((ref) {
  final folders = ref.watch(allFoldersProvider);
  final query = ref.watch(docSearchQueryProvider).toLowerCase().trim();
  final clientId = ref.watch(docClientFilterProvider);

  return List.unmodifiable(
    folders.where((folder) {
      if (clientId != null && folder.clientId != clientId) return false;
      if (query.isNotEmpty) {
        final matchesName = folder.folderName.toLowerCase().contains(query);
        final matchesClient = folder.clientName.toLowerCase().contains(query);
        return matchesName || matchesClient;
      }
      return true;
    }).toList()..sort((a, b) => b.lastModified.compareTo(a.lastModified)),
  );
});

/// Summary counts for the documents screen header.
final docSummaryProvider = Provider<({int total, int shared, int folders})>((
  ref,
) {
  final docs = ref.watch(allDocumentsProvider).asData?.value ?? [];
  final folders = ref.watch(allFoldersProvider);
  final shared = docs.where((d) => d.isSharedWithClient).length;
  return (total: docs.length, shared: shared, folders: folders.length);
});
