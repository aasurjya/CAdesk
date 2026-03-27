import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/analytics/domain/services/cross_module_aggregator.dart';
import 'package:ca_app/features/practice/domain/models/billing_invoice.dart';
import 'package:ca_app/features/practice/domain/models/billing_line_item.dart';
import 'package:ca_app/features/practice/domain/models/engagement.dart';
import 'package:ca_app/features/practice/domain/models/workflow_task.dart';
import 'package:ca_app/features/practice/domain/models/staff_assignment.dart';

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

BillingInvoice _makeInvoice({
  required String id,
  required DateTime dueDate,
  required int totalAmount,
  PaymentStatus paymentStatus = PaymentStatus.pending,
}) {
  return BillingInvoice(
    invoiceId: id,
    clientId: 'client-1',
    engagementId: 'eng-1',
    lineItems: [
      BillingLineItem(
        description: 'Professional fee',
        sacCode: '998221',
        quantity: 1,
        rate: totalAmount,
        amount: totalAmount,
        gstRate: 0.18,
      ),
    ],
    subtotal: totalAmount,
    gstAmount: (totalAmount * 0.18).toInt(),
    totalAmount: totalAmount,
    dueDate: dueDate,
    paymentStatus: paymentStatus,
  );
}

Engagement _makeEngagement({
  required String id,
  required DateTime dueDate,
  EngagementStatus status = EngagementStatus.inProgress,
  DateTime? completedDate,
  List<WorkflowTask> templateTasks = const [],
  List<StaffAssignment> assignedStaff = const [],
}) {
  return Engagement(
    engagementId: id,
    clientId: 'client-1',
    templateId: 'tmpl-1',
    templateTasks: templateTasks,
    assignedStaff: assignedStaff,
    status: status,
    dueDate: dueDate,
    completedDate: completedDate,
    billingAmount: 50000,
  );
}

WorkflowTask _makeTask(String taskId, {int estimatedHours = 2}) {
  return WorkflowTask(
    taskId: taskId,
    name: 'Task $taskId',
    description: 'Description',
    requiredRole: StaffRole.junior,
    estimatedHours: estimatedHours,
    dependsOn: const [],
    checklistItems: const [],
  );
}

void main() {
  group('CrossModuleAggregator', () {
    final aggregator = CrossModuleAggregator.instance;

    final jan2025 = DateRange(
      start: DateTime(2025, 1, 1),
      end: DateTime(2025, 1, 31),
    );

    // -------------------------------------------------------------------------
    // Singleton
    // -------------------------------------------------------------------------

    group('singleton', () {
      test('instance is always the same object', () {
        expect(
          CrossModuleAggregator.instance,
          same(CrossModuleAggregator.instance),
        );
      });
    });

    // -------------------------------------------------------------------------
    // DateRange
    // -------------------------------------------------------------------------

    group('DateRange', () {
      test('contains returns true for date within range', () {
        expect(jan2025.contains(DateTime(2025, 1, 15)), isTrue);
      });

      test('contains returns true for start date (inclusive)', () {
        expect(jan2025.contains(DateTime(2025, 1, 1)), isTrue);
      });

      test('contains returns true for end date (inclusive)', () {
        expect(jan2025.contains(DateTime(2025, 1, 31)), isTrue);
      });

      test('contains returns false for date before range', () {
        expect(jan2025.contains(DateTime(2024, 12, 31)), isFalse);
      });

      test('contains returns false for date after range', () {
        expect(jan2025.contains(DateTime(2025, 2, 1)), isFalse);
      });

      test('equality based on start and end', () {
        final a = DateRange(
          start: DateTime(2025, 1, 1),
          end: DateTime(2025, 1, 31),
        );
        final b = DateRange(
          start: DateTime(2025, 1, 1),
          end: DateTime(2025, 1, 31),
        );
        expect(a, equals(b));
      });
    });

    // -------------------------------------------------------------------------
    // aggregateBilling — empty data
    // -------------------------------------------------------------------------

    group('aggregateBilling with empty data', () {
      test('returns BillingMetrics with all zeros', () {
        final metrics = aggregator.aggregateBilling([], jan2025);

        expect(metrics.totalBilled, equals(0.0));
        expect(metrics.totalCollected, equals(0.0));
        expect(metrics.outstanding, equals(0.0));
        expect(metrics.invoiceCount, equals(0));
        expect(metrics.collectionRate, equals(0.0));
      });
    });

    // -------------------------------------------------------------------------
    // aggregateBilling — with data
    // -------------------------------------------------------------------------

    group('aggregateBilling with invoices', () {
      test('totalBilled sums all invoices within period', () {
        final invoices = [
          _makeInvoice(
            id: 'inv-1',
            dueDate: DateTime(2025, 1, 10),
            totalAmount: 100000,
          ),
          _makeInvoice(
            id: 'inv-2',
            dueDate: DateTime(2025, 1, 20),
            totalAmount: 50000,
          ),
        ];

        final metrics = aggregator.aggregateBilling(invoices, jan2025);

        expect(metrics.totalBilled, equals(150000.0));
        expect(metrics.invoiceCount, equals(2));
      });

      test('totalCollected only counts paid invoices', () {
        final invoices = [
          _makeInvoice(
            id: 'inv-1',
            dueDate: DateTime(2025, 1, 10),
            totalAmount: 100000,
            paymentStatus: PaymentStatus.paid,
          ),
          _makeInvoice(
            id: 'inv-2',
            dueDate: DateTime(2025, 1, 20),
            totalAmount: 50000,
            paymentStatus: PaymentStatus.pending,
          ),
        ];

        final metrics = aggregator.aggregateBilling(invoices, jan2025);

        expect(metrics.totalCollected, equals(100000.0));
        expect(metrics.outstanding, equals(50000.0));
      });

      test('collectionRate is totalCollected / totalBilled', () {
        final invoices = [
          _makeInvoice(
            id: 'inv-1',
            dueDate: DateTime(2025, 1, 10),
            totalAmount: 200000,
            paymentStatus: PaymentStatus.paid,
          ),
          _makeInvoice(
            id: 'inv-2',
            dueDate: DateTime(2025, 1, 20),
            totalAmount: 200000,
            paymentStatus: PaymentStatus.pending,
          ),
        ];

        final metrics = aggregator.aggregateBilling(invoices, jan2025);

        expect(metrics.collectionRate, closeTo(0.5, 0.001));
      });

      test('excludes invoices outside the period', () {
        final invoices = [
          _makeInvoice(
            id: 'inv-1',
            dueDate: DateTime(2025, 1, 15),
            totalAmount: 100000,
          ),
          _makeInvoice(
            id: 'inv-2',
            dueDate: DateTime(2025, 2, 15), // outside Jan 2025
            totalAmount: 999999,
          ),
        ];

        final metrics = aggregator.aggregateBilling(invoices, jan2025);

        expect(metrics.invoiceCount, equals(1));
        expect(metrics.totalBilled, equals(100000.0));
      });

      test('collectionRate is 0.0 when totalBilled is zero', () {
        final metrics = aggregator.aggregateBilling([], jan2025);
        expect(metrics.collectionRate, equals(0.0));
      });
    });

    // -------------------------------------------------------------------------
    // aggregateFiling — empty data
    // -------------------------------------------------------------------------

    group('aggregateFiling with empty data', () {
      test('returns FilingMetrics with all zeros', () {
        final metrics = aggregator.aggregateFiling([], jan2025);

        expect(metrics.totalFilings, equals(0));
        expect(metrics.completedOnTime, equals(0));
        expect(metrics.completedLate, equals(0));
        expect(metrics.pending, equals(0));
        expect(metrics.complianceRate, equals(0.0));
      });
    });

    // -------------------------------------------------------------------------
    // aggregateFiling — with data
    // -------------------------------------------------------------------------

    group('aggregateFiling with engagements', () {
      test('counts pending engagements not in done/billed status', () {
        final engagements = [
          _makeEngagement(
            id: 'e-1',
            dueDate: DateTime(2025, 1, 15),
            status: EngagementStatus.inProgress,
          ),
          _makeEngagement(
            id: 'e-2',
            dueDate: DateTime(2025, 1, 20),
            status: EngagementStatus.notStarted,
          ),
        ];

        final metrics = aggregator.aggregateFiling(engagements, jan2025);

        expect(metrics.totalFilings, equals(2));
        expect(metrics.pending, equals(2));
        expect(metrics.completedOnTime, equals(0));
      });

      test('counts on-time when completedDate is before or on dueDate', () {
        final engagements = [
          _makeEngagement(
            id: 'e-1',
            dueDate: DateTime(2025, 1, 20),
            status: EngagementStatus.done,
            completedDate: DateTime(2025, 1, 18),
          ),
        ];

        final metrics = aggregator.aggregateFiling(engagements, jan2025);

        expect(metrics.completedOnTime, equals(1));
        expect(metrics.completedLate, equals(0));
      });

      test('counts late when completedDate is after dueDate', () {
        final engagements = [
          _makeEngagement(
            id: 'e-1',
            dueDate: DateTime(2025, 1, 10),
            status: EngagementStatus.done,
            completedDate: DateTime(2025, 1, 15),
          ),
        ];

        final metrics = aggregator.aggregateFiling(engagements, jan2025);

        expect(metrics.completedLate, equals(1));
        expect(metrics.completedOnTime, equals(0));
      });

      test('complianceRate is onTime / total', () {
        final engagements = [
          _makeEngagement(
            id: 'e-1',
            dueDate: DateTime(2025, 1, 10),
            status: EngagementStatus.done,
            completedDate: DateTime(2025, 1, 8),
          ),
          _makeEngagement(
            id: 'e-2',
            dueDate: DateTime(2025, 1, 15),
            status: EngagementStatus.done,
            completedDate: DateTime(2025, 1, 20),
          ),
          _makeEngagement(
            id: 'e-3',
            dueDate: DateTime(2025, 1, 25),
            status: EngagementStatus.inProgress,
          ),
          _makeEngagement(
            id: 'e-4',
            dueDate: DateTime(2025, 1, 28),
            status: EngagementStatus.done,
            completedDate: DateTime(2025, 1, 26),
          ),
        ];

        final metrics = aggregator.aggregateFiling(engagements, jan2025);

        // 2 on time, 1 late, 1 pending; rate = 2/4 = 0.5
        expect(metrics.complianceRate, closeTo(0.5, 0.001));
      });

      test('billed status counts as done (completed)', () {
        final engagements = [
          _makeEngagement(
            id: 'e-1',
            dueDate: DateTime(2025, 1, 15),
            status: EngagementStatus.billed,
            completedDate: DateTime(2025, 1, 14),
          ),
        ];

        final metrics = aggregator.aggregateFiling(engagements, jan2025);

        expect(metrics.pending, equals(0));
        expect(metrics.completedOnTime, equals(1));
      });

      test('excludes engagements outside period', () {
        final engagements = [
          _makeEngagement(
            id: 'e-1',
            dueDate: DateTime(2025, 1, 15),
            status: EngagementStatus.inProgress,
          ),
          _makeEngagement(
            id: 'e-2',
            dueDate: DateTime(2025, 3, 15), // outside
            status: EngagementStatus.inProgress,
          ),
        ];

        final metrics = aggregator.aggregateFiling(engagements, jan2025);

        expect(metrics.totalFilings, equals(1));
      });
    });

    // -------------------------------------------------------------------------
    // aggregateTasks — empty data
    // -------------------------------------------------------------------------

    group('aggregateTasks with empty data', () {
      test('returns TaskMetrics with all zeros', () {
        final metrics = aggregator.aggregateTasks([], jan2025);

        expect(metrics.totalTasks, equals(0));
        expect(metrics.completedTasks, equals(0));
        expect(metrics.pendingTasks, equals(0));
        expect(metrics.completionRate, equals(0.0));
        expect(metrics.avgEstimatedHours, equals(0.0));
      });
    });

    // -------------------------------------------------------------------------
    // aggregateTasks — with data
    // -------------------------------------------------------------------------

    group('aggregateTasks with engagements', () {
      test('totalTasks counts all template tasks across engagements', () {
        final engagements = [
          _makeEngagement(
            id: 'e-1',
            dueDate: DateTime(2025, 1, 15),
            templateTasks: [_makeTask('t1'), _makeTask('t2')],
          ),
          _makeEngagement(
            id: 'e-2',
            dueDate: DateTime(2025, 1, 20),
            templateTasks: [_makeTask('t3')],
          ),
        ];

        final metrics = aggregator.aggregateTasks(engagements, jan2025);

        expect(metrics.totalTasks, equals(3));
      });

      test('completedTasks counts tasks in completedTaskIds', () {
        final engagements = [
          _makeEngagement(
            id: 'e-1',
            dueDate: DateTime(2025, 1, 15),
            templateTasks: [_makeTask('t1'), _makeTask('t2'), _makeTask('t3')],
            assignedStaff: [
              const StaffAssignment(
                staffId: 'staff-1',
                role: StaffRole.junior,
                tasks: ['t1', 't2'],
                hoursLogged: 4,
                hoursEstimated: 4,
              ),
            ],
          ),
        ];

        final metrics = aggregator.aggregateTasks(engagements, jan2025);

        expect(metrics.completedTasks, equals(2));
        expect(metrics.pendingTasks, equals(1));
      });

      test('completionRate is completedTasks / totalTasks', () {
        final engagements = [
          _makeEngagement(
            id: 'e-1',
            dueDate: DateTime(2025, 1, 15),
            templateTasks: [_makeTask('t1'), _makeTask('t2')],
            assignedStaff: [
              const StaffAssignment(
                staffId: 'staff-1',
                role: StaffRole.junior,
                tasks: ['t1'],
                hoursLogged: 2,
                hoursEstimated: 2,
              ),
            ],
          ),
        ];

        final metrics = aggregator.aggregateTasks(engagements, jan2025);

        expect(metrics.completionRate, closeTo(0.5, 0.001));
      });

      test('avgEstimatedHours is mean across all tasks', () {
        final engagements = [
          _makeEngagement(
            id: 'e-1',
            dueDate: DateTime(2025, 1, 15),
            templateTasks: [
              _makeTask('t1', estimatedHours: 2),
              _makeTask('t2', estimatedHours: 4),
            ],
          ),
        ];

        final metrics = aggregator.aggregateTasks(engagements, jan2025);

        expect(metrics.avgEstimatedHours, closeTo(3.0, 0.001));
      });
    });

    // -------------------------------------------------------------------------
    // buildSnapshot
    // -------------------------------------------------------------------------

    group('buildSnapshot', () {
      test('returns DashboardSnapshot with correct period', () {
        final snapshot = aggregator.buildSnapshot(
          jan2025,
          invoices: [],
          engagements: [],
        );

        expect(snapshot.period, equals(jan2025));
      });

      test('snapshot has billing, filing, and tasks metrics', () {
        final snapshot = aggregator.buildSnapshot(
          jan2025,
          invoices: [],
          engagements: [],
        );

        expect(snapshot.billing, isNotNull);
        expect(snapshot.filing, isNotNull);
        expect(snapshot.tasks, isNotNull);
      });

      test('empty data produces snapshot with all zero metrics', () {
        final snapshot = aggregator.buildSnapshot(
          jan2025,
          invoices: [],
          engagements: [],
        );

        expect(snapshot.billing.totalBilled, equals(0.0));
        expect(snapshot.filing.totalFilings, equals(0));
        expect(snapshot.tasks.totalTasks, equals(0));
      });

      test('two snapshots for different periods are independent', () {
        final feb2025 = DateRange(
          start: DateTime(2025, 2, 1),
          end: DateTime(2025, 2, 28),
        );

        final janInvoices = [
          _makeInvoice(
            id: 'jan-inv',
            dueDate: DateTime(2025, 1, 15),
            totalAmount: 100000,
          ),
        ];
        final febInvoices = [
          _makeInvoice(
            id: 'feb-inv',
            dueDate: DateTime(2025, 2, 15),
            totalAmount: 200000,
          ),
        ];

        final janSnapshot = aggregator.buildSnapshot(
          jan2025,
          invoices: janInvoices + febInvoices,
          engagements: [],
        );
        final febSnapshot = aggregator.buildSnapshot(
          feb2025,
          invoices: janInvoices + febInvoices,
          engagements: [],
        );

        expect(janSnapshot.billing.totalBilled, equals(100000.0));
        expect(febSnapshot.billing.totalBilled, equals(200000.0));
        expect(janSnapshot.period, isNot(equals(febSnapshot.period)));
      });
    });

    // -------------------------------------------------------------------------
    // DashboardSnapshot model
    // -------------------------------------------------------------------------

    group('DashboardSnapshot equality', () {
      test('snapshots for same period are equal', () {
        final a = aggregator.buildSnapshot(
          jan2025,
          invoices: [],
          engagements: [],
        );
        final b = aggregator.buildSnapshot(
          jan2025,
          invoices: [],
          engagements: [],
        );
        expect(a, equals(b));
      });
    });
  });
}
