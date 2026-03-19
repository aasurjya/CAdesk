import 'package:ca_app/features/billing/domain/models/invoice.dart';
import 'package:ca_app/features/clients/domain/models/client.dart';
import 'package:ca_app/features/clients/domain/models/client_type.dart';
import 'package:ca_app/features/compliance/domain/models/compliance_deadline.dart';
import 'package:ca_app/features/documents/domain/models/document.dart';
import 'package:ca_app/features/tasks/domain/models/task.dart';
import 'package:ca_app/features/tasks/domain/models/task_priority.dart';
import 'package:ca_app/features/tasks/domain/models/task_status.dart';

/// Auto-incrementing counter for generating unique test IDs.
int _counter = 0;

/// Returns a unique ID string for test data. Each call increments the
/// internal counter so IDs never collide within a test run.
String _nextId(String prefix) {
  _counter++;
  return '$prefix-$_counter';
}

/// Resets the internal counter. Call in setUp if tests need deterministic IDs.
void resetTestDataCounter() {
  _counter = 0;
}

// ---------------------------------------------------------------------------
// Client
// ---------------------------------------------------------------------------

/// Creates a [Client] with sensible defaults. Override any field via named
/// parameters.
Client makeClient({
  String? id,
  String? name,
  String? pan,
  String? aadhaar,
  String? email,
  String? phone,
  String? alternatePhone,
  ClientType? clientType,
  DateTime? dateOfBirth,
  DateTime? dateOfIncorporation,
  String? address,
  String? city,
  String? state,
  String? pincode,
  String? gstin,
  String? tan,
  List<ServiceType>? servicesAvailed,
  ClientStatus? status,
  DateTime? createdAt,
  DateTime? updatedAt,
  String? notes,
}) {
  final now = DateTime(2025, 1, 15, 10, 0);
  return Client(
    id: id ?? _nextId('client'),
    name: name ?? 'Test Client',
    pan: pan ?? 'ABCDE1234F',
    aadhaar: aadhaar,
    email: email ?? 'test@example.com',
    phone: phone ?? '9876543210',
    alternatePhone: alternatePhone,
    clientType: clientType ?? ClientType.individual,
    dateOfBirth: dateOfBirth,
    dateOfIncorporation: dateOfIncorporation,
    address: address ?? '123 MG Road',
    city: city ?? 'Mumbai',
    state: state ?? 'Maharashtra',
    pincode: pincode ?? '400001',
    gstin: gstin,
    tan: tan,
    servicesAvailed: servicesAvailed ?? const [ServiceType.itrFiling],
    status: status ?? ClientStatus.active,
    createdAt: createdAt ?? now,
    updatedAt: updatedAt ?? now,
    notes: notes,
  );
}

// ---------------------------------------------------------------------------
// Invoice / LineItem
// ---------------------------------------------------------------------------

/// Creates a [LineItem] with sensible defaults.
LineItem makeLineItem({
  String? description,
  String? hsn,
  double? quantity,
  double? rate,
  double? taxableAmount,
  double? gstRate,
  double? cgst,
  double? sgst,
  double? igst,
  double? total,
}) {
  final qty = quantity ?? 1;
  final r = rate ?? 10000;
  final taxable = taxableAmount ?? qty * r;
  final gst = gstRate ?? 18;
  final halfGst = taxable * gst / 200;
  return LineItem(
    description: description ?? 'Professional Services',
    hsn: hsn ?? '998231',
    quantity: qty,
    rate: r,
    taxableAmount: taxable,
    gstRate: gst,
    cgst: cgst ?? halfGst,
    sgst: sgst ?? halfGst,
    igst: igst ?? 0,
    total: total ?? (taxable + halfGst * 2),
  );
}

/// Creates an [Invoice] with sensible defaults.
Invoice makeInvoice({
  String? id,
  String? invoiceNumber,
  String? clientId,
  String? clientName,
  String? gstin,
  DateTime? invoiceDate,
  DateTime? dueDate,
  List<LineItem>? lineItems,
  double? subtotal,
  double? totalGst,
  double? grandTotal,
  double? paidAmount,
  double? balanceDue,
  InvoiceStatus? status,
  DateTime? paymentDate,
  String? paymentMethod,
  String? remarks,
  bool? isRecurring,
  RecurringFrequency? recurringFrequency,
}) {
  final items = lineItems ?? [makeLineItem()];
  final sub = subtotal ?? 10000;
  final gst = totalGst ?? 1800;
  final grand = grandTotal ?? 11800;
  final paid = paidAmount ?? 0;

  return Invoice(
    id: id ?? _nextId('inv'),
    invoiceNumber:
        invoiceNumber ?? 'INV-${_counter.toString().padLeft(4, '0')}',
    clientId: clientId ?? 'client-1',
    clientName: clientName ?? 'Test Client',
    gstin: gstin,
    invoiceDate: invoiceDate ?? DateTime(2025, 1, 15),
    dueDate: dueDate ?? DateTime(2025, 2, 14),
    lineItems: items,
    subtotal: sub,
    totalGst: gst,
    grandTotal: grand,
    paidAmount: paid,
    balanceDue: balanceDue ?? (grand - paid),
    status: status ?? InvoiceStatus.draft,
    paymentDate: paymentDate,
    paymentMethod: paymentMethod,
    remarks: remarks,
    isRecurring: isRecurring ?? false,
    recurringFrequency: recurringFrequency,
  );
}

// ---------------------------------------------------------------------------
// Task
// ---------------------------------------------------------------------------

/// Creates a [Task] with sensible defaults.
Task makeTask({
  String? id,
  String? title,
  String? description,
  String? clientId,
  String? clientName,
  TaskType? taskType,
  TaskPriority? priority,
  TaskStatus? status,
  String? assignedTo,
  String? assignedBy,
  DateTime? dueDate,
  DateTime? completedDate,
  DateTime? createdAt,
  List<String>? tags,
}) {
  return Task(
    id: id ?? _nextId('task'),
    title: title ?? 'File ITR for Test Client',
    description: description ?? 'Complete ITR-1 filing',
    clientId: clientId ?? 'client-1',
    clientName: clientName ?? 'Test Client',
    taskType: taskType ?? TaskType.itrFiling,
    priority: priority ?? TaskPriority.medium,
    status: status ?? TaskStatus.todo,
    assignedTo: assignedTo ?? 'Ankit Sharma',
    assignedBy: assignedBy ?? 'Rajesh Patel',
    dueDate: dueDate ?? DateTime(2025, 7, 31),
    completedDate: completedDate,
    createdAt: createdAt ?? DateTime(2025, 1, 15, 10, 0),
    tags: tags ?? const ['itr', 'fy2024-25'],
  );
}

// ---------------------------------------------------------------------------
// ComplianceDeadline
// ---------------------------------------------------------------------------

/// Creates a [ComplianceDeadline] with sensible defaults.
ComplianceDeadline makeComplianceDeadline({
  String? id,
  String? title,
  String? description,
  ComplianceCategory? category,
  DateTime? dueDate,
  List<String>? applicableTo,
  bool? isRecurring,
  ComplianceFrequency? frequency,
  ComplianceStatus? status,
}) {
  return ComplianceDeadline(
    id: id ?? _nextId('compliance'),
    title: title ?? 'GSTR-3B Filing',
    description: description ?? 'Monthly GST return filing',
    category: category ?? ComplianceCategory.gst,
    dueDate: dueDate ?? DateTime(2025, 2, 20),
    applicableTo: applicableTo ?? const ['All GST registered clients'],
    isRecurring: isRecurring ?? true,
    frequency: frequency ?? ComplianceFrequency.monthly,
    status: status ?? ComplianceStatus.upcoming,
  );
}

// ---------------------------------------------------------------------------
// Document
// ---------------------------------------------------------------------------

/// Creates a [Document] with sensible defaults.
Document makeDocument({
  String? id,
  String? clientId,
  String? clientName,
  String? title,
  DocumentCategory? category,
  DocumentFileType? fileType,
  int? fileSize,
  String? uploadedBy,
  DateTime? uploadedAt,
  List<String>? tags,
  bool? isSharedWithClient,
  int? downloadCount,
  int? version,
  String? remarks,
}) {
  return Document(
    id: id ?? _nextId('doc'),
    clientId: clientId ?? 'client-1',
    clientName: clientName ?? 'Test Client',
    title: title ?? 'ITR Acknowledgement AY 2024-25',
    category: category ?? DocumentCategory.taxReturns,
    fileType: fileType ?? DocumentFileType.pdf,
    fileSize: fileSize ?? 524288,
    uploadedBy: uploadedBy ?? 'Ankit Sharma',
    uploadedAt: uploadedAt ?? DateTime(2025, 1, 15, 10, 0),
    tags: tags ?? const ['itr', 'ay2024-25'],
    isSharedWithClient: isSharedWithClient ?? false,
    downloadCount: downloadCount ?? 0,
    version: version ?? 1,
    remarks: remarks,
  );
}
