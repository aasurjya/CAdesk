import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/dashboard/data/mappers/dashboard_mapper.dart';

void main() {
  group('DashboardMapper', () {
    group('summaryFromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'total_clients': 55,
          'filed_returns': 230,
          'pending_returns': 12,
          'overdue_tasks': 3,
          'upcoming_deadlines': 8,
          'total_billing': 450000.0,
        };

        final summary = DashboardMapper.summaryFromJson(json);

        expect(summary.totalClients, 55);
        expect(summary.filedReturns, 230);
        expect(summary.pendingReturns, 12);
        expect(summary.overdueTasks, 3);
        expect(summary.upcomingDeadlines, 8);
        expect(summary.totalBilling, 450000.0);
      });

      test('handles null values with 0 defaults', () {
        final json = <String, dynamic>{
          'total_clients': null,
          'filed_returns': null,
          'pending_returns': null,
          'overdue_tasks': null,
          'upcoming_deadlines': null,
          'total_billing': null,
        };

        final summary = DashboardMapper.summaryFromJson(json);

        expect(summary.totalClients, 0);
        expect(summary.filedReturns, 0);
        expect(summary.pendingReturns, 0);
        expect(summary.overdueTasks, 0);
        expect(summary.upcomingDeadlines, 0);
        expect(summary.totalBilling, 0.0);
      });

      test('converts double integer values to int', () {
        final json = {
          'total_clients': 45.0,
          'filed_returns': 200.0,
          'pending_returns': 10.0,
          'overdue_tasks': 2.0,
          'upcoming_deadlines': 5.0,
          'total_billing': 300000.0,
        };

        final summary = DashboardMapper.summaryFromJson(json);
        expect(summary.totalClients, 45);
        expect(summary.totalClients, isA<int>());
      });

      test('converts integer total_billing to double', () {
        final json = {
          'total_clients': 10,
          'filed_returns': 50,
          'pending_returns': 5,
          'overdue_tasks': 1,
          'upcoming_deadlines': 3,
          'total_billing': 200000,
        };

        final summary = DashboardMapper.summaryFromJson(json);
        expect(summary.totalBilling, 200000.0);
        expect(summary.totalBilling, isA<double>());
      });

      test('handles string numeric values', () {
        final json = {
          'total_clients': '30',
          'filed_returns': '150',
          'pending_returns': '7',
          'overdue_tasks': '0',
          'upcoming_deadlines': '4',
          'total_billing': '250000.50',
        };

        final summary = DashboardMapper.summaryFromJson(json);
        expect(summary.totalClients, 30);
        expect(summary.filedReturns, 150);
        expect(summary.totalBilling, 250000.50);
      });

      test('handles all zero values for new firm', () {
        final json = {
          'total_clients': 0,
          'filed_returns': 0,
          'pending_returns': 0,
          'overdue_tasks': 0,
          'upcoming_deadlines': 0,
          'total_billing': 0.0,
        };

        final summary = DashboardMapper.summaryFromJson(json);
        expect(summary.totalClients, 0);
        expect(summary.totalBilling, 0.0);
      });
    });

    group('recentFilingFromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'client_name': 'Ramesh Kumar',
          'filing_type': 'ITR-1',
          'status': 'Accepted',
          'date': '2025-07-31T00:00:00.000Z',
        };

        final filing = DashboardMapper.recentFilingFromJson(json);

        expect(filing.clientName, 'Ramesh Kumar');
        expect(filing.filingType, 'ITR-1');
        expect(filing.status, 'Accepted');
        expect(filing.date.year, 2025);
        expect(filing.date.month, 7);
        expect(filing.date.day, 31);
      });

      test('handles null fields with empty string defaults', () {
        final json = <String, dynamic>{};

        final filing = DashboardMapper.recentFilingFromJson(json);
        expect(filing.clientName, '');
        expect(filing.filingType, '');
        expect(filing.status, '');
        expect(filing.date, isA<DateTime>());
      });
    });

    group('topClientFromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'client_name': 'ABC Industries',
          'filing_count': 18,
          'billing_amount': 120000.0,
        };

        final client = DashboardMapper.topClientFromJson(json);

        expect(client.clientName, 'ABC Industries');
        expect(client.filingCount, 18);
        expect(client.billingAmount, 120000.0);
      });

      test('handles null fields with defaults', () {
        final json = <String, dynamic>{};

        final client = DashboardMapper.topClientFromJson(json);
        expect(client.clientName, '');
        expect(client.filingCount, 0);
        expect(client.billingAmount, 0.0);
      });

      test('converts integer billing_amount to double', () {
        final json = {
          'client_name': 'XYZ Corp',
          'filing_count': 12,
          'billing_amount': 80000,
        };

        final client = DashboardMapper.topClientFromJson(json);
        expect(client.billingAmount, 80000.0);
        expect(client.billingAmount, isA<double>());
      });
    });
  });
}
