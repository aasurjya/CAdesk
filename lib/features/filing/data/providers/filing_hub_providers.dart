import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/filing/domain/models/filing_hub_item.dart';

/// Currently selected assessment year for the Filing Hub.
final selectedAssessmentYearProvider =
    NotifierProvider<SelectedAssessmentYearNotifier, String>(
      SelectedAssessmentYearNotifier.new,
    );

class SelectedAssessmentYearNotifier extends Notifier<String> {
  @override
  String build() => 'AY 2026-27';

  void update(String value) => state = value;
}

/// All filing hub items (mock data aggregated across ITR/GST/TDS/MCA).
final filingHubItemsProvider =
    NotifierProvider<FilingHubItemsNotifier, List<FilingHubItem>>(
      FilingHubItemsNotifier.new,
    );

class FilingHubItemsNotifier extends Notifier<List<FilingHubItem>> {
  @override
  List<FilingHubItem> build() => _mockFilingItems;

  void update(List<FilingHubItem> items) => state = items;
}

/// Urgent filings: overdue + dueThisWeek items, sorted by dueDate ascending.
final urgentFilingsProvider = Provider<List<FilingHubItem>>((ref) {
  final items = ref.watch(filingHubItemsProvider);
  return items
      .where(
        (item) =>
            item.status == FilingHubStatus.overdue ||
            item.status == FilingHubStatus.dueThisWeek,
      )
      .toList()
    ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
});

/// In-progress filings: inProgress + draft items, sorted by dueDate ascending.
final inProgressFilingsProvider = Provider<List<FilingHubItem>>((ref) {
  final items = ref.watch(filingHubItemsProvider);
  return items
      .where(
        (item) =>
            item.status == FilingHubStatus.inProgress ||
            item.status == FilingHubStatus.draft,
      )
      .toList()
    ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
});

/// Recently filed returns: filed + verified items, sorted by filedDate desc.
final recentFilingsProvider = Provider<List<FilingHubItem>>((ref) {
  final items = ref.watch(filingHubItemsProvider);
  final recent =
      items
          .where(
            (item) =>
                item.status == FilingHubStatus.filed ||
                item.status == FilingHubStatus.verified,
          )
          .toList()
        ..sort((a, b) {
          final aDate = a.filedDate ?? DateTime(2000);
          final bDate = b.filedDate ?? DateTime(2000);
          return bDate.compareTo(aDate);
        });
  return recent;
});

// ---------------------------------------------------------------------------
// Mock filing data across ITR / GST / TDS / MCA
// ---------------------------------------------------------------------------

final _now = DateTime.now();
final _year = _now.year;
final _month = _now.month;

final _mockFilingItems = <FilingHubItem>[
  // --- Overdue ---
  FilingHubItem(
    id: 'fh-001',
    clientName: 'Sharma & Associates',
    filingType: FilingCategory.gst,
    subType: 'GSTR-3B',
    status: FilingHubStatus.overdue,
    dueDate: DateTime(_year, _month, _now.day - 5),
  ),
  FilingHubItem(
    id: 'fh-002',
    clientName: 'Mehta Industries Pvt Ltd',
    filingType: FilingCategory.tds,
    subType: 'Form 24Q',
    status: FilingHubStatus.overdue,
    dueDate: DateTime(_year, _month, _now.day - 2),
  ),

  // --- Due This Week ---
  FilingHubItem(
    id: 'fh-003',
    clientName: 'Patel Traders',
    filingType: FilingCategory.gst,
    subType: 'GSTR-1',
    status: FilingHubStatus.dueThisWeek,
    dueDate: DateTime(_year, _month, _now.day + 2),
  ),
  FilingHubItem(
    id: 'fh-004',
    clientName: 'Agarwal & Sons',
    filingType: FilingCategory.itr,
    subType: 'ITR-3',
    status: FilingHubStatus.dueThisWeek,
    dueDate: DateTime(_year, _month, _now.day + 4),
  ),

  // --- In Progress ---
  FilingHubItem(
    id: 'fh-005',
    clientName: 'Gupta Enterprises',
    filingType: FilingCategory.itr,
    subType: 'ITR-1',
    status: FilingHubStatus.inProgress,
    dueDate: DateTime(_year, _month + 1, 31),
  ),
  FilingHubItem(
    id: 'fh-006',
    clientName: 'Reddy Holdings',
    filingType: FilingCategory.mca,
    subType: 'MGT-7',
    status: FilingHubStatus.inProgress,
    dueDate: DateTime(_year, _month + 1, 30),
  ),
  FilingHubItem(
    id: 'fh-007',
    clientName: 'Joshi Consulting',
    filingType: FilingCategory.gst,
    subType: 'GSTR-9',
    status: FilingHubStatus.inProgress,
    dueDate: DateTime(_year, _month + 2, 31),
  ),

  // --- Draft ---
  FilingHubItem(
    id: 'fh-008',
    clientName: 'Kapoor & Co',
    filingType: FilingCategory.tds,
    subType: 'Form 26Q',
    status: FilingHubStatus.draft,
    dueDate: DateTime(_year, _month + 1, 15),
  ),
  FilingHubItem(
    id: 'fh-009',
    clientName: 'Singh Infrastructure',
    filingType: FilingCategory.itr,
    subType: 'ITR-6',
    status: FilingHubStatus.draft,
    dueDate: DateTime(_year, _month + 2, 30),
  ),

  // --- Filed ---
  FilingHubItem(
    id: 'fh-010',
    clientName: 'Verma Textiles',
    filingType: FilingCategory.gst,
    subType: 'GSTR-3B',
    status: FilingHubStatus.filed,
    dueDate: DateTime(_year, _month - 1, 20),
    filedDate: DateTime(_year, _month - 1, 19),
  ),
  FilingHubItem(
    id: 'fh-011',
    clientName: 'Bose Electronics',
    filingType: FilingCategory.tds,
    subType: 'Form 24Q',
    status: FilingHubStatus.filed,
    dueDate: DateTime(_year, _month - 1, 31),
    filedDate: DateTime(_year, _month - 1, 28),
  ),

  // --- Verified ---
  FilingHubItem(
    id: 'fh-012',
    clientName: 'Nair & Partners',
    filingType: FilingCategory.itr,
    subType: 'ITR-4',
    status: FilingHubStatus.verified,
    dueDate: DateTime(_year, _month - 2, 31),
    filedDate: DateTime(_year, _month - 2, 25),
  ),
  FilingHubItem(
    id: 'fh-013',
    clientName: 'Iyer Logistics',
    filingType: FilingCategory.mca,
    subType: 'AOC-4',
    status: FilingHubStatus.verified,
    dueDate: DateTime(_year, _month - 2, 30),
    filedDate: DateTime(_year, _month - 2, 22),
  ),
];
