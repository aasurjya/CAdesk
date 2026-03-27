import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/features/ai_automation/presentation/ai_dashboard_screen.dart';
import 'package:ca_app/features/analytics/presentation/analytics_dashboard_screen.dart';
import 'package:ca_app/features/idp/presentation/idp_screen.dart';
import 'package:ca_app/features/knowledge_engine/presentation/knowledge_engine_screen.dart';
import 'package:ca_app/features/industry_playbooks/presentation/industry_playbooks_screen.dart';
import 'package:ca_app/features/esg_reporting/presentation/esg_reporting_screen.dart';
import 'package:ca_app/features/virtual_cfo/presentation/virtual_cfo_screen.dart';
import 'package:ca_app/features/regulatory_trust/presentation/regulatory_trust_screen.dart';
import 'package:ca_app/features/regulatory_intelligence/presentation/regulatory_intelligence_screen.dart';
import 'package:ca_app/features/practice_benchmarking/presentation/practice_benchmarking_screen.dart';
import 'package:ca_app/features/data_pipelines/presentation/data_pipelines_screen.dart';
import 'package:ca_app/features/ecosystem/presentation/ecosystem_screen.dart';
import 'package:ca_app/features/roadmap_modules/presentation/roadmap_module_screen.dart';
import 'package:ca_app/features/regulatory_intelligence/presentation/regulation_detail_screen.dart';
import 'package:ca_app/features/esg_reporting/presentation/esg_report_screen.dart';
import 'package:ca_app/features/industry_playbooks/presentation/playbook_detail_screen.dart';
import 'package:ca_app/features/virtual_cfo/presentation/cfo_dashboard_detail_screen.dart';
import 'package:ca_app/features/ai_automation/presentation/ai_workflow_screen.dart';
import 'package:ca_app/features/analytics/presentation/analytics_report_screen.dart';
import 'package:ca_app/features/knowledge_engine/presentation/ca_gpt_chat_screen.dart';
import 'package:ca_app/features/ai_automation/presentation/rpa_dashboard_screen.dart';
import 'package:ca_app/features/idp/presentation/ocr_hub_screen.dart';
import 'package:ca_app/features/knowledge_engine/presentation/knowledge_search_screen.dart';
import 'package:ca_app/features/settings/presentation/smart_notifications_screen.dart';
import 'package:ca_app/features/data_pipelines/presentation/pipeline_detail_screen.dart';
import 'package:ca_app/features/practice_benchmarking/presentation/benchmark_detail_screen.dart';
import 'package:ca_app/features/regulatory_trust/presentation/trust_score_screen.dart';
import 'package:ca_app/features/portal_connector/presentation/portal_connector_screen.dart';
import 'package:ca_app/features/portal_parser/presentation/parser_result_screen.dart';
import 'package:ca_app/features/portal_export/presentation/export_detail_screen.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_job.dart';
import 'package:ca_app/features/portal_autosubmit/presentation/autosubmit_queue_screen.dart';
import 'package:ca_app/features/portal_autosubmit/presentation/pre_fill_review_screen.dart';
import 'package:ca_app/features/portal_autosubmit/presentation/submission_flow_screen.dart';
import 'package:ca_app/features/portal_autosubmit/domain/services/confirmation_gate.dart';
import 'package:ca_app/features/portal_autosubmit/webview/file_upload_handler.dart';
import 'package:ca_app/features/portal_autosubmit/webview/portal_webview_screen.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';
import 'package:ca_app/features/gstn_api/presentation/gstn_api_dashboard_screen.dart';
import 'package:ca_app/features/ecosystem/presentation/integration_detail_screen.dart';

/// Returns all AI, analytics, and platform routes.
List<RouteBase> aiRoutes(GlobalKey<NavigatorState> rootNavigatorKey) => [
  GoRoute(
    path: '/ai-automation',
    name: 'aiAutomation',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const AiDashboardScreen(),
  ),
  GoRoute(
    path: '/analytics',
    name: 'analytics',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const AnalyticsDashboardScreen(),
  ),
  GoRoute(
    path: '/idp',
    name: 'idp',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const IdpScreen(),
  ),
  GoRoute(
    path: '/knowledge-engine',
    name: 'knowledgeEngine',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const KnowledgeEngineScreen(),
  ),
  GoRoute(
    path: '/industry-playbooks',
    name: 'industryPlaybooks',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const IndustryPlaybooksScreen(),
  ),
  GoRoute(
    path: '/esg-reporting',
    name: 'esgReporting',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const EsgReportingScreen(),
  ),
  GoRoute(
    path: '/virtual-cfo',
    name: 'virtualCfo',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const VirtualCfoScreen(),
  ),
  GoRoute(
    path: '/regulatory-trust',
    name: 'regulatoryTrust',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const RegulatoryTrustScreen(),
  ),
  GoRoute(
    path: '/regulatory-intelligence',
    name: 'regulatoryIntelligence',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const RegulatoryIntelligenceScreen(),
  ),
  GoRoute(
    path: '/practice-benchmarking',
    name: 'practiceBenchmarking',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const PracticeBenchmarkingScreen(),
  ),
  GoRoute(
    path: '/data-pipelines',
    name: 'dataPipelines',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const DataPipelinesScreen(),
  ),
  GoRoute(
    path: '/ecosystem',
    name: 'ecosystem',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const EcosystemScreen(),
  ),
  // Legacy /dashboard path redirects to home (Dashboard is now at /).
  GoRoute(
    path: '/dashboard',
    parentNavigatorKey: rootNavigatorKey,
    redirect: (context, state) => '/',
  ),
  GoRoute(
    path: '/roadmap/:moduleId',
    name: 'roadmapModule',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) {
      final moduleId = state.pathParameters['moduleId']!;
      return RoadmapModuleScreen(moduleId: moduleId);
    },
  ),
  GoRoute(
    path: '/regulatory-intelligence/detail/:regulationId',
    name: 'regulationDetail',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) {
      final regulationId = state.pathParameters['regulationId']!;
      return RegulationDetailScreen(regulationId: regulationId);
    },
  ),
  GoRoute(
    path: '/esg-reporting/report/:reportId',
    name: 'esgReport',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) {
      final reportId = state.pathParameters['reportId']!;
      return EsgReportScreen(reportId: reportId);
    },
  ),
  GoRoute(
    path: '/industry-playbooks/detail/:playbookId',
    name: 'playbookDetail',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) {
      final playbookId = state.pathParameters['playbookId']!;
      return PlaybookDetailScreen(playbookId: playbookId);
    },
  ),
  GoRoute(
    path: '/virtual-cfo/dashboard/:clientId',
    name: 'cfoDashboard',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) {
      final clientId = state.pathParameters['clientId']!;
      return CfoDashboardDetailScreen(clientId: clientId);
    },
  ),
  // --- AI & Analytics detail screens ---
  GoRoute(
    path: '/ai-automation/workflow/:workflowId',
    name: 'aiWorkflow',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) {
      final workflowId = state.pathParameters['workflowId']!;
      return AiWorkflowScreen(workflowId: workflowId);
    },
  ),
  GoRoute(
    path: '/analytics/report',
    name: 'analyticsReport',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const AnalyticsReportScreen(),
  ),
  GoRoute(
    path: '/ca-gpt',
    name: 'caGpt',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const CaGptChatScreen(),
  ),
  GoRoute(
    path: '/ai-automation/rpa',
    name: 'rpaDashboard',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const RpaDashboardScreen(),
  ),
  GoRoute(
    path: '/idp/ocr-hub',
    name: 'ocrHub',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const OcrHubScreen(),
  ),
  GoRoute(
    path: '/knowledge-engine/search',
    name: 'knowledgeSearch',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const KnowledgeSearchScreen(),
  ),
  GoRoute(
    path: '/settings/notifications',
    name: 'smartNotifications',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const SmartNotificationsScreen(),
  ),
  GoRoute(
    path: '/data-pipelines/detail/:pipelineId',
    name: 'pipelineDetail',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) {
      final pipelineId = state.pathParameters['pipelineId']!;
      return PipelineDetailScreen(pipelineId: pipelineId);
    },
  ),
  GoRoute(
    path: '/practice-benchmarking/detail',
    name: 'benchmarkDetail',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const BenchmarkDetailScreen(),
  ),
  GoRoute(
    path: '/regulatory-trust/score',
    name: 'trustScore',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const TrustScoreScreen(),
  ),
  // --- Portal & Platform enhancement screens ---
  GoRoute(
    path: '/portal-connector',
    name: 'portalConnector',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const PortalConnectorScreen(),
  ),
  GoRoute(
    path: '/portal-parser/result/:resultId',
    name: 'parserResult',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) {
      final resultId = state.pathParameters['resultId']!;
      return ParserResultScreen(resultId: resultId);
    },
  ),
  GoRoute(
    path: '/portal-export/detail/:exportId',
    name: 'exportDetail',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) {
      final exportId = state.pathParameters['exportId']!;
      return ExportDetailScreen(exportId: exportId);
    },
  ),
  GoRoute(
    path: '/portal-autosubmit',
    name: 'autosubmitQueue',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const AutosubmitQueueScreen(),
  ),
  GoRoute(
    path: '/portal-autosubmit/flow/:jobId',
    name: 'submissionFlow',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) {
      final jobId = state.pathParameters['jobId']!;
      return SubmissionFlowScreen(jobId: jobId);
    },
  ),
  GoRoute(
    path: '/portal-autosubmit/review/:jobId',
    name: 'submissionReview',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) {
      final job = state.extra as SubmissionJob;
      return PreFillReviewScreen(job: job);
    },
  ),
  GoRoute(
    path: '/portal-autosubmit/webview/:jobId',
    name: 'submissionWebView',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) {
      final extra = state.extra! as Map<String, dynamic>;
      return PortalWebViewScreen(
        job: extra['job'] as SubmissionJob,
        credential: extra['credential'] as PortalCredential,
        automationRunner: extra['runner'] as AutomationRunner?,
        confirmationGate: extra['gate'] as ConfirmationGate?,
        fileUploadHandler: extra['fileUploadHandler'] as FileUploadHandler?,
      );
    },
  ),
  GoRoute(
    path: '/gstn-api',
    name: 'gstnApiDashboard',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const GstnApiDashboardScreen(),
  ),
  GoRoute(
    path: '/ecosystem/integration/:integrationId',
    name: 'integrationDetail',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) {
      final integrationId = state.pathParameters['integrationId']!;
      return IntegrationDetailScreen(integrationId: integrationId);
    },
  ),
];
