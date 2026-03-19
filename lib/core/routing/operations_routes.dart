import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/features/tasks/presentation/tasks_screen.dart';
import 'package:ca_app/features/time_tracking/presentation/time_tracking_screen.dart';
import 'package:ca_app/features/firm_operations/presentation/firm_operations_screen.dart';
import 'package:ca_app/features/staff_monitoring/presentation/staff_monitoring_screen.dart';
import 'package:ca_app/features/onboarding/presentation/onboarding_screen.dart';
import 'package:ca_app/features/client_portal/presentation/client_portal_screen.dart';
import 'package:ca_app/features/billing/presentation/billing_screen.dart';
import 'package:ca_app/features/documents/presentation/documents_screen.dart';
import 'package:ca_app/features/documents/presentation/document_viewer_screen.dart';
import 'package:ca_app/features/documents/presentation/document_upload_screen.dart';
import 'package:ca_app/features/documents/presentation/ocr_preview_screen.dart';
import 'package:ca_app/features/settings/presentation/settings_screen.dart';
import 'package:ca_app/features/lead_funnel/presentation/lead_funnel_screen.dart';
import 'package:ca_app/features/sme_cfo/presentation/sme_cfo_screen.dart';
import 'package:ca_app/features/collaboration/presentation/collaboration_screen.dart';
import 'package:ca_app/features/bulk_operations/presentation/bulk_dashboard_screen.dart';
import 'package:ca_app/features/bulk_operations/presentation/batch_detail_screen.dart';
import 'package:ca_app/features/bulk_operations/presentation/new_batch_screen.dart';
import 'package:ca_app/features/practice/presentation/practice_dashboard_screen.dart';
import 'package:ca_app/features/practice/presentation/workflow_list_screen.dart';
import 'package:ca_app/features/practice/presentation/assignment_screen.dart';
import 'package:ca_app/features/practice/presentation/capacity_screen.dart';
import 'package:ca_app/features/practice/presentation/kanban/kanban_board_screen.dart';
import 'package:ca_app/features/practice/presentation/deadline_dashboard_screen.dart';
import 'package:ca_app/features/time_tracking/presentation/time_entry_screen.dart';
import 'package:ca_app/features/staff_monitoring/presentation/staff_detail_screen.dart';
import 'package:ca_app/features/client_portal/presentation/portal_admin_screen.dart';
import 'package:ca_app/features/lead_funnel/presentation/lead_detail_screen.dart';
import 'package:ca_app/features/billing/presentation/invoice_form_screen.dart';
import 'package:ca_app/features/clients/presentation/client_health_dashboard.dart';
import 'package:ca_app/features/firm_operations/presentation/firm_kpi_screen.dart';
import 'package:ca_app/features/tasks/presentation/task_detail_screen.dart';
import 'package:ca_app/features/reconciliation/presentation/reconciliation_detail_screen.dart';
import 'package:ca_app/features/settings/presentation/firm_profile_screen.dart';
import 'package:ca_app/features/onboarding/presentation/kyc_verification_screen.dart';
import 'package:ca_app/features/post_filing/presentation/demand_tracker_screen.dart';
import 'package:ca_app/features/sme_cfo/presentation/sme_advisory_screen.dart';
import 'package:ca_app/features/bulk_operations/presentation/batch_progress_screen.dart';
import 'package:ca_app/features/collaboration/presentation/shared_workspace_screen.dart';

/// Returns all practice management and operations routes.
List<RouteBase> operationsRoutes(
  GlobalKey<NavigatorState> rootNavigatorKey,
) => [
  GoRoute(
    path: '/tasks',
    name: 'tasks',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const TasksScreen(),
  ),
  GoRoute(
    path: '/time-tracking',
    name: 'timeTracking',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const TimeTrackingScreen(),
  ),
  GoRoute(
    path: '/firm-operations',
    name: 'firmOperations',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const FirmOperationsScreen(),
  ),
  GoRoute(
    path: '/staff-monitoring',
    name: 'staffMonitoring',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const StaffMonitoringScreen(),
  ),
  GoRoute(
    path: '/onboarding',
    name: 'onboarding',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const OnboardingScreen(),
  ),
  GoRoute(
    path: '/client-portal',
    name: 'clientPortal',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const ClientPortalScreen(),
  ),
  GoRoute(
    path: '/billing',
    name: 'billing',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const BillingScreen(),
  ),
  GoRoute(
    path: '/documents',
    name: 'documents',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const DocumentsScreen(),
  ),
  GoRoute(
    path: '/documents/view/:documentId',
    name: 'documentViewer',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) =>
        DocumentViewerScreen(documentId: state.pathParameters['documentId']!),
  ),
  GoRoute(
    path: '/documents/upload',
    name: 'documentUpload',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const DocumentUploadScreen(),
  ),
  GoRoute(
    path: '/documents/ocr/:documentId',
    name: 'documentOcr',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) =>
        OcrPreviewScreen(documentId: state.pathParameters['documentId']!),
  ),
  GoRoute(
    path: '/settings',
    name: 'settings',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const SettingsScreen(),
  ),
  GoRoute(
    path: '/lead-funnel',
    name: 'leadFunnel',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const LeadFunnelScreen(),
  ),
  GoRoute(
    path: '/sme-cfo',
    name: 'smeCfo',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const SmeCfoScreen(),
  ),
  GoRoute(
    path: '/collaboration',
    name: 'collaboration',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const CollaborationScreen(),
  ),
  GoRoute(
    path: '/bulk-operations',
    name: 'bulkOperations',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const BulkDashboardScreen(),
  ),
  GoRoute(
    path: '/bulk-operations/batch',
    name: 'batchDetail',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const BatchDetailScreen(),
  ),
  GoRoute(
    path: '/bulk-operations/new',
    name: 'newBatch',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const NewBatchScreen(),
  ),
  GoRoute(
    path: '/practice',
    name: 'practice',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const PracticeDashboardScreen(),
  ),
  GoRoute(
    path: '/practice/workflows',
    name: 'practiceWorkflows',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const WorkflowListScreen(),
  ),
  GoRoute(
    path: '/practice/assignments',
    name: 'practiceAssignments',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const AssignmentScreen(),
  ),
  GoRoute(
    path: '/practice/capacity',
    name: 'practiceCapacity',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const CapacityScreen(),
  ),
  GoRoute(
    path: '/practice/kanban',
    name: 'practiceKanban',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const KanbanBoardScreen(),
  ),
  GoRoute(
    path: '/practice/deadlines',
    name: 'practiceDeadlines',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const DeadlineDashboardScreen(),
  ),

  // --- Enhanced module screens ---
  GoRoute(
    path: '/time-tracking/new',
    name: 'timeEntry',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const TimeEntryScreen(),
  ),
  GoRoute(
    path: '/staff-monitoring/detail/:staffId',
    name: 'staffDetail',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) {
      final staffId = state.pathParameters['staffId']!;
      return StaffDetailScreen(staffId: staffId);
    },
  ),
  GoRoute(
    path: '/client-portal/admin',
    name: 'portalAdmin',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const PortalAdminScreen(),
  ),
  GoRoute(
    path: '/lead-funnel/detail/:leadId',
    name: 'leadDetail',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) {
      final leadId = state.pathParameters['leadId']!;
      return LeadDetailScreen(leadId: leadId);
    },
  ),
  GoRoute(
    path: '/billing/new',
    name: 'invoiceNew',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const InvoiceFormScreen(),
  ),
  GoRoute(
    path: '/billing/edit/:invoiceId',
    name: 'invoiceEdit',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) {
      final invoiceId = state.pathParameters['invoiceId']!;
      return InvoiceFormScreen(invoiceId: invoiceId);
    },
  ),
  GoRoute(
    path: '/clients/health/:clientId',
    name: 'clientHealth',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) {
      final clientId = state.pathParameters['clientId']!;
      return ClientHealthDashboard(clientId: clientId);
    },
  ),
  GoRoute(
    path: '/firm-operations/kpis',
    name: 'firmKpis',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const FirmKpiScreen(),
  ),
  GoRoute(
    path: '/tasks/detail/:taskId',
    name: 'taskDetail',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) {
      final taskId = state.pathParameters['taskId']!;
      return TaskDetailScreen(taskId: taskId);
    },
  ),
  GoRoute(
    path: '/reconciliation/detail/:periodId',
    name: 'reconciliationDetail',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) {
      final periodId = state.pathParameters['periodId']!;
      return ReconciliationDetailScreen(periodId: periodId);
    },
  ),
  GoRoute(
    path: '/settings/firm-profile',
    name: 'firmProfile',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const FirmProfileScreen(),
  ),
  GoRoute(
    path: '/onboarding/kyc/:clientId',
    name: 'kycVerification',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) {
      final clientId = state.pathParameters['clientId']!;
      return KycVerificationScreen(clientId: clientId);
    },
  ),
  GoRoute(
    path: '/post-filing/demands',
    name: 'demandTracker',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const DemandTrackerScreen(),
  ),
  GoRoute(
    path: '/sme-cfo/advisory/:clientId',
    name: 'smeAdvisory',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) {
      final clientId = state.pathParameters['clientId']!;
      return SmeAdvisoryScreen(clientId: clientId);
    },
  ),
  // --- Portal & Platform enhancement screens ---
  GoRoute(
    path: '/bulk-operations/progress/:batchId',
    name: 'batchProgress',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) {
      final batchId = state.pathParameters['batchId']!;
      return BatchProgressScreen(batchId: batchId);
    },
  ),
  GoRoute(
    path: '/collaboration/workspace/:workspaceId',
    name: 'sharedWorkspace',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) {
      final workspaceId = state.pathParameters['workspaceId']!;
      return SharedWorkspaceScreen(workspaceId: workspaceId);
    },
  ),
];
