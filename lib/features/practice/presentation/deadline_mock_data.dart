// Mock deadline data for the deadline intelligence dashboard.
// Replace with real data source (Drift DB / Supabase) when available.

/// Immutable deadline item for display in the dashboard.
class DeadlineItem {
  const DeadlineItem({
    required this.title,
    required this.dueDate,
    required this.riskScore,
    required this.category,
    this.penaltyAmount,
  });

  final String title;
  final DateTime dueDate;
  final double riskScore;
  final String category;
  final double? penaltyAmount;
}

final _now = DateTime.now();

/// 13 mock deadlines across ITR, GST, TDS, ROC, Audit, PF/ESI categories.
final mockDeadlines = <DeadlineItem>[
  // Overdue
  DeadlineItem(
    title: 'GSTR-3B Feb 2026 — Priya Mehta',
    dueDate: _now.subtract(const Duration(days: 2)),
    riskScore: 0.95,
    category: 'GST',
    penaltyAmount: 5000,
  ),
  DeadlineItem(
    title: 'Monthly Bookkeeping — Mehta & Sons',
    dueDate: _now.subtract(const Duration(days: 1)),
    riskScore: 0.80,
    category: 'Audit',
    penaltyAmount: 0,
  ),

  // Critical — next 3 days
  DeadlineItem(
    title: 'Advance Tax Q4 — Deepak Patel',
    dueDate: _now.add(const Duration(days: 3)),
    riskScore: 0.90,
    category: 'ITR',
    penaltyAmount: 25000,
  ),

  // High — next 7 days
  DeadlineItem(
    title: 'ITR-1 Filing — Rajesh Kumar Sharma',
    dueDate: _now.add(const Duration(days: 5)),
    riskScore: 0.70,
    category: 'ITR',
    penaltyAmount: 5000,
  ),
  DeadlineItem(
    title: 'GST Registration Amendment — GreenLeaf',
    dueDate: _now.add(const Duration(days: 7)),
    riskScore: 0.40,
    category: 'GST',
  ),

  // Medium — next 2 weeks
  DeadlineItem(
    title: 'Statutory Audit Fieldwork — ABC Infra',
    dueDate: _now.add(const Duration(days: 10)),
    riskScore: 0.65,
    category: 'Audit',
    penaltyAmount: 50000,
  ),
  DeadlineItem(
    title: 'TDS Return 24Q Q4 — ABC Infra',
    dueDate: _now.add(const Duration(days: 15)),
    riskScore: 0.55,
    category: 'TDS',
    penaltyAmount: 10000,
  ),
  DeadlineItem(
    title: 'ITR-4 Filing — Deepak Patel',
    dueDate: _now.add(const Duration(days: 15)),
    riskScore: 0.45,
    category: 'ITR',
    penaltyAmount: 5000,
  ),

  // Lower risk — this month
  DeadlineItem(
    title: 'GSTR-9 Annual Return — Mehta & Sons',
    dueDate: _now.add(const Duration(days: 20)),
    riskScore: 0.50,
    category: 'GST',
    penaltyAmount: 25000,
  ),
  DeadlineItem(
    title: 'PF Monthly Challan — TechVista',
    dueDate: _now.add(const Duration(days: 10)),
    riskScore: 0.35,
    category: 'PF/ESI',
    penaltyAmount: 2000,
  ),
  DeadlineItem(
    title: 'ESI Half-Yearly Return — TechVista',
    dueDate: _now.add(const Duration(days: 25)),
    riskScore: 0.30,
    category: 'PF/ESI',
    penaltyAmount: 5000,
  ),

  // Safe — beyond this month
  DeadlineItem(
    title: 'ROC Annual Filing — ABC Infra',
    dueDate: _now.add(const Duration(days: 45)),
    riskScore: 0.20,
    category: 'ROC',
    penaltyAmount: 100000,
  ),
  DeadlineItem(
    title: 'Transfer Pricing Report — Bharat Electronics',
    dueDate: _now.add(const Duration(days: 90)),
    riskScore: 0.10,
    category: 'ITR',
    penaltyAmount: 500000,
  ),
];
