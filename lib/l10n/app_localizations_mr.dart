// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Marathi (`mr`).
class AppLocalizationsMr extends AppLocalizations {
  AppLocalizationsMr([String locale = 'mr']) : super(locale);

  @override
  String get appTitle => 'CADesk';

  @override
  String get tabFiling => 'फाइलिंग';

  @override
  String get tabClients => 'क्लायंट';

  @override
  String get tabToday => 'आज';

  @override
  String get tabDocuments => 'दस्तऐवज';

  @override
  String get tabMore => 'अधिक';

  @override
  String get addClient => 'क्लायंट जोडा';

  @override
  String get searchHint => 'शोधा…';

  @override
  String get searchClientsHint => 'नाव, PAN, फोन शोधा…';

  @override
  String get searchDocumentsHint => 'दस्तऐवज, क्लायंट शोधा…';

  @override
  String clientCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count क्लायंट',
      one: '1 क्लायंट',
    );
    return '$_temp0';
  }

  @override
  String get statusAll => 'सर्व';

  @override
  String get statusActive => 'सक्रिय';

  @override
  String get statusInactive => 'निष्क्रिय';

  @override
  String get statusProspect => 'संभाव्य';

  @override
  String get clientTypeIndividual => 'वैयक्तिक';

  @override
  String get clientTypeCompany => 'कंपनी';

  @override
  String get clientTypeFirm => 'फर्म';

  @override
  String get clientTypeLlp => 'LLP';

  @override
  String get retry => 'पुन्हा प्रयत्न';

  @override
  String get failedToLoadClients => 'क्लायंट लोड करण्यात अयशस्वी';

  @override
  String get noClientsYet => 'अद्याप कोणताही क्लायंट नाही';

  @override
  String get noClientsMatchFilter => 'आपल्या फिल्टरशी जुळणारे क्लायंट नाहीत';

  @override
  String get addFirstClient => 'सुरू करण्यासाठी आपला पहिला क्लायंट जोडा';

  @override
  String get adjustFilters => 'आपली शोध किंवा फिल्टर समायोजित करा';

  @override
  String documentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count दस्तऐवज',
      one: '1 दस्तऐवज',
    );
    return '$_temp0';
  }

  @override
  String get uploadDocument => 'अपलोड';

  @override
  String get allDocuments => 'सर्व दस्तऐवज';

  @override
  String get folders => 'फोल्डर';

  @override
  String get noDocumentsFound => 'कोणताही दस्तऐवज आढळला नाही';

  @override
  String get noFoldersFound => 'कोणताही फोल्डर आढळला नाही';

  @override
  String get sortBy => 'यानुसार क्रमवारी';

  @override
  String filingYear(String year) {
    return 'आर्थिक वर्ष $year';
  }

  @override
  String assessmentYear(String year) {
    return 'मूल्यांकन वर्ष $year';
  }

  @override
  String get next => 'पुढे';

  @override
  String get back => 'मागे';

  @override
  String get save => 'जतन करा';

  @override
  String get cancel => 'रद्द करा';

  @override
  String get confirm => 'पुष्टी करा';

  @override
  String get delete => 'हटवा';

  @override
  String get edit => 'संपादित करा';

  @override
  String confirmDeleteTitle(String name) {
    return '$name हटवायचे?';
  }

  @override
  String get confirmDeleteMessage => 'ही क्रिया पूर्वत करता येणार नाही.';

  @override
  String get itrFiling => 'ITR फाइलिंग';

  @override
  String get gstFiling => 'GST फाइलिंग';

  @override
  String get tdsFiling => 'TDS फाइलिंग';

  @override
  String get personalInfo => 'वैयक्तिक माहिती';

  @override
  String get salaryIncome => 'वेतन उत्पन्न';

  @override
  String get houseProperty => 'घर मालमत्ता';

  @override
  String get capitalGains => 'भांडवली नफा';

  @override
  String get deductions => 'वजावट';

  @override
  String get taxComputation => 'कर गणना';

  @override
  String get reviewAndExport => 'पुनरावलोकन आणि निर्यात';

  @override
  String get gstin => 'GSTIN';

  @override
  String get pan => 'PAN';

  @override
  String get tan => 'TAN';

  @override
  String get invalidGstin => 'अवैध GSTIN स्वरूप';

  @override
  String get invalidPan => 'अवैध PAN स्वरूप';

  @override
  String get requiredField => 'हे क्षेत्र आवश्यक आहे';

  @override
  String get caGptHint => 'CA GPT ला विचारा…';

  @override
  String deadlineDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days दिवस शिल्लक',
      one: '1 दिवस शिल्लक',
      zero: 'आज देय',
    );
    return '$_temp0';
  }

  @override
  String penaltyWarning(String amount) {
    return 'दंड: ₹$amount';
  }

  @override
  String get riskHigh => 'उच्च धोका';

  @override
  String get riskMedium => 'मध्यम धोका';

  @override
  String get riskLow => 'कमी धोका';

  @override
  String get portalConnected => 'जोडलेले';

  @override
  String get portalDisconnected => 'जोडलेले नाही';

  @override
  String get exportSuccess => 'निर्यात यशस्वी';

  @override
  String exportFailed(String reason) {
    return 'निर्यात अयशस्वी: $reason';
  }

  @override
  String get totalBilled => 'एकूण बिल';

  @override
  String get outstanding => 'थकबाकी';

  @override
  String get overdue => 'विलंबित';

  @override
  String get complianceCalendar => 'अनुपालन कॅलेंडर';

  @override
  String get upcomingDeadlines => 'आगामी मुदती';

  @override
  String get noUpcomingDeadlines => 'कोणत्याही आगामी मुदती नाहीत';

  @override
  String get practiceManagement => 'प्रॅक्टिस व्यवस्थापन';

  @override
  String get kanbanBoard => 'कानबान बोर्ड';

  @override
  String get addTask => 'कार्य जोडा';

  @override
  String get taskTitle => 'कार्य शीर्षक';

  @override
  String get assignee => 'नियुक्त';

  @override
  String get dueDate => 'देय तारीख';

  @override
  String get priorityHigh => 'उच्च';

  @override
  String get priorityMedium => 'मध्यम';

  @override
  String get priorityLow => 'कमी';

  @override
  String get signIn => 'साइन इन';

  @override
  String get signUp => 'साइन अप';

  @override
  String get forgotPassword => 'पासवर्ड विसरलात?';

  @override
  String get email => 'ईमेल';

  @override
  String get password => 'पासवर्ड';

  @override
  String get fullName => 'पूर्ण नाव';
}
