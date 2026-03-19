import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_mr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('gu'),
    Locale('hi'),
    Locale('mr'),
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'CADesk'**
  String get appTitle;

  /// Bottom nav: Filing tab
  ///
  /// In en, this message translates to:
  /// **'Filing'**
  String get tabFiling;

  /// Bottom nav: Clients tab
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get tabClients;

  /// Bottom nav: Today tab
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get tabToday;

  /// Bottom nav: Documents tab
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get tabDocuments;

  /// Bottom nav: More tab
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get tabMore;

  /// FAB label on clients screen
  ///
  /// In en, this message translates to:
  /// **'Add Client'**
  String get addClient;

  /// Generic search hint text
  ///
  /// In en, this message translates to:
  /// **'Search…'**
  String get searchHint;

  /// Client search hint
  ///
  /// In en, this message translates to:
  /// **'Search name, PAN, phone…'**
  String get searchClientsHint;

  /// Documents search hint
  ///
  /// In en, this message translates to:
  /// **'Search documents, clients…'**
  String get searchDocumentsHint;

  /// Client list count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 client} other{{count} clients}}'**
  String clientCount(int count);

  /// Filter chip: All
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get statusAll;

  /// Filter chip: Active clients
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// Filter chip: Inactive clients
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get statusInactive;

  /// Filter chip: Prospect clients
  ///
  /// In en, this message translates to:
  /// **'Prospect'**
  String get statusProspect;

  /// Client type chip
  ///
  /// In en, this message translates to:
  /// **'Individual'**
  String get clientTypeIndividual;

  /// Client type chip
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get clientTypeCompany;

  /// Client type chip
  ///
  /// In en, this message translates to:
  /// **'Firm'**
  String get clientTypeFirm;

  /// Client type chip
  ///
  /// In en, this message translates to:
  /// **'LLP'**
  String get clientTypeLlp;

  /// Retry button label
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Error message on clients list
  ///
  /// In en, this message translates to:
  /// **'Failed to load clients'**
  String get failedToLoadClients;

  /// Empty state: no clients
  ///
  /// In en, this message translates to:
  /// **'No clients yet'**
  String get noClientsYet;

  /// Empty state: filter applied, no results
  ///
  /// In en, this message translates to:
  /// **'No clients match your filters'**
  String get noClientsMatchFilter;

  /// Empty state subtitle
  ///
  /// In en, this message translates to:
  /// **'Add your first client to get started'**
  String get addFirstClient;

  /// Empty state subtitle when filtering
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or filters'**
  String get adjustFilters;

  /// Document list count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 document} other{{count} documents}}'**
  String documentCount(int count);

  /// Upload FAB label
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get uploadDocument;

  /// Documents tab label
  ///
  /// In en, this message translates to:
  /// **'All Documents'**
  String get allDocuments;

  /// Folders tab label
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get folders;

  /// Empty state for documents
  ///
  /// In en, this message translates to:
  /// **'No documents found'**
  String get noDocumentsFound;

  /// Empty state for folders
  ///
  /// In en, this message translates to:
  /// **'No folders found'**
  String get noFoldersFound;

  /// Sort menu title
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// Financial year label
  ///
  /// In en, this message translates to:
  /// **'FY {year}'**
  String filingYear(String year);

  /// Assessment year label
  ///
  /// In en, this message translates to:
  /// **'AY {year}'**
  String assessmentYear(String year);

  /// Next button in wizards
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Back button in wizards
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Confirm button in dialogs
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Delete action
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Edit action
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Confirm delete dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String confirmDeleteTitle(String name);

  /// Confirm delete dialog message
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get confirmDeleteMessage;

  /// ITR filing section title
  ///
  /// In en, this message translates to:
  /// **'ITR Filing'**
  String get itrFiling;

  /// GST filing section title
  ///
  /// In en, this message translates to:
  /// **'GST Filing'**
  String get gstFiling;

  /// TDS filing section title
  ///
  /// In en, this message translates to:
  /// **'TDS Filing'**
  String get tdsFiling;

  /// Wizard step: Personal Info
  ///
  /// In en, this message translates to:
  /// **'Personal Info'**
  String get personalInfo;

  /// Wizard step: Salary
  ///
  /// In en, this message translates to:
  /// **'Salary Income'**
  String get salaryIncome;

  /// Wizard step: House Property
  ///
  /// In en, this message translates to:
  /// **'House Property'**
  String get houseProperty;

  /// Wizard step: Capital Gains
  ///
  /// In en, this message translates to:
  /// **'Capital Gains'**
  String get capitalGains;

  /// Wizard step: Deductions
  ///
  /// In en, this message translates to:
  /// **'Deductions'**
  String get deductions;

  /// Wizard step: Tax Computation
  ///
  /// In en, this message translates to:
  /// **'Tax Computation'**
  String get taxComputation;

  /// Wizard step: Review & Export
  ///
  /// In en, this message translates to:
  /// **'Review & Export'**
  String get reviewAndExport;

  /// GSTIN label
  ///
  /// In en, this message translates to:
  /// **'GSTIN'**
  String get gstin;

  /// PAN label
  ///
  /// In en, this message translates to:
  /// **'PAN'**
  String get pan;

  /// TAN label
  ///
  /// In en, this message translates to:
  /// **'TAN'**
  String get tan;

  /// GSTIN validation error
  ///
  /// In en, this message translates to:
  /// **'Invalid GSTIN format'**
  String get invalidGstin;

  /// PAN validation error
  ///
  /// In en, this message translates to:
  /// **'Invalid PAN format'**
  String get invalidPan;

  /// Required field validation error
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get requiredField;

  /// CA GPT input hint
  ///
  /// In en, this message translates to:
  /// **'Ask CA GPT…'**
  String get caGptHint;

  /// Deadline urgency label
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =0{Due today} =1{1 day left} other{{days} days left}}'**
  String deadlineDaysLeft(int days);

  /// Penalty amount warning on deadline card
  ///
  /// In en, this message translates to:
  /// **'Penalty: ₹{amount}'**
  String penaltyWarning(String amount);

  /// Risk level: High
  ///
  /// In en, this message translates to:
  /// **'High Risk'**
  String get riskHigh;

  /// Risk level: Medium
  ///
  /// In en, this message translates to:
  /// **'Medium Risk'**
  String get riskMedium;

  /// Risk level: Low
  ///
  /// In en, this message translates to:
  /// **'Low Risk'**
  String get riskLow;

  /// Portal connection status
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get portalConnected;

  /// Portal disconnection status
  ///
  /// In en, this message translates to:
  /// **'Not Connected'**
  String get portalDisconnected;

  /// Export success message
  ///
  /// In en, this message translates to:
  /// **'Export successful'**
  String get exportSuccess;

  /// Export failure message
  ///
  /// In en, this message translates to:
  /// **'Export failed: {reason}'**
  String exportFailed(String reason);

  /// Billing KPI label
  ///
  /// In en, this message translates to:
  /// **'Total Billed'**
  String get totalBilled;

  /// Outstanding amount label
  ///
  /// In en, this message translates to:
  /// **'Outstanding'**
  String get outstanding;

  /// Overdue status label
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// Compliance calendar section
  ///
  /// In en, this message translates to:
  /// **'Compliance Calendar'**
  String get complianceCalendar;

  /// Upcoming deadlines section
  ///
  /// In en, this message translates to:
  /// **'Upcoming Deadlines'**
  String get upcomingDeadlines;

  /// Empty state for deadlines
  ///
  /// In en, this message translates to:
  /// **'No upcoming deadlines'**
  String get noUpcomingDeadlines;

  /// Practice management section title
  ///
  /// In en, this message translates to:
  /// **'Practice Management'**
  String get practiceManagement;

  /// Kanban board title
  ///
  /// In en, this message translates to:
  /// **'Kanban Board'**
  String get kanbanBoard;

  /// Add task button
  ///
  /// In en, this message translates to:
  /// **'Add Task'**
  String get addTask;

  /// Task title field label
  ///
  /// In en, this message translates to:
  /// **'Task Title'**
  String get taskTitle;

  /// Assignee field label
  ///
  /// In en, this message translates to:
  /// **'Assignee'**
  String get assignee;

  /// Due date field label
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDate;

  /// Priority: High
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get priorityHigh;

  /// Priority: Medium
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get priorityMedium;

  /// Priority: Low
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priorityLow;

  /// Sign in button
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// Sign up button
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// Forgot password link
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Full name field label
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'gu', 'hi', 'mr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'gu':
      return AppLocalizationsGu();
    case 'hi':
      return AppLocalizationsHi();
    case 'mr':
      return AppLocalizationsMr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
