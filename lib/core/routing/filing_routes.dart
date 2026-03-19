import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/features/filing/presentation/filing_type_picker_screen.dart';
import 'package:ca_app/features/filing/presentation/itr1/itr1_wizard_screen.dart';
import 'package:ca_app/features/filing/presentation/itr2/itr2_wizard_screen.dart';
import 'package:ca_app/features/filing/presentation/itr4/itr4_wizard_screen.dart';
import 'package:ca_app/features/filing/presentation/post_filing/filing_status_screen.dart';
import 'package:ca_app/features/filing/presentation/post_filing/e_verification_screen.dart';
import 'package:ca_app/features/filing/presentation/bulk/filing_queue_screen.dart';
import 'package:ca_app/features/filing/presentation/reconciliation/reconciliation_screen.dart';
import 'package:ca_app/features/filing/presentation/analytics/filing_analytics_screen.dart';
import 'package:ca_app/features/filing/presentation/itr_u/itr_u_screen.dart';
import 'package:ca_app/features/filing/presentation/advance_tax/advance_tax_screen.dart';
import 'package:ca_app/features/filing/presentation/advance_tax/advance_tax_calculator_screen.dart';
import 'package:ca_app/features/income_tax/presentation/income_tax_screen.dart';
import 'package:ca_app/features/gst/presentation/gst_screen.dart';
import 'package:ca_app/features/gst/presentation/gstr1/gstr1_wizard_screen.dart';
import 'package:ca_app/features/gst/presentation/gstr3b/gstr3b_wizard_screen.dart';
import 'package:ca_app/features/tds/presentation/tds_screen.dart';
import 'package:ca_app/features/tds/presentation/fvu/fvu_generation_screen.dart';
import 'package:ca_app/features/einvoicing/presentation/einvoicing_screen.dart';
import 'package:ca_app/features/einvoicing/presentation/einvoice_detail_screen.dart';
import 'package:ca_app/features/einvoicing/presentation/einvoice_form_screen.dart';
import 'package:ca_app/features/filing/presentation/post_filing/e_verify_flow_screen.dart';
import 'package:ca_app/features/filing/presentation/post_filing/filing_tracker_screen.dart';

/// Returns all filing and tax-return related routes.
List<RouteBase> filingRoutes(GlobalKey<NavigatorState> rootNavigatorKey) => [
  GoRoute(
    path: '/filing/new',
    name: 'filingNew',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const FilingTypePickerScreen(),
  ),
  GoRoute(
    path: '/filing/itr1/:jobId',
    name: 'itr1Wizard',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) {
      final jobId = state.pathParameters['jobId']!;
      return Itr1WizardScreen(jobId: jobId);
    },
  ),
  GoRoute(
    path: '/filing/itr2/:jobId',
    name: 'itr2Wizard',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) {
      final jobId = state.pathParameters['jobId']!;
      return Itr2WizardScreen(jobId: jobId);
    },
  ),
  GoRoute(
    path: '/filing/itr4/:jobId',
    name: 'itr4Wizard',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) {
      final jobId = state.pathParameters['jobId']!;
      return Itr4WizardScreen(jobId: jobId);
    },
  ),
  GoRoute(
    path: '/filing/status/:jobId',
    name: 'filingStatus',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) {
      final jobId = state.pathParameters['jobId']!;
      return FilingStatusScreen(jobId: jobId);
    },
  ),
  GoRoute(
    path: '/filing/e-verify/:jobId',
    name: 'eVerification',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) {
      final jobId = state.pathParameters['jobId']!;
      return EVerificationScreen(jobId: jobId);
    },
  ),
  GoRoute(
    path: '/filing/queue',
    name: 'filingQueue',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const FilingQueueScreen(),
  ),
  GoRoute(
    path: '/filing/reconciliation',
    name: 'reconciliation',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const ReconciliationScreen(),
  ),
  GoRoute(
    path: '/filing/analytics',
    name: 'filingAnalytics',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const FilingAnalyticsScreen(),
  ),
  GoRoute(
    path: '/filing/itr-u',
    name: 'itrU',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const ItrUScreen(),
  ),
  GoRoute(
    path: '/filing/advance-tax',
    name: 'advanceTax',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const AdvanceTaxScreen(),
  ),
  GoRoute(
    path: '/filing/advance-tax-calculator',
    name: 'advanceTaxCalculator',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const AdvanceTaxCalculatorScreen(),
  ),
  GoRoute(
    path: '/income-tax',
    name: 'incomeTax',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const IncomeTaxScreen(),
  ),
  GoRoute(
    path: '/gst',
    name: 'gst',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const GstScreen(),
  ),
  GoRoute(
    path: '/gst/gstr1-wizard',
    name: 'gstr1Wizard',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const Gstr1WizardScreen(),
  ),
  GoRoute(
    path: '/gst/gstr3b-wizard',
    name: 'gstr3bWizard',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const Gstr3bWizardScreen(),
  ),
  GoRoute(
    path: '/tds',
    name: 'tds',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const TdsScreen(),
  ),
  GoRoute(
    path: '/tds/fvu-generation',
    name: 'fvuGeneration',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const FvuGenerationScreen(),
  ),
  GoRoute(
    path: '/einvoicing',
    name: 'einvoicing',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const EinvoicingScreen(),
  ),
  GoRoute(
    path: '/einvoicing/detail/:invoiceId',
    name: 'einvoiceDetail',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) {
      final invoiceId = state.pathParameters['invoiceId']!;
      return EinvoiceDetailScreen(invoiceId: invoiceId);
    },
  ),
  GoRoute(
    path: '/einvoicing/new',
    name: 'einvoiceNew',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const EinvoiceFormScreen(),
  ),
  GoRoute(
    path: '/einvoicing/edit/:invoiceId',
    name: 'einvoiceEdit',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) {
      final invoiceId = state.pathParameters['invoiceId']!;
      return EinvoiceFormScreen(invoiceId: invoiceId);
    },
  ),
  GoRoute(
    path: '/filing/e-verify-flow/:jobId',
    name: 'eVerifyFlow',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) {
      final jobId = state.pathParameters['jobId']!;
      return EVerifyFlowScreen(jobId: jobId);
    },
  ),
  GoRoute(
    path: '/filing/tracker',
    name: 'filingTracker',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const FilingTrackerScreen(),
  ),
];
