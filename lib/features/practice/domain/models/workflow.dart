enum WorkflowCategory {
  itrFiling('ITR Filing'),
  gstFiling('GST Filing'),
  tdsFiling('TDS Filing'),
  audit('Audit'),
  payroll('Payroll'),
  mca('MCA'),
  other('Other');

  const WorkflowCategory(this.label);

  final String label;
}

class Workflow {
  const Workflow({
    required this.id,
    required this.name,
    required this.description,
    required this.steps,
    required this.estimatedDays,
    required this.category,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String description;
  final List<String> steps;
  final int estimatedDays;
  final WorkflowCategory category;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Workflow copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? steps,
    int? estimatedDays,
    WorkflowCategory? category,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Workflow(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      steps: steps ?? this.steps,
      estimatedDays: estimatedDays ?? this.estimatedDays,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Workflow && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
