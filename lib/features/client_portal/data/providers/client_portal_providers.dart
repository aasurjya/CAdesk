import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/client_portal/domain/models/client_query.dart';
import 'package:ca_app/features/client_portal/domain/models/portal_message.dart';
import 'package:ca_app/features/client_portal/domain/models/portal_notification.dart';
import 'package:ca_app/features/client_portal/domain/models/shared_document.dart';

// ---------------------------------------------------------------------------
// Mock Messages – 10 messages across 3 threads
// ---------------------------------------------------------------------------

final mockPortalMessages = <PortalMessage>[
  // Thread 1: ITR Filing Discussion (Rajesh Sharma)
  PortalMessage(
    id: 'msg-1',
    senderId: '1',
    senderName: 'Rajesh Kumar Sharma',
    senderType: SenderType.client,
    content: 'I have received Form 16 from TCS. Should I upload it here?',
    threadId: 'thread-1',
    createdAt: DateTime(2026, 3, 5, 10, 30),
    isRead: true,
  ),
  PortalMessage(
    id: 'msg-2',
    senderId: 'staff-1',
    senderName: 'Amit Verma',
    senderType: SenderType.staff,
    content:
        'Yes, please upload Form 16 and your bank statements for FY 2025-26. '
        'We will begin preparing your ITR-2.',
    threadId: 'thread-1',
    createdAt: DateTime(2026, 3, 5, 11, 15),
    isRead: true,
  ),
  PortalMessage(
    id: 'msg-3',
    senderId: '1',
    senderName: 'Rajesh Kumar Sharma',
    senderType: SenderType.client,
    content:
        'Uploaded both documents. Also, I had capital gains from '
        'mutual fund redemption this year.',
    attachments: ['Form16_RajeshSharma.pdf', 'BankStatement_HDFC.pdf'],
    threadId: 'thread-1',
    createdAt: DateTime(2026, 3, 5, 14, 0),
    isRead: true,
  ),
  PortalMessage(
    id: 'msg-4',
    senderId: 'staff-1',
    senderName: 'Amit Verma',
    senderType: SenderType.staff,
    content:
        'Noted. Please also share the mutual fund capital gains '
        'statement from your AMC or CAMS/KFintech.',
    threadId: 'thread-1',
    createdAt: DateTime(2026, 3, 5, 15, 30),
    isRead: false,
  ),

  // Thread 2: GST Return Query (Mehta & Sons)
  PortalMessage(
    id: 'msg-5',
    senderId: '4',
    senderName: 'Suresh Mehta',
    senderType: SenderType.client,
    content:
        'Our GSTR-3B for February is due on 20th March. '
        'Have you received all purchase invoices?',
    threadId: 'thread-2',
    createdAt: DateTime(2026, 3, 8, 9, 0),
    isRead: true,
  ),
  PortalMessage(
    id: 'msg-6',
    senderId: 'staff-2',
    senderName: 'Neha Kapoor',
    senderType: SenderType.staff,
    content:
        'We have reconciled most invoices. There are 3 mismatches '
        'in ITC claims. Sharing the reconciliation report now.',
    attachments: ['GSTR2B_Reconciliation_Feb2026.xlsx'],
    threadId: 'thread-2',
    createdAt: DateTime(2026, 3, 8, 10, 45),
    isRead: true,
  ),
  PortalMessage(
    id: 'msg-7',
    senderId: 'system',
    senderName: 'System',
    senderType: SenderType.system,
    content:
        'Reminder: GSTR-3B filing deadline for February 2026 '
        'is 20th March 2026.',
    threadId: 'thread-2',
    createdAt: DateTime(2026, 3, 9, 8, 0),
    isRead: false,
  ),

  // Thread 3: Payment & Billing (Deepak Patel)
  PortalMessage(
    id: 'msg-8',
    senderId: '9',
    senderName: 'Deepak Patel',
    senderType: SenderType.client,
    content: 'I received the invoice for Q4 services. Can I pay via UPI?',
    threadId: 'thread-3',
    createdAt: DateTime(2026, 3, 7, 16, 0),
    isRead: true,
  ),
  PortalMessage(
    id: 'msg-9',
    senderId: 'staff-1',
    senderName: 'Amit Verma',
    senderType: SenderType.staff,
    content:
        'Yes, you can pay via UPI. Use the payment link shared '
        'in the invoice email or pay directly through the portal.',
    threadId: 'thread-3',
    createdAt: DateTime(2026, 3, 7, 16, 30),
    isRead: true,
  ),
  PortalMessage(
    id: 'msg-10',
    senderId: '9',
    senderName: 'Deepak Patel',
    senderType: SenderType.client,
    content: 'Payment done. PAN: DLKPP3456I. Please confirm receipt.',
    threadId: 'thread-3',
    createdAt: DateTime(2026, 3, 7, 17, 0),
    isRead: false,
  ),
  PortalMessage(
    id: 'msg-11',
    senderId: 'system',
    senderName: 'AI Follow-up Bot',
    senderType: SenderType.system,
    content:
        'WhatsApp reminder sent with a secure magic upload link for '
        'Aadhaar, PAN, and address proof.',
    threadId: 'thread-4',
    createdAt: DateTime(2026, 3, 9, 12, 5),
    isRead: true,
  ),
  PortalMessage(
    id: 'msg-12',
    senderId: '14',
    senderName: 'Vikram Singh Rathore',
    senderType: SenderType.client,
    content:
        'Used the magic link and uploaded Aadhaar + PAN. Address proof '
        'will be shared tonight.',
    attachments: ['aadhaar_vikram.pdf', 'pan_vikram.pdf'],
    threadId: 'thread-4',
    createdAt: DateTime(2026, 3, 9, 12, 18),
    isRead: false,
  ),
  PortalMessage(
    id: 'msg-13',
    senderId: 'staff-2',
    senderName: 'Neha Kapoor',
    senderType: SenderType.staff,
    content:
        'Received. GST registration checklist is now 67% complete. '
        'Only address proof is pending.',
    threadId: 'thread-4',
    createdAt: DateTime(2026, 3, 9, 12, 25),
    isRead: false,
  ),
];

// ---------------------------------------------------------------------------
// Mock Shared Documents – 8 documents
// ---------------------------------------------------------------------------

final mockSharedDocuments = <SharedDocument>[
  SharedDocument(
    id: 'doc-1',
    clientId: '1',
    documentName: 'Form 16 - FY 2025-26',
    documentType: 'Form 16',
    uploadedBy: 'Rajesh Kumar Sharma',
    uploadedAt: DateTime(2026, 3, 5, 14, 0),
    downloadUrl: '/documents/doc-1/form16_rajesh.pdf',
  ),
  SharedDocument(
    id: 'doc-2',
    clientId: '1',
    documentName: 'ITR-2 Draft - AY 2026-27',
    documentType: 'ITR Draft',
    uploadedBy: 'Amit Verma',
    uploadedAt: DateTime(2026, 3, 6, 10, 0),
    isSignatureRequired: true,
    signatureStatus: SignatureStatus.pending,
    downloadUrl: '/documents/doc-2/itr2_draft_rajesh.pdf',
  ),
  SharedDocument(
    id: 'doc-3',
    clientId: '3',
    documentName: 'Statutory Audit Report - FY 2025-26',
    documentType: 'Audit Report',
    uploadedBy: 'Neha Kapoor',
    uploadedAt: DateTime(2026, 2, 28, 15, 0),
    isSignatureRequired: true,
    signatureStatus: SignatureStatus.signed,
    downloadUrl: '/documents/doc-3/audit_report_abc_infra.pdf',
  ),
  SharedDocument(
    id: 'doc-4',
    clientId: '4',
    documentName: 'GSTR-3B Feb 2026',
    documentType: 'GST Return',
    uploadedBy: 'Neha Kapoor',
    uploadedAt: DateTime(2026, 3, 8, 11, 0),
    isSignatureRequired: true,
    signatureStatus: SignatureStatus.pending,
    downloadUrl: '/documents/doc-4/gstr3b_feb_mehta.pdf',
  ),
  SharedDocument(
    id: 'doc-5',
    clientId: '6',
    documentName: 'TDS Return Q3 - Form 24Q',
    documentType: 'TDS Return',
    uploadedBy: 'Amit Verma',
    uploadedAt: DateTime(2026, 2, 15, 9, 30),
    downloadUrl: '/documents/doc-5/tds_q3_techvista.pdf',
  ),
  SharedDocument(
    id: 'doc-6',
    clientId: '8',
    documentName: 'Board Resolution for AGM',
    documentType: 'Corporate Filing',
    uploadedBy: 'Bharat Electronics Ltd',
    uploadedAt: DateTime(2026, 3, 1, 12, 0),
    isSignatureRequired: true,
    signatureStatus: SignatureStatus.rejected,
    expiresAt: DateTime(2026, 3, 15),
    downloadUrl: '/documents/doc-6/board_resolution_bel.pdf',
  ),
  SharedDocument(
    id: 'doc-7',
    clientId: '9',
    documentName: 'Invoice - Q4 2025-26 Services',
    documentType: 'Invoice',
    uploadedBy: 'Amit Verma',
    uploadedAt: DateTime(2026, 3, 7, 10, 0),
    downloadUrl: '/documents/doc-7/invoice_q4_deepak.pdf',
  ),
  SharedDocument(
    id: 'doc-8',
    clientId: '10',
    documentName: 'Form 10B - AY 2026-27',
    documentType: 'Trust Filing',
    uploadedBy: 'Neha Kapoor',
    uploadedAt: DateTime(2026, 3, 4, 14, 0),
    isSignatureRequired: true,
    signatureStatus: SignatureStatus.signed,
    downloadUrl: '/documents/doc-8/form10b_sharma_trust.pdf',
  ),
];

// ---------------------------------------------------------------------------
// Mock Client Queries – 6 queries
// ---------------------------------------------------------------------------

final mockClientQueries = <ClientQuery>[
  ClientQuery(
    id: 'query-1',
    clientId: '1',
    clientName: 'Rajesh Kumar Sharma',
    subject: 'Capital gains computation for MF redemption',
    description:
        'Need help computing capital gains from mutual fund '
        'redemption done in January 2026. Units were purchased across '
        'multiple SIPs.',
    category: QueryCategory.tax,
    priority: QueryPriority.high,
    status: QueryStatus.inProgress,
    assignedTo: 'Amit Verma',
    createdAt: DateTime(2026, 3, 5, 14, 30),
    messages: ['msg-1', 'msg-2', 'msg-3', 'msg-4'],
  ),
  ClientQuery(
    id: 'query-2',
    clientId: '4',
    clientName: 'Suresh Mehta (Mehta & Sons)',
    subject: 'ITC mismatch in GSTR-2B reconciliation',
    description:
        '3 invoices from suppliers not reflecting in GSTR-2B. '
        'Total ITC difference of Rs 47,500.',
    category: QueryCategory.gst,
    priority: QueryPriority.urgent,
    status: QueryStatus.open,
    assignedTo: 'Neha Kapoor',
    createdAt: DateTime(2026, 3, 8, 11, 0),
    messages: ['msg-5', 'msg-6', 'msg-7'],
  ),
  ClientQuery(
    id: 'query-3',
    clientId: '9',
    clientName: 'Deepak Patel',
    subject: 'Invoice clarification for Q4 services',
    description:
        'Received invoice for Rs 15,000 but expected Rs 12,000 '
        'as per the engagement letter. Need breakdown.',
    category: QueryCategory.billing,
    priority: QueryPriority.medium,
    status: QueryStatus.resolved,
    assignedTo: 'Amit Verma',
    createdAt: DateTime(2026, 3, 7, 16, 0),
    resolvedAt: DateTime(2026, 3, 7, 17, 30),
    messages: ['msg-8', 'msg-9', 'msg-10'],
  ),
  ClientQuery(
    id: 'query-4',
    clientId: '6',
    clientName: 'TechVista Solutions LLP',
    subject: 'TDS rate for contractor payments',
    description:
        'We are paying a US-based contractor. What TDS rate '
        'applies under Section 195? Do we need a CA certificate?',
    category: QueryCategory.compliance,
    priority: QueryPriority.high,
    status: QueryStatus.awaitingClient,
    assignedTo: 'Amit Verma',
    createdAt: DateTime(2026, 3, 2, 10, 0),
    messages: [],
  ),
  ClientQuery(
    id: 'query-5',
    clientId: '8',
    clientName: 'Bharat Electronics Ltd',
    subject: 'Board resolution format for AGM',
    description:
        'Need the correct format for board resolution to '
        'approve the annual accounts before the AGM scheduled in April.',
    category: QueryCategory.compliance,
    priority: QueryPriority.medium,
    status: QueryStatus.closed,
    assignedTo: 'Neha Kapoor',
    createdAt: DateTime(2026, 2, 25, 9, 0),
    resolvedAt: DateTime(2026, 3, 1, 12, 0),
    messages: [],
  ),
  ClientQuery(
    id: 'query-6',
    clientId: '14',
    clientName: 'Vikram Singh Rathore',
    subject: 'GST registration for hotel business',
    description:
        'Planning to register for GST. Need guidance on '
        'applicable rate for hotel rooms below Rs 7,500 per night.',
    category: QueryCategory.gst,
    priority: QueryPriority.low,
    status: QueryStatus.open,
    createdAt: DateTime(2026, 3, 9, 11, 30),
    messages: [],
  ),
];

// ---------------------------------------------------------------------------
// Mock Notifications – 10 notifications
// ---------------------------------------------------------------------------

final mockPortalNotifications = <PortalNotification>[
  PortalNotification(
    id: 'notif-1',
    clientId: '1',
    type: NotificationType.document,
    title: 'ITR-2 Draft Ready for Review',
    body:
        'Your ITR-2 draft for AY 2026-27 is ready. Please review '
        'and sign the document in the portal.',
    channel: NotificationChannel.email,
    sentAt: DateTime(2026, 3, 6, 10, 30),
  ),
  PortalNotification(
    id: 'notif-2',
    clientId: '4',
    type: NotificationType.deadline,
    title: 'GSTR-3B Filing Deadline',
    body:
        'GSTR-3B for February 2026 is due on 20th March 2026. '
        'Please approve the return for filing.',
    channel: NotificationChannel.whatsapp,
    sentAt: DateTime(2026, 3, 9, 8, 0),
  ),
  PortalNotification(
    id: 'notif-3',
    clientId: '9',
    type: NotificationType.payment,
    title: 'Payment Received - Rs 15,000',
    body:
        'We have received your payment of Rs 15,000 for Q4 2025-26 '
        'services. Receipt has been generated.',
    channel: NotificationChannel.email,
    sentAt: DateTime(2026, 3, 7, 18, 0),
    isRead: true,
  ),
  PortalNotification(
    id: 'notif-4',
    clientId: '6',
    type: NotificationType.reminder,
    title: 'Pending: TDS Certificate Required',
    body:
        'Please share the TDS certificate for payments made to the '
        'US-based contractor to proceed with Section 195 compliance.',
    channel: NotificationChannel.sms,
    sentAt: DateTime(2026, 3, 8, 14, 0),
  ),
  PortalNotification(
    id: 'notif-5',
    clientId: '8',
    type: NotificationType.document,
    title: 'Board Resolution Needs Re-signing',
    body:
        'The board resolution document was rejected. Please review '
        'the comments and re-sign the updated version.',
    channel: NotificationChannel.inApp,
    sentAt: DateTime(2026, 3, 3, 9, 0),
  ),
  PortalNotification(
    id: 'notif-6',
    clientId: '3',
    type: NotificationType.deadline,
    title: 'Advance Tax Due - 15th March',
    body:
        'Advance tax for Q4 (January-March 2026) is due on 15th '
        'March 2026. Estimated payable: Rs 4,50,000.',
    channel: NotificationChannel.whatsapp,
    sentAt: DateTime(2026, 3, 10, 8, 0),
  ),
  PortalNotification(
    id: 'notif-7',
    clientId: '10',
    type: NotificationType.document,
    title: 'Form 10B Signed Successfully',
    body:
        'Form 10B for AY 2026-27 has been signed and submitted. '
        'You can download the signed copy from the portal.',
    channel: NotificationChannel.email,
    sentAt: DateTime(2026, 3, 5, 16, 0),
    isRead: true,
  ),
  PortalNotification(
    id: 'notif-8',
    clientId: '1',
    type: NotificationType.message,
    title: 'New Message from Your CA',
    body:
        'Amit Verma has sent you a message regarding your capital '
        'gains computation. Please check the portal.',
    channel: NotificationChannel.inApp,
    sentAt: DateTime(2026, 3, 5, 15, 35),
  ),
  PortalNotification(
    id: 'notif-9',
    clientId: '14',
    type: NotificationType.reminder,
    title: 'GST Registration - Documents Needed',
    body:
        'To proceed with your GST registration, please upload '
        'Aadhaar, PAN card, and proof of business address.',
    channel: NotificationChannel.sms,
    sentAt: DateTime(2026, 3, 9, 12, 0),
  ),
  PortalNotification(
    id: 'notif-10',
    clientId: '4',
    type: NotificationType.payment,
    title: 'Invoice Generated - Rs 25,000',
    body:
        'Invoice for GST filing and bookkeeping services for '
        'February 2026 has been generated. Due date: 25th March 2026.',
    channel: NotificationChannel.email,
    sentAt: DateTime(2026, 3, 10, 10, 0),
  ),
  PortalNotification(
    id: 'notif-11',
    clientId: '14',
    type: NotificationType.reminder,
    title: 'AI Follow-up Sent on WhatsApp',
    body:
        'The bot sent a document request with a one-tap magic upload link '
        'for GST registration KYC.',
    channel: NotificationChannel.whatsapp,
    sentAt: DateTime(2026, 3, 9, 12, 5),
  ),
  PortalNotification(
    id: 'notif-12',
    clientId: '1',
    type: NotificationType.document,
    title: 'Magic Link Expires in 6 Hours',
    body:
        'Capital gains statement upload link will expire today at 10:00 PM. '
        'Resend if the client has not completed submission.',
    channel: NotificationChannel.inApp,
    sentAt: DateTime(2026, 3, 10, 16, 0),
  ),
];

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

// Messages

final allMessagesProvider =
    NotifierProvider<AllMessagesNotifier, List<PortalMessage>>(
      AllMessagesNotifier.new,
    );

class AllMessagesNotifier extends Notifier<List<PortalMessage>> {
  @override
  List<PortalMessage> build() => List.unmodifiable(mockPortalMessages);

  void update(List<PortalMessage> value) => state = value;
}

final selectedThreadProvider =
    NotifierProvider<SelectedThreadNotifier, String?>(
      SelectedThreadNotifier.new,
    );

class SelectedThreadNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void update(String? value) => state = value;
}

final threadIdsProvider = Provider<List<String>>((ref) {
  final messages = ref.watch(allMessagesProvider);
  final seen = <String>{};
  final ids = <String>[];
  for (final m in messages) {
    if (seen.add(m.threadId)) {
      ids.add(m.threadId);
    }
  }
  return List.unmodifiable(ids);
});

final messagesByThreadProvider = Provider.family<List<PortalMessage>, String>((
  ref,
  threadId,
) {
  final messages = ref.watch(allMessagesProvider);
  return List.unmodifiable(
    messages.where((m) => m.threadId == threadId).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt)),
  );
});

// Shared Documents

final allDocumentsProvider =
    NotifierProvider<AllDocumentsNotifier, List<SharedDocument>>(
      AllDocumentsNotifier.new,
    );

class AllDocumentsNotifier extends Notifier<List<SharedDocument>> {
  @override
  List<SharedDocument> build() => List.unmodifiable(mockSharedDocuments);

  void update(List<SharedDocument> value) => state = value;
}

final documentFilterProvider =
    NotifierProvider<DocumentFilterNotifier, SignatureStatus?>(
      DocumentFilterNotifier.new,
    );

class DocumentFilterNotifier extends Notifier<SignatureStatus?> {
  @override
  SignatureStatus? build() => null;

  void update(SignatureStatus? value) => state = value;
}

final filteredDocumentsProvider = Provider<List<SharedDocument>>((ref) {
  final docs = ref.watch(allDocumentsProvider);
  final filter = ref.watch(documentFilterProvider);
  if (filter == null) return docs;
  return List.unmodifiable(
    docs.where((d) => d.signatureStatus == filter).toList(),
  );
});

// Client Queries

final allQueriesProvider =
    NotifierProvider<AllQueriesNotifier, List<ClientQuery>>(
      AllQueriesNotifier.new,
    );

class AllQueriesNotifier extends Notifier<List<ClientQuery>> {
  @override
  List<ClientQuery> build() => List.unmodifiable(mockClientQueries);

  void update(List<ClientQuery> value) => state = value;
}

final queryStatusFilterProvider =
    NotifierProvider<QueryStatusFilterNotifier, QueryStatus?>(
      QueryStatusFilterNotifier.new,
    );

class QueryStatusFilterNotifier extends Notifier<QueryStatus?> {
  @override
  QueryStatus? build() => null;

  void update(QueryStatus? value) => state = value;
}

final filteredQueriesProvider = Provider<List<ClientQuery>>((ref) {
  final queries = ref.watch(allQueriesProvider);
  final statusFilter = ref.watch(queryStatusFilterProvider);
  if (statusFilter == null) return queries;
  return List.unmodifiable(
    queries.where((q) => q.status == statusFilter).toList(),
  );
});

// Notifications

final allNotificationsProvider =
    NotifierProvider<AllNotificationsNotifier, List<PortalNotification>>(
      AllNotificationsNotifier.new,
    );

class AllNotificationsNotifier extends Notifier<List<PortalNotification>> {
  @override
  List<PortalNotification> build() =>
      List.unmodifiable(mockPortalNotifications);

  void update(List<PortalNotification> value) => state = value;
}

final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(allNotificationsProvider);
  return notifications.where((n) => !n.isRead).length;
});

final portalAutomationSummaryProvider = Provider<Map<String, int>>((ref) {
  final notifications = ref.watch(allNotificationsProvider);
  final documents = ref.watch(allDocumentsProvider);
  return {
    'followUps': notifications
        .where((n) => n.title.contains('AI Follow-up'))
        .length,
    'magicLinks': notifications
        .where((n) => n.title.contains('Magic Link'))
        .length,
    'pendingSignatures': documents
        .where((d) => d.signatureStatus == SignatureStatus.pending)
        .length,
  };
});
