import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/analytics/domain/models/practice_metrics.dart';
import 'package:ca_app/features/analytics/domain/services/practice_analytics_service.dart';
import 'package:ca_app/features/practice/domain/models/billing_invoice.dart';
import 'package:ca_app/features/practice/domain/models/engagement.dart';
import 'package:ca_app/features/practice/domain/models/staff_assignment.dart';
import 'package:ca_app/features/practice/domain/models/workflow_task.dart';

BillingInvoice _makeInvoice({
  required String clientId,
  required int totalAmount,
  PaymentStatus paymentStatus = PaymentStatus.paid,
  DateTime? dueDate,
}) {
  return BillingInvoice(
    invoiceId: 'inv-${clientId.hashCode}',
    clientId: clientId,
    engagementId: 'eng-001',
    lineItems: const [],
    subtotal: totalAmount,
    gstAmount: 0,
    totalAmount: totalAmount,
    dueDate: dueDate ?? DateTime(2024, 12, 31),
    paymentStatus: paymentStatus,
  );
}

Engagement _makeEngagement({
  required String engagementId,
  required String clientId,
  EngagementStatus status = EngagementStatus.done,
  DateTime? dueDate,
  DateTime? completedDate,
  int billingAmount = 100000,
  List<StaffAssignment> assignedStaff = const [],
}) {
  return Engagement(
    engagementId: engagementId,
    clientId: clientId,
    templateId: 'tmpl-itr',
    templateTasks: const [],
    assignedStaff: assignedStaff,
    status: status,
    dueDate: dueDate ?? DateTime(2024, 7, 31),
    completedDate: completedDate,
    billingAmount: billingAmount,
  );
}

StaffAssignment _makeStaff({
  required String staffId,
  required int hoursLogged,
}) {
  return StaffAssignment(
    staffId: staffId,
    role: StaffRole.senior,
    tasks: const [],
    hoursLogged: hoursLogged,
    hoursEstimated: hoursLogged,
  );
}

void main() {
  final service = PracticeAnalyticsService.instance;

  // ---------------------------------------------------------------------------
  // computeRevenueGrowth
  // ---------------------------------------------------------------------------
  group('computeRevenueGrowth', () {
    test('returns positive growth when current > prior', () {
      final growth = service.computeRevenueGrowth(120000, 100000);
      expect(growth, closeTo(20.0, 0.001));
    });

    test('returns negative growth when current < prior', () {
      final growth = service.computeRevenueGrowth(80000, 100000);
      expect(growth, closeTo(-20.0, 0.001));
    });

    test('returns zero when no change', () {
      final growth = service.computeRevenueGrowth(100000, 100000);
      expect(growth, 0.0);
    });

    test('returns 0.0 when prior revenue is zero', () {
      final growth = service.computeRevenueGrowth(50000, 0);
      expect(growth, 0.0);
    });
  });

  // ---------------------------------------------------------------------------
  // computeFilingComplianceRate
  // ---------------------------------------------------------------------------
  group('computeFilingComplianceRate', () {
    test('returns 1.0 when all engagements completed before deadline', () {
      final engagements = [
        _makeEngagement(
          engagementId: 'e1',
          clientId: 'c1',
          dueDate: DateTime(2024, 7, 31),
          completedDate: DateTime(2024, 7, 28),
          status: EngagementStatus.done,
        ),
        _makeEngagement(
          engagementId: 'e2',
          clientId: 'c2',
          dueDate: DateTime(2024, 9, 30),
          completedDate: DateTime(2024, 9, 25),
          status: EngagementStatus.done,
        ),
      ];
      final rate = service.computeFilingComplianceRate(engagements);
      expect(rate, 1.0);
    });

    test('returns 0.5 when half completed on time', () {
      final engagements = [
        _makeEngagement(
          engagementId: 'e1',
          clientId: 'c1',
          dueDate: DateTime(2024, 7, 31),
          completedDate: DateTime(2024, 7, 28),
          status: EngagementStatus.done,
        ),
        _makeEngagement(
          engagementId: 'e2',
          clientId: 'c2',
          dueDate: DateTime(2024, 7, 31),
          completedDate: DateTime(2024, 8, 5),
          status: EngagementStatus.done,
        ),
      ];
      final rate = service.computeFilingComplianceRate(engagements);
      expect(rate, 0.5);
    });

    test('returns 0.0 for empty engagements', () {
      final rate = service.computeFilingComplianceRate([]);
      expect(rate, 0.0);
    });

    test('counts non-done engagements as non-compliant', () {
      final engagements = [
        _makeEngagement(
          engagementId: 'e1',
          clientId: 'c1',
          dueDate: DateTime(2024, 7, 31),
          completedDate: null,
          status: EngagementStatus.inProgress,
        ),
      ];
      final rate = service.computeFilingComplianceRate(engagements);
      expect(rate, 0.0);
    });
  });

  // ---------------------------------------------------------------------------
  // computeUtilizationRate
  // ---------------------------------------------------------------------------
  group('computeUtilizationRate', () {
    test('returns correct utilization when hours below capacity', () {
      final assignments = [
        _makeStaff(staffId: 's1', hoursLogged: 6),
        _makeStaff(staffId: 's2', hoursLogged: 4),
      ];
      final rate = service.computeUtilizationRate(assignments, 20);
      expect(rate, closeTo(0.5, 0.001));
    });

    test('returns 1.0 when billable hours equal total available', () {
      final assignments = [_makeStaff(staffId: 's1', hoursLogged: 10)];
      final rate = service.computeUtilizationRate(assignments, 10);
      expect(rate, 1.0);
    });

    test('clamps to 1.0 when over capacity', () {
      final assignments = [_makeStaff(staffId: 's1', hoursLogged: 15)];
      final rate = service.computeUtilizationRate(assignments, 10);
      expect(rate, 1.0);
    });

    test('returns 0.0 when total available hours is zero', () {
      final assignments = [_makeStaff(staffId: 's1', hoursLogged: 5)];
      final rate = service.computeUtilizationRate(assignments, 0);
      expect(rate, 0.0);
    });

    test('returns 0.0 for empty assignments', () {
      final rate = service.computeUtilizationRate([], 100);
      expect(rate, 0.0);
    });
  });

  // ---------------------------------------------------------------------------
  // computeMetrics
  // ---------------------------------------------------------------------------
  group('computeMetrics', () {
    test('computes aggregate practice metrics correctly', () {
      final invoices = [
        _makeInvoice(clientId: 'c1', totalAmount: 200000),
        _makeInvoice(clientId: 'c2', totalAmount: 300000),
        _makeInvoice(clientId: 'c3', totalAmount: 100000),
      ];
      final engagements = [
        _makeEngagement(
          engagementId: 'e1',
          clientId: 'c1',
          dueDate: DateTime(2024, 7, 31),
          completedDate: DateTime(2024, 7, 20),
          status: EngagementStatus.done,
          assignedStaff: [_makeStaff(staffId: 's1', hoursLogged: 4)],
        ),
        _makeEngagement(
          engagementId: 'e2',
          clientId: 'c2',
          dueDate: DateTime(2024, 9, 30),
          completedDate: DateTime(2024, 9, 28),
          status: EngagementStatus.done,
          assignedStaff: [_makeStaff(staffId: 's1', hoursLogged: 6)],
        ),
        _makeEngagement(
          engagementId: 'e3',
          clientId: 'c3',
          dueDate: DateTime(2024, 7, 31),
          completedDate: DateTime(2024, 8, 5),
          status: EngagementStatus.done,
          assignedStaff: [_makeStaff(staffId: 's2', hoursLogged: 5)],
        ),
      ];

      final metrics = service.computeMetrics(
        invoices,
        engagements,
        'FY2024-25',
        priorRevenue: 500000,
        firmId: 'firm-001',
        newClientsCount: 1,
        churnedClientsCount: 0,
        pendingFilings: 2,
        overdueFilings: 1,
        totalAvailableHours: 40,
      );

      expect(metrics.period, 'FY2024-25');
      expect(metrics.firmId, 'firm-001');
      expect(metrics.totalRevenue, 600000);
      expect(metrics.totalClients, 3);
      expect(metrics.newClients, 1);
      expect(metrics.churnedClients, 0);
      expect(metrics.avgRevenuePerClient, 200000);
      expect(metrics.filingComplianceRate, closeTo(2 / 3, 0.001));
      expect(metrics.pendingFilings, 2);
      expect(metrics.overdueFilings, 1);
      expect(metrics.revenueGrowth, closeTo(20.0, 0.001));
    });

    test('handles zero clients — avgRevenuePerClient is 0', () {
      final metrics = service.computeMetrics(
        [],
        [],
        'FY2024-25',
        priorRevenue: 0,
        firmId: 'firm-001',
        newClientsCount: 0,
        churnedClientsCount: 0,
        pendingFilings: 0,
        overdueFilings: 0,
        totalAvailableHours: 0,
      );
      expect(metrics.totalRevenue, 0);
      expect(metrics.avgRevenuePerClient, 0);
    });
  });

  // ---------------------------------------------------------------------------
  // PracticeMetrics model
  // ---------------------------------------------------------------------------
  group('PracticeMetrics', () {
    test('copyWith returns new instance with changed fields', () {
      const original = PracticeMetrics(
        period: 'FY2024-25',
        firmId: 'firm-001',
        totalRevenue: 500000,
        revenueGrowth: 10.0,
        totalClients: 5,
        newClients: 1,
        churnedClients: 0,
        filingComplianceRate: 0.8,
        pendingFilings: 2,
        overdueFilings: 1,
        utilizationRate: 0.7,
      );

      final updated = original.copyWith(totalClients: 10);

      expect(updated.totalClients, 10);
      expect(updated.firmId, original.firmId);
      expect(updated.totalRevenue, original.totalRevenue);
    });

    test('avgRevenuePerClient computed correctly', () {
      const metrics = PracticeMetrics(
        period: 'FY2024-25',
        firmId: 'firm-001',
        totalRevenue: 600000,
        revenueGrowth: 0.0,
        totalClients: 3,
        newClients: 0,
        churnedClients: 0,
        filingComplianceRate: 1.0,
        pendingFilings: 0,
        overdueFilings: 0,
        utilizationRate: 0.8,
      );
      expect(metrics.avgRevenuePerClient, 200000);
    });

    test('avgRevenuePerClient returns 0 when no clients', () {
      const metrics = PracticeMetrics(
        period: 'FY2024-25',
        firmId: 'firm-001',
        totalRevenue: 0,
        revenueGrowth: 0.0,
        totalClients: 0,
        newClients: 0,
        churnedClients: 0,
        filingComplianceRate: 0.0,
        pendingFilings: 0,
        overdueFilings: 0,
        utilizationRate: 0.0,
      );
      expect(metrics.avgRevenuePerClient, 0);
    });

    test('equality and hashCode', () {
      const a = PracticeMetrics(
        period: 'FY2024-25',
        firmId: 'firm-001',
        totalRevenue: 500000,
        revenueGrowth: 10.0,
        totalClients: 5,
        newClients: 1,
        churnedClients: 0,
        filingComplianceRate: 0.8,
        pendingFilings: 2,
        overdueFilings: 1,
        utilizationRate: 0.7,
      );
      const b = PracticeMetrics(
        period: 'FY2024-25',
        firmId: 'firm-001',
        totalRevenue: 500000,
        revenueGrowth: 10.0,
        totalClients: 5,
        newClients: 1,
        churnedClients: 0,
        filingComplianceRate: 0.8,
        pendingFilings: 2,
        overdueFilings: 1,
        utilizationRate: 0.7,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
