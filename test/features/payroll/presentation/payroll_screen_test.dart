import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/payroll/presentation/payroll_screen.dart';
import 'package:ca_app/features/payroll/presentation/widgets/employee_tile.dart';
import 'package:ca_app/features/payroll/presentation/widgets/payroll_summary_widget.dart';
import 'package:ca_app/features/payroll/presentation/widgets/statutory_return_tile.dart';
import 'package:ca_app/features/payroll/domain/models/employee.dart';
import 'package:ca_app/features/payroll/domain/models/statutory_return.dart';

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

/// Wide enough to avoid overflow in summary rows (payroll has many stacked rows).
Future<void> _setPhoneDisplay(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(600, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Widget _buildScreen() {
  return const ProviderScope(child: MaterialApp(home: PayrollScreen()));
}

// ---------------------------------------------------------------------------
// Sample data
// ---------------------------------------------------------------------------

final _testEmployee = Employee(
  id: 'emp-001',
  employeeCode: 'EMP-001',
  name: 'Amit Sharma',
  designation: 'Software Engineer',
  department: 'Engineering',
  joiningDate: DateTime(2022, 1, 15),
  basicSalary: 30000,
  hra: 12000,
  da: 0,
  conveyance: 1600,
  medicalAllowance: 1250,
  specialAllowance: 5150,
  grossSalary: 50000,
  pfContribution: 1800,
  esiContribution: 0,
  tdsMonthly: 2500,
  netSalary: 45700,
  pfNumber: 'MH/12345/12345',
  esiNumber: 'N/A',
  bankAccount: '12345678901234',
  ifscCode: 'HDFC0001234',
  pan: 'ABCPA1234D',
  isActive: true,
  leaveBalance: const {'CL': 8, 'PL': 12, 'SL': 4},
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('PayrollScreen', () {
    testWidgets('renders app bar with Payroll title', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Payroll'), findsOneWidget);
    });

    testWidgets('renders Employees tab label', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Employees'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders Monthly Payroll tab label', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Monthly Payroll'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders Statutory Returns tab label', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Statutory Returns'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders summary tiles with Employees label', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Employees'), findsWidgets);
    });

    testWidgets('renders Gross Payout summary label', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Gross Payout'), findsWidgets);
    });

    testWidgets('renders Net Payout summary label', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Net Payout'), findsWidgets);
    });

    testWidgets('renders period selector with calendar icon', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.calendar_month_rounded), findsOneWidget);
      expect(find.textContaining('Payroll Period:'), findsOneWidget);
    });

    testWidgets('renders PayrollSummaryWidget', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(PayrollSummaryWidget), findsOneWidget);
    });

    testWidgets('renders Run Payroll FAB', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Run Payroll'), findsOneWidget);
    });

    testWidgets('renders employee tiles in Employees tab', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(EmployeeTile), findsWidgets);
    });

    testWidgets('switching to Statutory Returns tab shows returns', (
      tester,
    ) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Statutory Returns'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(StatutoryReturnTile), findsWidgets);
    });

    testWidgets('switching to Monthly Payroll tab shows payroll records', (
      tester,
    ) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Monthly Payroll'),
        ),
      );
      await tester.pumpAndSettle();

      // Monthly payroll tab shows records or status chips
      expect(find.byType(ListView), findsWidgets);
    });
  });

  group('EmployeeTile', () {
    testWidgets('renders employee name', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: EmployeeTile(employee: _testEmployee)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Amit Sharma'), findsOneWidget);
    });

    testWidgets('renders designation and department', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: EmployeeTile(employee: _testEmployee)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Software Engineer'), findsOneWidget);
      expect(find.textContaining('Engineering'), findsWidgets);
    });

    testWidgets('renders Gross salary chip', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: EmployeeTile(employee: _testEmployee)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Gross'), findsOneWidget);
    });

    testWidgets('renders Net salary chip', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: EmployeeTile(employee: _testEmployee)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Net'), findsWidgets);
    });

    testWidgets('renders PF number', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: EmployeeTile(employee: _testEmployee)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('MH/12345'), findsOneWidget);
    });

    testWidgets('fires onTap callback', (tester) async {
      await _setPhoneDisplay(tester);
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmployeeTile(
              employee: _testEmployee,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(EmployeeTile));
      expect(tapped, isTrue);
    });

    testWidgets('renders Inactive badge for inactive employee', (tester) async {
      await _setPhoneDisplay(tester);
      final inactiveEmployee = Employee(
        id: 'emp-x01',
        employeeCode: 'EMP-X01',
        name: 'Former Employee',
        designation: 'Analyst',
        department: 'Finance',
        joiningDate: DateTime(2020, 3, 1),
        basicSalary: 20000,
        hra: 8000,
        da: 0,
        conveyance: 1600,
        medicalAllowance: 1250,
        specialAllowance: 2150,
        grossSalary: 33000,
        pfContribution: 1800,
        esiContribution: 0,
        tdsMonthly: 0,
        netSalary: 31200,
        pfNumber: 'MH/99999/99999',
        esiNumber: 'N/A',
        bankAccount: '99887766554433',
        ifscCode: 'SBIN0001234',
        pan: 'ZZZZZ9999Z',
        isActive: false,
        leaveBalance: const {},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: EmployeeTile(employee: inactiveEmployee)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Inactive'), findsOneWidget);
    });
  });

  group('StatutoryReturnTile', () {
    final testReturn = StatutoryReturn(
      id: 'sr-001',
      returnType: StatutoryReturnType.pfEcr,
      period: 'Feb 2026',
      dueDate: DateTime.utc(2026, 3, 15),
      status: StatutoryReturnStatus.pending,
      totalEmployees: 25,
      totalContribution: 85000,
    );

    testWidgets('renders return type label', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: StatutoryReturnTile(returnRecord: testReturn)),
        ),
      );
      await tester.pumpAndSettle();

      // PF ECR label should appear
      expect(find.textContaining('PF'), findsWidgets);
    });

    testWidgets('renders due date', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: StatutoryReturnTile(returnRecord: testReturn)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Mar'), findsWidgets);
    });
  });
}
