/// Category of a client query/ticket.
enum QueryCategory {
  tax('Tax'),
  gst('GST'),
  compliance('Compliance'),
  billing('Billing'),
  general('General');

  const QueryCategory(this.label);

  final String label;
}

/// Priority level for a client query.
enum QueryPriority {
  low('Low'),
  medium('Medium'),
  high('High'),
  urgent('Urgent');

  const QueryPriority(this.label);

  final String label;
}

/// Status of a client query/ticket.
enum QueryStatus {
  open('Open'),
  inProgress('In Progress'),
  awaitingClient('Awaiting Client'),
  resolved('Resolved'),
  closed('Closed');

  const QueryStatus(this.label);

  final String label;
}

/// Represents a client query/support ticket with threaded messages.
class ClientQuery {
  const ClientQuery({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.subject,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.assignedTo,
    this.resolvedAt,
    this.messages = const [],
  });

  final String id;
  final String clientId;
  final String clientName;
  final String subject;
  final String description;
  final QueryCategory category;
  final QueryPriority priority;
  final QueryStatus status;
  final String? assignedTo;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final List<String> messages;

  bool get isOpen =>
      status == QueryStatus.open || status == QueryStatus.inProgress;

  ClientQuery copyWith({
    String? id,
    String? clientId,
    String? clientName,
    String? subject,
    String? description,
    QueryCategory? category,
    QueryPriority? priority,
    QueryStatus? status,
    String? assignedTo,
    DateTime? createdAt,
    DateTime? resolvedAt,
    List<String>? messages,
  }) {
    return ClientQuery(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      messages: messages ?? this.messages,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClientQuery && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
