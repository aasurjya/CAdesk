// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'CADesk';

  @override
  String get tabFiling => 'फाइलिंग';

  @override
  String get tabClients => 'क्लाइंट';

  @override
  String get tabToday => 'आज';

  @override
  String get tabDocuments => 'दस्तावेज़';

  @override
  String get tabMore => 'अधिक';

  @override
  String get addClient => 'क्लाइंट जोड़ें';

  @override
  String get searchHint => 'खोजें…';

  @override
  String get searchClientsHint => 'नाम, PAN, फ़ोन खोजें…';

  @override
  String get searchDocumentsHint => 'दस्तावेज़, क्लाइंट खोजें…';

  @override
  String clientCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count क्लाइंट',
      one: '1 क्लाइंट',
    );
    return '$_temp0';
  }

  @override
  String get statusAll => 'सभी';

  @override
  String get statusActive => 'सक्रिय';

  @override
  String get statusInactive => 'निष्क्रिय';

  @override
  String get statusProspect => 'संभावित';

  @override
  String get clientTypeIndividual => 'व्यक्तिगत';

  @override
  String get clientTypeCompany => 'कंपनी';

  @override
  String get clientTypeFirm => 'फर्म';

  @override
  String get clientTypeLlp => 'LLP';

  @override
  String get retry => 'पुनः प्रयास';

  @override
  String get failedToLoadClients => 'क्लाइंट लोड करने में विफल';

  @override
  String get noClientsYet => 'अभी तक कोई क्लाइंट नहीं';

  @override
  String get noClientsMatchFilter => 'आपके फ़िल्टर से कोई क्लाइंट नहीं मिला';

  @override
  String get addFirstClient => 'शुरू करने के लिए अपना पहला क्लाइंट जोड़ें';

  @override
  String get adjustFilters => 'अपनी खोज या फ़िल्टर समायोजित करें';

  @override
  String documentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count दस्तावेज़',
      one: '1 दस्तावेज़',
    );
    return '$_temp0';
  }

  @override
  String get uploadDocument => 'अपलोड';

  @override
  String get allDocuments => 'सभी दस्तावेज़';

  @override
  String get folders => 'फ़ोल्डर';

  @override
  String get noDocumentsFound => 'कोई दस्तावेज़ नहीं मिला';

  @override
  String get noFoldersFound => 'कोई फ़ोल्डर नहीं मिला';

  @override
  String get sortBy => 'इसके अनुसार क्रमबद्ध करें';

  @override
  String filingYear(String year) {
    return 'वित्त वर्ष $year';
  }

  @override
  String assessmentYear(String year) {
    return 'निर्धारण वर्ष $year';
  }

  @override
  String get next => 'अगला';

  @override
  String get back => 'पिछला';

  @override
  String get save => 'सहेजें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get confirm => 'पुष्टि करें';

  @override
  String get delete => 'हटाएं';

  @override
  String get edit => 'संपादित करें';

  @override
  String confirmDeleteTitle(String name) {
    return '$name हटाएं?';
  }

  @override
  String get confirmDeleteMessage => 'यह क्रिया पूर्ववत नहीं की जा सकती।';

  @override
  String get itrFiling => 'ITR फाइलिंग';

  @override
  String get gstFiling => 'GST फाइलिंग';

  @override
  String get tdsFiling => 'TDS फाइलिंग';

  @override
  String get personalInfo => 'व्यक्तिगत जानकारी';

  @override
  String get salaryIncome => 'वेतन आय';

  @override
  String get houseProperty => 'गृह संपत्ति';

  @override
  String get capitalGains => 'पूंजीगत लाभ';

  @override
  String get deductions => 'कटौतियां';

  @override
  String get taxComputation => 'कर गणना';

  @override
  String get reviewAndExport => 'समीक्षा और निर्यात';

  @override
  String get gstin => 'GSTIN';

  @override
  String get pan => 'PAN';

  @override
  String get tan => 'TAN';

  @override
  String get invalidGstin => 'अमान्य GSTIN प्रारूप';

  @override
  String get invalidPan => 'अमान्य PAN प्रारूप';

  @override
  String get requiredField => 'यह फ़ील्ड आवश्यक है';

  @override
  String get caGptHint => 'CA GPT से पूछें…';

  @override
  String deadlineDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days दिन शेष',
      one: '1 दिन शेष',
      zero: 'आज देय',
    );
    return '$_temp0';
  }

  @override
  String penaltyWarning(String amount) {
    return 'जुर्माना: ₹$amount';
  }

  @override
  String get riskHigh => 'उच्च जोखिम';

  @override
  String get riskMedium => 'मध्यम जोखिम';

  @override
  String get riskLow => 'कम जोखिम';

  @override
  String get portalConnected => 'जुड़ा हुआ';

  @override
  String get portalDisconnected => 'जुड़ा नहीं';

  @override
  String get exportSuccess => 'निर्यात सफल';

  @override
  String exportFailed(String reason) {
    return 'निर्यात विफल: $reason';
  }

  @override
  String get totalBilled => 'कुल बिल';

  @override
  String get outstanding => 'बकाया';

  @override
  String get overdue => 'विलंबित';

  @override
  String get complianceCalendar => 'अनुपालन कैलेंडर';

  @override
  String get upcomingDeadlines => 'आगामी समय-सीमाएं';

  @override
  String get noUpcomingDeadlines => 'कोई आगामी समय-सीमा नहीं';

  @override
  String get practiceManagement => 'प्रैक्टिस प्रबंधन';

  @override
  String get kanbanBoard => 'कानबान बोर्ड';

  @override
  String get addTask => 'कार्य जोड़ें';

  @override
  String get taskTitle => 'कार्य शीर्षक';

  @override
  String get assignee => 'नियुक्त';

  @override
  String get dueDate => 'देय तिथि';

  @override
  String get priorityHigh => 'उच्च';

  @override
  String get priorityMedium => 'मध्यम';

  @override
  String get priorityLow => 'कम';

  @override
  String get signIn => 'साइन इन';

  @override
  String get signUp => 'साइन अप';

  @override
  String get forgotPassword => 'पासवर्ड भूल गए?';

  @override
  String get email => 'ईमेल';

  @override
  String get password => 'पासवर्ड';

  @override
  String get fullName => 'पूरा नाम';
}
