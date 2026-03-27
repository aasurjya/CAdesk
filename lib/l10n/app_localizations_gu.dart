// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Gujarati (`gu`).
class AppLocalizationsGu extends AppLocalizations {
  AppLocalizationsGu([String locale = 'gu']) : super(locale);

  @override
  String get appTitle => 'CADesk';

  @override
  String get tabFiling => 'ફાઇલિંગ';

  @override
  String get tabClients => 'ક્લાયન્ટ';

  @override
  String get tabToday => 'આજ';

  @override
  String get tabDocuments => 'દસ્તાવેજ';

  @override
  String get tabMore => 'વધુ';

  @override
  String get addClient => 'ક્લાયન્ટ ઉમેરો';

  @override
  String get searchHint => 'શોધો…';

  @override
  String get searchClientsHint => 'નામ, PAN, ફોન શોધો…';

  @override
  String get searchDocumentsHint => 'દસ્તાવેજ, ક્લાયન્ટ શોધો…';

  @override
  String clientCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ક્લાયન્ટ',
      one: '1 ક્લાયન્ટ',
    );
    return '$_temp0';
  }

  @override
  String get statusAll => 'બધા';

  @override
  String get statusActive => 'સક્રિય';

  @override
  String get statusInactive => 'નિષ્ક્રિય';

  @override
  String get statusProspect => 'સંભવિત';

  @override
  String get clientTypeIndividual => 'વ્યક્તિગત';

  @override
  String get clientTypeCompany => 'કંપની';

  @override
  String get clientTypeFirm => 'ફર્મ';

  @override
  String get clientTypeLlp => 'LLP';

  @override
  String get retry => 'ફરી પ્રયાસ';

  @override
  String get failedToLoadClients => 'ક્લાયન્ટ લોડ કરવામાં નિષ્ફળ';

  @override
  String get noClientsYet => 'હજી સુધી કોઈ ક્લાયન્ટ નથી';

  @override
  String get noClientsMatchFilter => 'આપના ફિલ્ટર સાથે કોઈ ક્લાયન્ટ મળ્યો નથી';

  @override
  String get addFirstClient => 'શરૂ કરવા આપનો પ્રથમ ક્લાયન્ટ ઉમેરો';

  @override
  String get adjustFilters => 'આપની શોધ અથવા ફિલ્ટર સમાયોજિત કરો';

  @override
  String documentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count દસ્તાવેજ',
      one: '1 દસ્તાવેજ',
    );
    return '$_temp0';
  }

  @override
  String get uploadDocument => 'અપલોડ';

  @override
  String get allDocuments => 'બધા દસ્તાવેજ';

  @override
  String get folders => 'ફોલ્ડર';

  @override
  String get noDocumentsFound => 'કોઈ દસ્તાવેજ મળ્યો નથી';

  @override
  String get noFoldersFound => 'કોઈ ફોલ્ડર મળ્યો નથી';

  @override
  String get sortBy => 'આ અનુસાર ગોઠવો';

  @override
  String filingYear(String year) {
    return 'નાણાં વર્ષ $year';
  }

  @override
  String assessmentYear(String year) {
    return 'મૂલ્યાંકન વર્ષ $year';
  }

  @override
  String get next => 'આગળ';

  @override
  String get back => 'પાછળ';

  @override
  String get save => 'સાચવો';

  @override
  String get cancel => 'રદ કરો';

  @override
  String get confirm => 'પુષ્ટિ કરો';

  @override
  String get delete => 'કાઢી નાખો';

  @override
  String get edit => 'સંપાદિત કરો';

  @override
  String confirmDeleteTitle(String name) {
    return '$name કાઢી નાખો?';
  }

  @override
  String get confirmDeleteMessage => 'આ ક્રિયા પૂર્વવત્ કરી શકાતી નથી.';

  @override
  String get itrFiling => 'ITR ફાઇલિંગ';

  @override
  String get gstFiling => 'GST ફાઇલિંગ';

  @override
  String get tdsFiling => 'TDS ફાઇલિંગ';

  @override
  String get personalInfo => 'વ્યક્તિગત માહિતી';

  @override
  String get salaryIncome => 'વેતન આવક';

  @override
  String get houseProperty => 'ઘર મિલ્કત';

  @override
  String get capitalGains => 'મૂડી લાભ';

  @override
  String get deductions => 'કપાત';

  @override
  String get taxComputation => 'કર ગણતરી';

  @override
  String get reviewAndExport => 'સમીક્ષા અને નિકાસ';

  @override
  String get gstin => 'GSTIN';

  @override
  String get pan => 'PAN';

  @override
  String get tan => 'TAN';

  @override
  String get invalidGstin => 'અમાન્ય GSTIN ફોર્મેટ';

  @override
  String get invalidPan => 'અમાન્ય PAN ફોર્મેટ';

  @override
  String get requiredField => 'આ ક્ષેત્ર જરૂરી છે';

  @override
  String get caGptHint => 'CA GPT ને પૂછો…';

  @override
  String deadlineDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days દિવસ બાકી',
      one: '1 દિવસ બાકી',
      zero: 'આજ ચૂકવણી',
    );
    return '$_temp0';
  }

  @override
  String penaltyWarning(String amount) {
    return 'દંડ: ₹$amount';
  }

  @override
  String get riskHigh => 'ઊંચું જોખમ';

  @override
  String get riskMedium => 'મધ્યમ જોખમ';

  @override
  String get riskLow => 'ઓછું જોખમ';

  @override
  String get portalConnected => 'જોડાયેલ';

  @override
  String get portalDisconnected => 'જોડાયેલ નથી';

  @override
  String get exportSuccess => 'નિકાસ સફળ';

  @override
  String exportFailed(String reason) {
    return 'નિકાસ નિષ્ફળ: $reason';
  }

  @override
  String get totalBilled => 'કુલ બિલ';

  @override
  String get outstanding => 'બાકી';

  @override
  String get overdue => 'વિલંબિત';

  @override
  String get complianceCalendar => 'અનુપાલન કૅલેન્ડર';

  @override
  String get upcomingDeadlines => 'આવનારી સમય-મર્યાદા';

  @override
  String get noUpcomingDeadlines => 'કોઈ આવનારી સમય-મર્યાદા નથી';

  @override
  String get practiceManagement => 'પ્રેક્ટિસ મેનેજમેન્ટ';

  @override
  String get kanbanBoard => 'કાનબાન બોર્ડ';

  @override
  String get addTask => 'કાર્ય ઉમેરો';

  @override
  String get taskTitle => 'કાર્ય શીર્ષક';

  @override
  String get assignee => 'સોંપાયેલ';

  @override
  String get dueDate => 'ચૂકવણી તારીખ';

  @override
  String get priorityHigh => 'ઊંચી';

  @override
  String get priorityMedium => 'મધ્યમ';

  @override
  String get priorityLow => 'ઓછી';

  @override
  String get signIn => 'સાઇન ઇન';

  @override
  String get signUp => 'સાઇન અપ';

  @override
  String get forgotPassword => 'પાસવર્ડ ભૂલ્યા?';

  @override
  String get email => 'ઇમેઇલ';

  @override
  String get password => 'પાસવર્ડ';

  @override
  String get fullName => 'પૂરું નામ';
}
