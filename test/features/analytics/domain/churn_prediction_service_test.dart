import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/analytics/domain/models/client_health_score.dart';
import 'package:ca_app/features/analytics/domain/services/churn_prediction_service.dart';
import 'package:ca_app/features/clients/domain/models/client.dart';
import 'package:ca_app/features/clients/domain/models/client_type.dart';
import 'package:ca_app/features/practice/domain/models/billing_invoice.dart';
import 'package:ca_app/features/practice/domain/models/engagement.dart';
import 'package:ca_app/features/practice/domain/models/staff_assignment.dart';
import 'package:ca_app/features/practice/domain/models/workflow_task.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Client _makeClient({
  String id = 'c1',
  String pan = 'ABCDE1234F',
  ClientStatus status = ClientStatus.active,
  DateTime? createdAt,
  List<ServiceType> servicesAvailed = const [ServiceType.itrFiling],
}) {
  final now = DateTime(2025, 3, 1);
  return Client(
    id: id,
    name: 'Test Client',
    pan: pan,
    clientType: ClientType.individual,
    status: status,
    createdAt: createdAt ?? DateTime(2020, 1, 1),
    updatedAt: now,
    servicesAvailed: servicesAvailed,
  );
}

Engagement _makeEngagement({
  required String engagementId,
  required String clientId,
  EngagementStatus status = EngagementStatus.done,
  DateTime? completedDate,
  DateTime? dueDate,
}) {
  return Engagement(
    engagementId: engagementId,
    clientId: clientId,
    templateId: 'tmpl-itr',
    templateTasks: const [],
    assignedStaff: const [],
    status: status,
    dueDate: dueDate ?? DateTime(2024, 7, 31),
    completedDate: completedDate,
    billingAmount: 100000,
  );
}

BillingInvoice _makeInvoice({
  required String clientId,
  required int totalAmount,
  PaymentStatus paymentStatus = PaymentStatus.paid,
  DateTime? dueDate,
}) {
  return BillingInvoice(
    invoiceId: 'inv-${clientId.hashCode}-${totalAmount.hashCode}',
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

void main() {
  final service = ChurnPredictionService.instance;
  final now = DateTime(2025, 3, 1);

  // ---------------------------------------------------------------------------
  // predictChurnRisk
  // ---------------------------------------------------------------------------
  group('predictChurnRisk', () {
    test('returns low for score 70–100', () {
      const score = ClientHealthScore(
        clientPan: 'ABCDE1234F',
        score: 85.0,
        churnRisk: ChurnRisk.low,
        riskFactors: [],
        lastServiceDate: null,
        lastPaymentDate: null,
        outstandingAmount: 0,
        engagementCount: 5,
        recommendation: '',
      );
      expect(service.predictChurnRisk(score), ChurnRisk.low);
    });

    test('returns medium for score 40–69', () {
      const score = ClientHealthScore(
        clientPan: 'ABCDE1234F',
        score: 55.0,
        churnRisk: ChurnRisk.medium,
        riskFactors: [],
        lastServiceDate: null,
        lastPaymentDate: null,
        outstandingAmount: 0,
        engagementCount: 2,
        recommendation: '',
      );
      expect(service.predictChurnRisk(score), ChurnRisk.medium);
    });

    test('returns high for score 20–39', () {
      const score = ClientHealthScore(
        clientPan: 'ABCDE1234F',
        score: 30.0,
        churnRisk: ChurnRisk.high,
        riskFactors: [],
        lastServiceDate: null,
        lastPaymentDate: null,
        outstandingAmount: 0,
        engagementCount: 1,
        recommendation: '',
      );
      expect(service.predictChurnRisk(score), ChurnRisk.high);
    });

    test('returns critical for score 0–19', () {
      const score = ClientHealthScore(
        clientPan: 'ABCDE1234F',
        score: 10.0,
        churnRisk: ChurnRisk.critical,
        riskFactors: [],
        lastServiceDate: null,
        lastPaymentDate: null,
        outstandingAmount: 0,
        engagementCount: 0,
        recommendation: '',
      );
      expect(service.predictChurnRisk(score), ChurnRisk.critical);
    });

    test('boundary: score exactly 70 is low', () {
      const score = ClientHealthScore(
        clientPan: 'ABCDE1234F',
        score: 70.0,
        churnRisk: ChurnRisk.low,
        riskFactors: [],
        lastServiceDate: null,
        lastPaymentDate: null,
        outstandingAmount: 0,
        engagementCount: 3,
        recommendation: '',
      );
      expect(service.predictChurnRisk(score), ChurnRisk.low);
    });

    test('boundary: score exactly 40 is medium', () {
      const score = ClientHealthScore(
        clientPan: 'ABCDE1234F',
        score: 40.0,
        churnRisk: ChurnRisk.medium,
        riskFactors: [],
        lastServiceDate: null,
        lastPaymentDate: null,
        outstandingAmount: 0,
        engagementCount: 2,
        recommendation: '',
      );
      expect(service.predictChurnRisk(score), ChurnRisk.medium);
    });
  });

  // ---------------------------------------------------------------------------
  // scoreClient — rule-based scoring
  // ---------------------------------------------------------------------------
  group('scoreClient', () {
    test('healthy client starts near base score 70', () {
      final client = _makeClient(
        servicesAvailed: [ServiceType.itrFiling, ServiceType.gstFiling],
        createdAt: DateTime(2020, 1, 1),
      );
      final history = [
        _makeEngagement(
          engagementId: 'e1',
          clientId: 'c1',
          completedDate: now.subtract(const Duration(days: 30)),
        ),
        _makeEngagement(
          engagementId: 'e2',
          clientId: 'c1',
          completedDate: now.subtract(const Duration(days: 60)),
        ),
      ];
      final invoices = [
        _makeInvoice(clientId: 'c1', totalAmount: 100000),
      ];

      final result = service.scoreClient(client, history, invoices, now: now);

      expect(result.clientPan, client.pan);
      expect(result.score, greaterThanOrEqualTo(0.0));
      expect(result.score, lessThanOrEqualTo(100.0));
    });

    test('deducts 30 points for no engagement in 6+ months', () {
      final client = _makeClient(createdAt: DateTime(2018, 1, 1));
      final history = [
        _makeEngagement(
          engagementId: 'e1',
          clientId: 'c1',
          completedDate: now.subtract(const Duration(days: 200)),
        ),
      ];
      final invoices = <BillingInvoice>[];

      final result = service.scoreClient(client, history, invoices, now: now);
      expect(result.riskFactors, contains('No engagement in 6+ months'));
      // Base 70 - 30 = 40, clamped [0, 100]
      expect(result.score, lessThanOrEqualTo(70.0));
    });

    test('deducts 20 points for outstanding invoice > 90 days', () {
      final client = _makeClient(createdAt: DateTime(2018, 1, 1));
      final history = [
        _makeEngagement(
          engagementId: 'e1',
          clientId: 'c1',
          completedDate: now.subtract(const Duration(days: 10)),
        ),
      ];
      final invoices = [
        _makeInvoice(
          clientId: 'c1',
          totalAmount: 50000,
          paymentStatus: PaymentStatus.overdue,
          dueDate: now.subtract(const Duration(days: 95)),
        ),
      ];

      final result = service.scoreClient(client, history, invoices, now: now);
      expect(result.riskFactors, contains('Outstanding invoice > 90 days'));
    });

    test('deducts 10 points for only 1 service type', () {
      final client = _makeClient(
        servicesAvailed: [ServiceType.itrFiling],
        createdAt: DateTime(2018, 1, 1),
      );
      final history = [
        _makeEngagement(
          engagementId: 'e1',
          clientId: 'c1',
          completedDate: now.subtract(const Duration(days: 10)),
        ),
      ];
      final invoices = <BillingInvoice>[];

      final result = service.scoreClient(client, history, invoices, now: now);
      expect(result.riskFactors, contains('Only 1 service type'));
    });

    test('adds 15 points for multiple services', () {
      final client = _makeClient(
        servicesAvailed: [ServiceType.itrFiling, ServiceType.gstFiling],
        createdAt: DateTime(2018, 1, 1),
      );
      final history = [
        _makeEngagement(
          engagementId: 'e1',
          clientId: 'c1',
          completedDate: now.subtract(const Duration(days: 10)),
        ),
        _makeEngagement(
          engagementId: 'e2',
          clientId: 'c1',
          completedDate: now.subtract(const Duration(days: 20)),
        ),
      ];
      final invoices = <BillingInvoice>[];

      final multiResult = service.scoreClient(
        client,
        history,
        invoices,
        now: now,
      );

      final singleClient = _makeClient(
        servicesAvailed: [ServiceType.itrFiling],
        createdAt: DateTime(2018, 1, 1),
      );
      final singleResult = service.scoreClient(
        singleClient,
        history,
        invoices,
        now: now,
      );

      // Multiple services adds 15, single deducts 10 → net 25 pts difference
      expect(
        multiResult.score,
        greaterThan(singleResult.score),
      );
    });

    test('adds 10 points for new client (< 6 months)', () {
      final client = _makeClient(
        createdAt: now.subtract(const Duration(days: 90)),
        servicesAvailed: [ServiceType.itrFiling],
      );
      final history = [
        _makeEngagement(
          engagementId: 'e1',
          clientId: 'c1',
          completedDate: now.subtract(const Duration(days: 10)),
        ),
      ];
      final invoices = <BillingInvoice>[];

      final result = service.scoreClient(client, history, invoices, now: now);
      expect(result.riskFactors, isNot(contains('New client')));
      // New client gets +10 bonus
      expect(result.score, greaterThanOrEqualTo(0));
    });

    test('score is clamped between 0 and 100', () {
      // A client with all negative factors to test lower clamp
      final client = _makeClient(
        servicesAvailed: [ServiceType.itrFiling],
        createdAt: DateTime(2018, 1, 1),
      );
      final history = [
        _makeEngagement(
          engagementId: 'e1',
          clientId: 'c1',
          completedDate: now.subtract(const Duration(days: 300)),
        ),
      ];
      final invoices = [
        _makeInvoice(
          clientId: 'c1',
          totalAmount: 50000,
          paymentStatus: PaymentStatus.overdue,
          dueDate: now.subtract(const Duration(days: 100)),
        ),
      ];

      final result = service.scoreClient(client, history, invoices, now: now);
      expect(result.score, greaterThanOrEqualTo(0.0));
      expect(result.score, lessThanOrEqualTo(100.0));
    });

    test('engagementCount reflects past 12-month engagements only', () {
      final client = _makeClient(createdAt: DateTime(2018, 1, 1));
      final history = [
        _makeEngagement(
          engagementId: 'e1',
          clientId: 'c1',
          completedDate: now.subtract(const Duration(days: 30)),
        ),
        _makeEngagement(
          engagementId: 'e2',
          clientId: 'c1',
          completedDate: now.subtract(const Duration(days: 400)),
        ),
      ];
      final invoices = <BillingInvoice>[];

      final result = service.scoreClient(client, history, invoices, now: now);
      expect(result.engagementCount, 1);
    });

    test('recommendation is non-empty string', () {
      final client = _makeClient();
      final result = service.scoreClient(client, [], [], now: now);
      expect(result.recommendation, isNotEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // ClientHealthScore model
  // ---------------------------------------------------------------------------
  group('ClientHealthScore', () {
    test('copyWith returns new instance with changed fields', () {
      const original = ClientHealthScore(
        clientPan: 'ABCDE1234F',
        score: 70.0,
        churnRisk: ChurnRisk.low,
        riskFactors: [],
        lastServiceDate: null,
        lastPaymentDate: null,
        outstandingAmount: 0,
        engagementCount: 5,
        recommendation: 'All good',
      );

      final updated = original.copyWith(score: 45.0, churnRisk: ChurnRisk.medium);
      expect(updated.score, 45.0);
      expect(updated.churnRisk, ChurnRisk.medium);
      expect(updated.clientPan, original.clientPan);
    });

    test('equality and hashCode', () {
      final date = DateTime(2024, 6, 1);
      final a = ClientHealthScore(
        clientPan: 'ABCDE1234F',
        score: 75.0,
        churnRisk: ChurnRisk.low,
        riskFactors: const ['factor1'],
        lastServiceDate: date,
        lastPaymentDate: null,
        outstandingAmount: 0,
        engagementCount: 3,
        recommendation: 'Good',
      );
      final b = ClientHealthScore(
        clientPan: 'ABCDE1234F',
        score: 75.0,
        churnRisk: ChurnRisk.low,
        riskFactors: const ['factor1'],
        lastServiceDate: date,
        lastPaymentDate: null,
        outstandingAmount: 0,
        engagementCount: 3,
        recommendation: 'Good',
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
