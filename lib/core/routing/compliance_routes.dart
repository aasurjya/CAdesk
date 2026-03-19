import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/features/compliance/presentation/compliance_screen.dart';
import 'package:ca_app/features/assessment/presentation/assessment_screen.dart';
import 'package:ca_app/features/accounts/presentation/accounts_screen.dart';
import 'package:ca_app/features/mca/presentation/mca_screen.dart';
import 'package:ca_app/features/xbrl/presentation/xbrl_screen.dart';
import 'package:ca_app/features/cma/presentation/cma_screen.dart';
import 'package:ca_app/features/payroll/presentation/payroll_screen.dart';
import 'package:ca_app/features/payroll/presentation/payslip_detail_screen.dart';
import 'package:ca_app/features/payroll/presentation/statutory_detail_screen.dart';
import 'package:ca_app/features/accounts/presentation/balance_sheet_screen.dart';
import 'package:ca_app/features/accounts/presentation/pnl_screen.dart';
import 'package:ca_app/features/fema/presentation/fema_screen.dart';
import 'package:ca_app/features/sebi/presentation/sebi_screen.dart';
import 'package:ca_app/features/transfer_pricing/presentation/transfer_pricing_screen.dart';
import 'package:ca_app/features/crypto_vda/presentation/crypto_vda_screen.dart';
import 'package:ca_app/features/startup_compliance/presentation/startup_compliance_screen.dart';
import 'package:ca_app/features/llp_compliance/presentation/llp_compliance_screen.dart';
import 'package:ca_app/features/msme/presentation/msme_screen.dart';
import 'package:ca_app/features/advanced_audit/presentation/advanced_audit_screen.dart';
import 'package:ca_app/features/faceless_assessment/presentation/faceless_assessment_screen.dart';
import 'package:ca_app/features/notice_resolution/presentation/notice_resolution_screen.dart';
import 'package:ca_app/features/dsc_vault/presentation/dsc_vault_screen.dart';
import 'package:ca_app/features/nri_tax/presentation/nri_tax_screen.dart';
import 'package:ca_app/features/renewal_expiry/presentation/renewal_expiry_screen.dart';
import 'package:ca_app/features/tax_advisory/presentation/tax_advisory_screen.dart';
import 'package:ca_app/features/fee_leakage/presentation/fee_leakage_screen.dart';
import 'package:ca_app/features/assessment/presentation/assessment_detail_screen.dart';
import 'package:ca_app/features/mca/presentation/mca_filing_screen.dart';
import 'package:ca_app/features/xbrl/presentation/xbrl_generation_screen.dart';
import 'package:ca_app/features/cma/presentation/cma_projection_screen.dart';
import 'package:ca_app/features/compliance/presentation/compliance_detail_screen.dart';
import 'package:ca_app/features/notice_resolution/presentation/notice_detail_screen.dart';
import 'package:ca_app/features/faceless_assessment/presentation/hearing_screen.dart';
import 'package:ca_app/features/tax_advisory/presentation/advisory_detail_screen.dart';
import 'package:ca_app/features/advanced_audit/presentation/audit_engagement_screen.dart';
import 'package:ca_app/features/fee_leakage/presentation/leakage_analysis_screen.dart';
import 'package:ca_app/features/renewal_expiry/presentation/renewal_detail_screen.dart';
import 'package:ca_app/features/traces/presentation/traces_detail_screen.dart';
import 'package:ca_app/features/fema/presentation/fema_transaction_screen.dart';
import 'package:ca_app/features/sebi/presentation/sebi_filing_screen.dart';
import 'package:ca_app/features/transfer_pricing/presentation/tp_study_screen.dart';
import 'package:ca_app/features/crypto_vda/presentation/vda_tax_screen.dart';
import 'package:ca_app/features/startup_compliance/presentation/startup_detail_screen.dart';
import 'package:ca_app/features/llp_compliance/presentation/llp_detail_screen.dart';
import 'package:ca_app/features/msme/presentation/msme_detail_screen.dart';
import 'package:ca_app/features/litigation/presentation/case_detail_screen.dart';
import 'package:ca_app/features/dsc_vault/presentation/dsc_detail_screen.dart';
import 'package:ca_app/features/nri_tax/presentation/nri_computation_screen.dart';
import 'package:ca_app/features/mca/presentation/mca_api_status_screen.dart';

/// Returns all compliance and tax-related routes.
List<RouteBase> complianceRoutes(GlobalKey<NavigatorState> rootNavigatorKey) =>
    [
      GoRoute(
        path: '/compliance',
        name: 'compliance',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ComplianceScreen(),
      ),
      GoRoute(
        path: '/assessment',
        name: 'assessment',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AssessmentScreen(),
      ),
      GoRoute(
        path: '/accounts',
        name: 'accounts',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AccountsScreen(),
      ),
      GoRoute(
        path: '/mca',
        name: 'mca',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const McaScreen(),
      ),
      GoRoute(
        path: '/xbrl',
        name: 'xbrl',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const XbrlScreen(),
      ),
      GoRoute(
        path: '/cma',
        name: 'cma',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const CmaScreen(),
      ),
      GoRoute(
        path: '/payroll',
        name: 'payroll',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const PayrollScreen(),
      ),
      GoRoute(
        path: '/fema',
        name: 'fema',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const FemaScreen(),
      ),
      GoRoute(
        path: '/sebi',
        name: 'sebi',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SebiScreen(),
      ),
      GoRoute(
        path: '/transfer-pricing',
        name: 'transferPricing',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const TransferPricingScreen(),
      ),
      GoRoute(
        path: '/crypto-vda',
        name: 'cryptoVda',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const CryptoVdaScreen(),
      ),
      GoRoute(
        path: '/startup-compliance',
        name: 'startupCompliance',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const StartupComplianceScreen(),
      ),
      GoRoute(
        path: '/llp-compliance',
        name: 'llpCompliance',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const LLPComplianceScreen(),
      ),
      GoRoute(
        path: '/msme',
        name: 'msme',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const MsmeScreen(),
      ),
      GoRoute(
        path: '/advanced-audit',
        name: 'advancedAudit',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AdvancedAuditScreen(),
      ),
      GoRoute(
        path: '/faceless-assessment',
        name: 'facelessAssessment',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const FacelessAssessmentScreen(),
      ),
      GoRoute(
        path: '/notice-resolution',
        name: 'noticeResolution',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const NoticeResolutionScreen(),
      ),
      GoRoute(
        path: '/dsc-vault',
        name: 'dscVault',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const DscVaultScreen(),
      ),
      GoRoute(
        path: '/nri-tax',
        name: 'nriTax',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const NriTaxScreen(),
      ),
      GoRoute(
        path: '/renewal-expiry',
        name: 'renewalExpiry',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const RenewalExpiryScreen(),
      ),
      GoRoute(
        path: '/tax-advisory',
        name: 'taxAdvisory',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const TaxAdvisoryScreen(),
      ),
      GoRoute(
        path: '/fee-leakage',
        name: 'feeLeakage',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const FeeLeakageScreen(),
      ),
      GoRoute(
        path: '/payroll/payslip/:payslipId',
        name: 'payslipDetail',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final payslipId = state.pathParameters['payslipId']!;
          return PayslipDetailScreen(payslipId: payslipId);
        },
      ),
      GoRoute(
        path: '/payroll/statutory/:returnId',
        name: 'statutoryDetail',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final returnId = state.pathParameters['returnId']!;
          return StatutoryDetailScreen(returnId: returnId);
        },
      ),
      GoRoute(
        path: '/accounts/balance-sheet/:clientId',
        name: 'balanceSheet',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final clientId = state.pathParameters['clientId']!;
          return BalanceSheetScreen(clientId: clientId);
        },
      ),
      GoRoute(
        path: '/accounts/pnl/:clientId',
        name: 'pnlStatement',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final clientId = state.pathParameters['clientId']!;
          return PnlScreen(clientId: clientId);
        },
      ),
      GoRoute(
        path: '/assessment/detail/:orderId',
        name: 'assessmentDetail',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          return AssessmentDetailScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: '/mca/filing',
        name: 'mcaFiling',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const McaFilingScreen(),
      ),
      GoRoute(
        path: '/xbrl/generate',
        name: 'xbrlGenerate',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const XbrlGenerationScreen(),
      ),
      GoRoute(
        path: '/cma/projection',
        name: 'cmaProjection',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const CmaProjectionScreen(),
      ),
      GoRoute(
        path: '/compliance/detail/:deadlineId',
        name: 'complianceDetail',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final deadlineId = state.pathParameters['deadlineId']!;
          return ComplianceDetailScreen(deadlineId: deadlineId);
        },
      ),
      GoRoute(
        path: '/notice-resolution/detail/:noticeId',
        name: 'noticeDetail',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final noticeId = state.pathParameters['noticeId']!;
          return NoticeDetailScreen(noticeId: noticeId);
        },
      ),
      GoRoute(
        path: '/faceless-assessment/hearing/:hearingId',
        name: 'hearingDetail',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final hearingId = state.pathParameters['hearingId']!;
          return HearingScreen(hearingId: hearingId);
        },
      ),
      GoRoute(
        path: '/tax-advisory/detail/:advisoryId',
        name: 'advisoryDetail',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final advisoryId = state.pathParameters['advisoryId']!;
          return AdvisoryDetailScreen(advisoryId: advisoryId);
        },
      ),
      GoRoute(
        path: '/advanced-audit/engagement/:engagementId',
        name: 'auditEngagement',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final engagementId = state.pathParameters['engagementId']!;
          return AuditEngagementScreen(engagementId: engagementId);
        },
      ),
      GoRoute(
        path: '/fee-leakage/analysis',
        name: 'leakageAnalysis',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const LeakageAnalysisScreen(),
      ),
      GoRoute(
        path: '/renewal-expiry/detail/:renewalId',
        name: 'renewalDetail',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final renewalId = state.pathParameters['renewalId']!;
          return RenewalDetailScreen(renewalId: renewalId);
        },
      ),
      GoRoute(
        path: '/traces/detail/:panId',
        name: 'tracesDetail',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final panId = state.pathParameters['panId']!;
          return TracesDetailScreen(panId: panId);
        },
      ),
      GoRoute(
        path: '/fema/transaction/:transactionId',
        name: 'femaTransaction',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final transactionId = state.pathParameters['transactionId']!;
          return FemaTransactionScreen(transactionId: transactionId);
        },
      ),
      GoRoute(
        path: '/sebi/filing/:filingId',
        name: 'sebiFiling',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final filingId = state.pathParameters['filingId']!;
          return SebiFilingScreen(filingId: filingId);
        },
      ),
      GoRoute(
        path: '/transfer-pricing/study/:studyId',
        name: 'tpStudy',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final studyId = state.pathParameters['studyId']!;
          return TpStudyScreen(studyId: studyId);
        },
      ),
      GoRoute(
        path: '/crypto-vda/tax/:clientId',
        name: 'vdaTax',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final clientId = state.pathParameters['clientId']!;
          return VdaTaxScreen(clientId: clientId);
        },
      ),
      GoRoute(
        path: '/startup-compliance/detail/:startupId',
        name: 'startupDetail',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final startupId = state.pathParameters['startupId']!;
          return StartupDetailScreen(startupId: startupId);
        },
      ),
      GoRoute(
        path: '/llp-compliance/detail/:llpId',
        name: 'llpDetail',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final llpId = state.pathParameters['llpId']!;
          return LlpDetailScreen(llpId: llpId);
        },
      ),
      GoRoute(
        path: '/msme/detail/:msmeId',
        name: 'msmeDetail',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final msmeId = state.pathParameters['msmeId']!;
          return MsmeDetailScreen(msmeId: msmeId);
        },
      ),
      GoRoute(
        path: '/litigation/case/:caseId',
        name: 'caseDetail',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final caseId = state.pathParameters['caseId']!;
          return CaseDetailScreen(caseId: caseId);
        },
      ),
      GoRoute(
        path: '/dsc-vault/detail/:dscId',
        name: 'dscDetail',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final dscId = state.pathParameters['dscId']!;
          return DscDetailScreen(dscId: dscId);
        },
      ),
      GoRoute(
        path: '/nri-tax/computation/:clientId',
        name: 'nriComputation',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final clientId = state.pathParameters['clientId']!;
          return NriComputationScreen(clientId: clientId);
        },
      ),
      GoRoute(
        path: '/mca/api-status',
        name: 'mcaApiStatus',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const McaApiStatusScreen(),
      ),
    ];
