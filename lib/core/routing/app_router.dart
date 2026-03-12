import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/widgets/adaptive_scaffold.dart';
import 'package:ca_app/features/filing/presentation/filing_screen.dart';
import 'package:ca_app/features/today/presentation/today_screen.dart';
import 'package:ca_app/features/dashboard/presentation/dashboard_screen.dart';
import 'package:ca_app/features/clients/presentation/clients_screen.dart';
import 'package:ca_app/features/clients/presentation/client_detail_screen.dart';
import 'package:ca_app/features/compliance/presentation/compliance_screen.dart';
import 'package:ca_app/features/tasks/presentation/tasks_screen.dart';
import 'package:ca_app/features/more/presentation/more_screen.dart';
import 'package:ca_app/features/client_portal/presentation/client_portal_screen.dart';
import 'package:ca_app/features/ai_automation/presentation/ai_dashboard_screen.dart';
import 'package:ca_app/features/analytics/presentation/analytics_dashboard_screen.dart';
import 'package:ca_app/features/time_tracking/presentation/time_tracking_screen.dart';
import 'package:ca_app/features/firm_operations/presentation/firm_operations_screen.dart';
import 'package:ca_app/features/onboarding/presentation/onboarding_screen.dart';
import 'package:ca_app/features/fema/presentation/fema_screen.dart';
import 'package:ca_app/features/sebi/presentation/sebi_screen.dart';
import 'package:ca_app/features/transfer_pricing/presentation/transfer_pricing_screen.dart';
import 'package:ca_app/features/crypto_vda/presentation/crypto_vda_screen.dart';
import 'package:ca_app/features/startup_compliance/presentation/startup_compliance_screen.dart';
import 'package:ca_app/features/llp_compliance/presentation/llp_compliance_screen.dart';
import 'package:ca_app/features/msme/presentation/msme_screen.dart';
import 'package:ca_app/features/advanced_audit/presentation/advanced_audit_screen.dart';
import 'package:ca_app/features/faceless_assessment/presentation/faceless_assessment_screen.dart';
import 'package:ca_app/features/income_tax/presentation/income_tax_screen.dart';
import 'package:ca_app/features/gst/presentation/gst_screen.dart';
import 'package:ca_app/features/tds/presentation/tds_screen.dart';
import 'package:ca_app/features/mca/presentation/mca_screen.dart';
import 'package:ca_app/features/xbrl/presentation/xbrl_screen.dart';
import 'package:ca_app/features/cma/presentation/cma_screen.dart';
import 'package:ca_app/features/payroll/presentation/payroll_screen.dart';
import 'package:ca_app/features/staff_monitoring/presentation/staff_monitoring_screen.dart';
import 'package:ca_app/features/settings/presentation/settings_screen.dart';
import 'package:ca_app/features/accounts/presentation/accounts_screen.dart';
import 'package:ca_app/features/assessment/presentation/assessment_screen.dart';
import 'package:ca_app/features/documents/presentation/documents_screen.dart';
import 'package:ca_app/features/billing/presentation/billing_screen.dart';
import 'package:ca_app/features/regulatory_trust/presentation/regulatory_trust_screen.dart';
import 'package:ca_app/features/data_pipelines/presentation/data_pipelines_screen.dart';
import 'package:ca_app/features/collaboration/presentation/collaboration_screen.dart';
import 'package:ca_app/features/ecosystem/presentation/ecosystem_screen.dart';
import 'package:ca_app/features/roadmap_modules/presentation/roadmap_module_screen.dart';
import 'package:ca_app/features/notice_resolution/presentation/notice_resolution_screen.dart';
import 'package:ca_app/features/dsc_vault/presentation/dsc_vault_screen.dart';
import 'package:ca_app/features/renewal_expiry/presentation/renewal_expiry_screen.dart';
import 'package:ca_app/features/tax_advisory/presentation/tax_advisory_screen.dart';
import 'package:ca_app/features/lead_funnel/presentation/lead_funnel_screen.dart';
import 'package:ca_app/features/nri_tax/presentation/nri_tax_screen.dart';
import 'package:ca_app/features/sme_cfo/presentation/sme_cfo_screen.dart';
import 'package:ca_app/features/fee_leakage/presentation/fee_leakage_screen.dart';
import 'package:ca_app/features/knowledge_engine/presentation/knowledge_engine_screen.dart';
import 'package:ca_app/features/industry_playbooks/presentation/industry_playbooks_screen.dart';
import 'package:ca_app/features/esg_reporting/presentation/esg_reporting_screen.dart';
import 'package:ca_app/features/virtual_cfo/presentation/virtual_cfo_screen.dart';
import 'package:ca_app/features/einvoicing/presentation/einvoicing_screen.dart';
import 'package:ca_app/features/idp/presentation/idp_screen.dart';
import 'package:ca_app/features/regulatory_intelligence/presentation/regulatory_intelligence_screen.dart';
import 'package:ca_app/features/practice_benchmarking/presentation/practice_benchmarking_screen.dart';
import 'package:ca_app/features/ca_gpt/presentation/ca_gpt_home_screen.dart';
import 'package:ca_app/features/filing/presentation/filing_type_picker_screen.dart';
import 'package:ca_app/features/filing/presentation/itr1/itr1_wizard_screen.dart';
import 'package:ca_app/features/filing/presentation/itr4/itr4_wizard_screen.dart';
import 'package:ca_app/features/filing/presentation/post_filing/filing_status_screen.dart';
import 'package:ca_app/features/filing/presentation/post_filing/e_verification_screen.dart';
import 'package:ca_app/features/filing/presentation/bulk/filing_queue_screen.dart';
import 'package:ca_app/features/filing/presentation/reconciliation/reconciliation_screen.dart';
import 'package:ca_app/features/filing/presentation/analytics/filing_analytics_screen.dart';
import 'package:ca_app/features/filing/presentation/itr_u/itr_u_screen.dart';
import 'package:ca_app/features/filing/presentation/advance_tax/advance_tax_screen.dart';
import 'package:ca_app/features/ocr/data/providers/ocr_providers.dart';
import 'package:ca_app/features/ocr/presentation/ocr_dashboard_screen.dart';
import 'package:ca_app/features/ocr/presentation/ocr_upload_screen.dart';
import 'package:ca_app/features/ocr/presentation/ocr_result_screen.dart';
import 'package:ca_app/features/rpa/domain/models/automation_task.dart';
import 'package:ca_app/features/rpa/presentation/rpa_dashboard_screen.dart';
import 'package:ca_app/features/rpa/presentation/rpa_new_task_screen.dart';
import 'package:ca_app/features/rpa/presentation/rpa_script_library_screen.dart';
import 'package:ca_app/features/rpa/presentation/rpa_task_detail_screen.dart';
import 'package:ca_app/features/litigation/domain/models/tax_notice.dart';
import 'package:ca_app/features/litigation/presentation/appeal_tracker_screen.dart';
import 'package:ca_app/features/litigation/presentation/litigation_dashboard_screen.dart';
import 'package:ca_app/features/litigation/presentation/notice_detail_screen.dart';
import 'package:ca_app/features/litigation/presentation/response_draft_screen.dart';
import 'package:ca_app/features/platform/presentation/platform_home_screen.dart';
import 'package:ca_app/features/platform/presentation/user_management_screen.dart';
import 'package:ca_app/features/platform/presentation/mfa_setup_screen.dart';
import 'package:ca_app/features/platform/presentation/audit_trail_screen.dart';
import 'package:ca_app/features/platform/presentation/sync_status_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _filingNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'filing');
final _clientsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'clients');
final _todayNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'today');
final _docsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'docs');
final _moreNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'more');

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AdaptiveScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _filingNavigatorKey,
            routes: [
              GoRoute(
                path: '/',
                name: 'filing',
                builder: (context, state) => const FilingScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _clientsNavigatorKey,
            routes: [
              GoRoute(
                path: '/clients',
                name: 'clients',
                builder: (context, state) => const ClientsScreen(),
                routes: [
                  GoRoute(
                    path: ':clientId',
                    name: 'clientDetail',
                    builder: (context, state) {
                      final clientId = state.pathParameters['clientId']!;
                      return ClientDetailScreen(clientId: clientId);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _todayNavigatorKey,
            routes: [
              GoRoute(
                path: '/today',
                name: 'today',
                builder: (context, state) => const TodayScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _docsNavigatorKey,
            routes: [
              GoRoute(
                path: '/docs',
                name: 'docs',
                builder: (context, state) => const DocumentsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _moreNavigatorKey,
            routes: [
              GoRoute(
                path: '/more',
                name: 'more',
                builder: (context, state) => const MoreScreen(),
              ),
              GoRoute(
                path: '/ocr',
                name: 'ocr',
                builder: (context, state) => const OcrDashboardScreen(),
              ),
              GoRoute(
                path: '/rpa',
                name: 'rpa',
                builder: (context, state) => const RpaDashboardScreen(),
              ),
              GoRoute(
                path: '/litigation',
                name: 'litigation',
                builder: (context, state) =>
                    const LitigationDashboardScreen(),
              ),
              GoRoute(
                path: '/ca-gpt',
                name: 'caGpt',
                builder: (context, state) => const CaGptHomeScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/tasks',
        name: 'tasks',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const TasksScreen(),
      ),
      GoRoute(
        path: '/compliance',
        name: 'compliance',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ComplianceScreen(),
      ),
      GoRoute(
        path: '/client-portal',
        name: 'clientPortal',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ClientPortalScreen(),
      ),
      GoRoute(
        path: '/income-tax',
        name: 'incomeTax',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const IncomeTaxScreen(),
      ),
      GoRoute(
        path: '/gst',
        name: 'gst',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const GstScreen(),
      ),
      GoRoute(
        path: '/tds',
        name: 'tds',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const TdsScreen(),
      ),
      GoRoute(
        path: '/ai-automation',
        name: 'aiAutomation',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AiDashboardScreen(),
      ),
      GoRoute(
        path: '/analytics',
        name: 'analytics',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AnalyticsDashboardScreen(),
      ),
      GoRoute(
        path: '/time-tracking',
        name: 'timeTracking',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const TimeTrackingScreen(),
      ),
      GoRoute(
        path: '/firm-operations',
        name: 'firmOperations',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const FirmOperationsScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/fema',
        name: 'fema',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const FemaScreen(),
      ),
      GoRoute(
        path: '/sebi',
        name: 'sebi',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SebiScreen(),
      ),
      GoRoute(
        path: '/transfer-pricing',
        name: 'transferPricing',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const TransferPricingScreen(),
      ),
      GoRoute(
        path: '/crypto-vda',
        name: 'cryptoVda',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CryptoVdaScreen(),
      ),
      GoRoute(
        path: '/startup-compliance',
        name: 'startupCompliance',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const StartupComplianceScreen(),
      ),
      GoRoute(
        path: '/llp-compliance',
        name: 'llpCompliance',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LLPComplianceScreen(),
      ),
      GoRoute(
        path: '/msme',
        name: 'msme',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MsmeScreen(),
      ),
      GoRoute(
        path: '/advanced-audit',
        name: 'advancedAudit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AdvancedAuditScreen(),
      ),
      GoRoute(
        path: '/faceless-assessment',
        name: 'facelessAssessment',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const FacelessAssessmentScreen(),
      ),
      GoRoute(
        path: '/staff-monitoring',
        name: 'staffMonitoring',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const StaffMonitoringScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/accounts',
        name: 'accounts',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AccountsScreen(),
      ),
      GoRoute(
        path: '/assessment',
        name: 'assessment',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AssessmentScreen(),
      ),
      GoRoute(
        path: '/documents',
        name: 'documents',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const DocumentsScreen(),
      ),
      GoRoute(
        path: '/billing',
        name: 'billing',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const BillingScreen(),
      ),
      GoRoute(
        path: '/cma',
        name: 'cma',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CmaScreen(),
      ),
      GoRoute(
        path: '/payroll',
        name: 'payroll',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PayrollScreen(),
      ),
      GoRoute(
        path: '/mca',
        name: 'mca',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const McaScreen(),
      ),
      GoRoute(
        path: '/xbrl',
        name: 'xbrl',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const XbrlScreen(),
      ),
      GoRoute(
        path: '/regulatory-trust',
        name: 'regulatoryTrust',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const RegulatoryTrustScreen(),
      ),
      GoRoute(
        path: '/data-pipelines',
        name: 'dataPipelines',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const DataPipelinesScreen(),
      ),
      GoRoute(
        path: '/collaboration',
        name: 'collaboration',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CollaborationScreen(),
      ),
      GoRoute(
        path: '/ecosystem',
        name: 'ecosystem',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const EcosystemScreen(),
      ),
      GoRoute(
        path: '/notice-resolution',
        name: 'noticeResolution',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NoticeResolutionScreen(),
      ),
      GoRoute(
        path: '/dsc-vault',
        name: 'dscVault',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const DscVaultScreen(),
      ),
      GoRoute(
        path: '/sme-cfo',
        name: 'smeCfo',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SmeCfoScreen(),
      ),
      GoRoute(
        path: '/nri-tax',
        name: 'nriTax',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NriTaxScreen(),
      ),
      GoRoute(
        path: '/lead-funnel',
        name: 'leadFunnel',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LeadFunnelScreen(),
      ),
      GoRoute(
        path: '/tax-advisory',
        name: 'taxAdvisory',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const TaxAdvisoryScreen(),
      ),
      GoRoute(
        path: '/renewal-expiry',
        name: 'renewalExpiry',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const RenewalExpiryScreen(),
      ),
      GoRoute(
        path: '/fee-leakage',
        name: 'feeLeakage',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const FeeLeakageScreen(),
      ),
      GoRoute(
        path: '/knowledge-engine',
        name: 'knowledgeEngine',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const KnowledgeEngineScreen(),
      ),
      GoRoute(
        path: '/industry-playbooks',
        name: 'industryPlaybooks',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const IndustryPlaybooksScreen(),
      ),
      GoRoute(
        path: '/esg-reporting',
        name: 'esgReporting',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const EsgReportingScreen(),
      ),
      GoRoute(
        path: '/virtual-cfo',
        name: 'virtualCfo',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const VirtualCfoScreen(),
      ),
      GoRoute(
        path: '/einvoicing',
        name: 'einvoicing',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const EinvoicingScreen(),
      ),
      GoRoute(
        path: '/idp',
        name: 'idp',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const IdpScreen(),
      ),
      GoRoute(
        path: '/regulatory-intelligence',
        name: 'regulatoryIntelligence',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const RegulatoryIntelligenceScreen(),
      ),
      GoRoute(
        path: '/practice-benchmarking',
        name: 'practiceBenchmarking',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PracticeBenchmarkingScreen(),
      ),
      GoRoute(
        path: '/roadmap/:moduleId',
        name: 'roadmapModule',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final moduleId = state.pathParameters['moduleId']!;
          return RoadmapModuleScreen(moduleId: moduleId);
        },
      ),
      GoRoute(
        path: '/filing/new',
        name: 'filingNew',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const FilingTypePickerScreen(),
      ),
      GoRoute(
        path: '/filing/itr1/:jobId',
        name: 'itr1Wizard',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final jobId = state.pathParameters['jobId']!;
          return Itr1WizardScreen(jobId: jobId);
        },
      ),
      GoRoute(
        path: '/filing/itr4/:jobId',
        name: 'itr4Wizard',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final jobId = state.pathParameters['jobId']!;
          return Itr4WizardScreen(jobId: jobId);
        },
      ),
      GoRoute(
        path: '/filing/status/:jobId',
        name: 'filingStatus',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final jobId = state.pathParameters['jobId']!;
          return FilingStatusScreen(jobId: jobId);
        },
      ),
      GoRoute(
        path: '/filing/e-verify/:jobId',
        name: 'eVerification',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final jobId = state.pathParameters['jobId']!;
          return EVerificationScreen(jobId: jobId);
        },
      ),
      GoRoute(
        path: '/filing/queue',
        name: 'filingQueue',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const FilingQueueScreen(),
      ),
      GoRoute(
        path: '/filing/reconciliation',
        name: 'reconciliation',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ReconciliationScreen(),
      ),
      GoRoute(
        path: '/filing/analytics',
        name: 'filingAnalytics',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const FilingAnalyticsScreen(),
      ),
      GoRoute(
        path: '/filing/itr-u',
        name: 'itrU',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ItrUScreen(),
      ),
      GoRoute(
        path: '/filing/advance-tax',
        name: 'advanceTax',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AdvanceTaxScreen(),
      ),
      GoRoute(
        path: '/ocr/upload',
        name: 'ocrUpload',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OcrUploadScreen(),
      ),
      GoRoute(
        path: '/ocr/result',
        name: 'ocrResult',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final job = state.extra as OcrJob;
          return OcrResultScreen(job: job);
        },
      ),
      GoRoute(
        path: '/rpa/new',
        name: 'rpaNew',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const RpaNewTaskScreen(),
      ),
      GoRoute(
        path: '/rpa/task',
        name: 'rpaTask',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final task = state.extra as AutomationTask;
          return RpaTaskDetailScreen(task: task);
        },
      ),
      GoRoute(
        path: '/rpa/scripts',
        name: 'rpaScripts',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const RpaScriptLibraryScreen(),
      ),
      GoRoute(
        path: '/litigation/notice',
        name: 'litigationNotice',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final notice = state.extra as TaxNotice;
          return NoticeDetailScreen(notice: notice);
        },
      ),
      GoRoute(
        path: '/litigation/response',
        name: 'litigationResponse',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final notice = state.extra as TaxNotice;
          return ResponseDraftScreen(notice: notice);
        },
      ),
      GoRoute(
        path: '/litigation/appeal',
        name: 'litigationAppeal',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AppealTrackerScreen(),
      ),
      GoRoute(
        path: '/platform',
        name: 'platform',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PlatformHomeScreen(),
      ),
      GoRoute(
        path: '/platform/users',
        name: 'platformUsers',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const UserManagementScreen(),
      ),
      GoRoute(
        path: '/platform/mfa',
        name: 'platformMfa',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MfaSetupScreen(),
      ),
      GoRoute(
        path: '/platform/audit',
        name: 'platformAudit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AuditTrailScreen(),
      ),
      GoRoute(
        path: '/platform/sync',
        name: 'platformSync',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SyncStatusScreen(),
      ),
    ],
  );
});
