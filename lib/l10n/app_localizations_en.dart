// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CADesk';

  @override
  String get tabFiling => 'Filing';

  @override
  String get tabClients => 'Clients';

  @override
  String get tabToday => 'Today';

  @override
  String get tabDocuments => 'Documents';

  @override
  String get tabMore => 'More';

  @override
  String get addClient => 'Add Client';

  @override
  String get searchHint => 'Search…';

  @override
  String get searchClientsHint => 'Search name, PAN, phone…';

  @override
  String get searchDocumentsHint => 'Search documents, clients…';

  @override
  String clientCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count clients',
      one: '1 client',
    );
    return '$_temp0';
  }

  @override
  String get statusAll => 'All';

  @override
  String get statusActive => 'Active';

  @override
  String get statusInactive => 'Inactive';

  @override
  String get statusProspect => 'Prospect';

  @override
  String get clientTypeIndividual => 'Individual';

  @override
  String get clientTypeCompany => 'Company';

  @override
  String get clientTypeFirm => 'Firm';

  @override
  String get clientTypeLlp => 'LLP';

  @override
  String get retry => 'Retry';

  @override
  String get failedToLoadClients => 'Failed to load clients';

  @override
  String get noClientsYet => 'No clients yet';

  @override
  String get noClientsMatchFilter => 'No clients match your filters';

  @override
  String get addFirstClient => 'Add your first client to get started';

  @override
  String get adjustFilters => 'Try adjusting your search or filters';

  @override
  String documentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count documents',
      one: '1 document',
    );
    return '$_temp0';
  }

  @override
  String get uploadDocument => 'Upload';

  @override
  String get allDocuments => 'All Documents';

  @override
  String get folders => 'Folders';

  @override
  String get noDocumentsFound => 'No documents found';

  @override
  String get noFoldersFound => 'No folders found';

  @override
  String get sortBy => 'Sort by';

  @override
  String filingYear(String year) {
    return 'FY $year';
  }

  @override
  String assessmentYear(String year) {
    return 'AY $year';
  }

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String confirmDeleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get confirmDeleteMessage => 'This action cannot be undone.';

  @override
  String get itrFiling => 'ITR Filing';

  @override
  String get gstFiling => 'GST Filing';

  @override
  String get tdsFiling => 'TDS Filing';

  @override
  String get personalInfo => 'Personal Info';

  @override
  String get salaryIncome => 'Salary Income';

  @override
  String get houseProperty => 'House Property';

  @override
  String get capitalGains => 'Capital Gains';

  @override
  String get deductions => 'Deductions';

  @override
  String get taxComputation => 'Tax Computation';

  @override
  String get reviewAndExport => 'Review & Export';

  @override
  String get gstin => 'GSTIN';

  @override
  String get pan => 'PAN';

  @override
  String get tan => 'TAN';

  @override
  String get invalidGstin => 'Invalid GSTIN format';

  @override
  String get invalidPan => 'Invalid PAN format';

  @override
  String get requiredField => 'This field is required';

  @override
  String get caGptHint => 'Ask CA GPT…';

  @override
  String deadlineDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days left',
      one: '1 day left',
      zero: 'Due today',
    );
    return '$_temp0';
  }

  @override
  String penaltyWarning(String amount) {
    return 'Penalty: ₹$amount';
  }

  @override
  String get riskHigh => 'High Risk';

  @override
  String get riskMedium => 'Medium Risk';

  @override
  String get riskLow => 'Low Risk';

  @override
  String get portalConnected => 'Connected';

  @override
  String get portalDisconnected => 'Not Connected';

  @override
  String get exportSuccess => 'Export successful';

  @override
  String exportFailed(String reason) {
    return 'Export failed: $reason';
  }

  @override
  String get totalBilled => 'Total Billed';

  @override
  String get outstanding => 'Outstanding';

  @override
  String get overdue => 'Overdue';

  @override
  String get complianceCalendar => 'Compliance Calendar';

  @override
  String get upcomingDeadlines => 'Upcoming Deadlines';

  @override
  String get noUpcomingDeadlines => 'No upcoming deadlines';

  @override
  String get practiceManagement => 'Practice Management';

  @override
  String get kanbanBoard => 'Kanban Board';

  @override
  String get addTask => 'Add Task';

  @override
  String get taskTitle => 'Task Title';

  @override
  String get assignee => 'Assignee';

  @override
  String get dueDate => 'Due Date';

  @override
  String get priorityHigh => 'High';

  @override
  String get priorityMedium => 'Medium';

  @override
  String get priorityLow => 'Low';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get fullName => 'Full Name';
}
