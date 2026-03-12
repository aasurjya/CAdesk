import 'package:ca_app/features/mca/domain/models/aoc4_financial_statement.dart';
import 'package:ca_app/features/mca/domain/models/mca_eform.dart';
import 'package:ca_app/features/mca/domain/models/mgt7_return.dart';

/// Stateless service for MCA e-form operations:
/// XML generation, penalty computation, and filing deadline lookup.
///
/// Penalty rate (Section 454, Companies Act 2013):
/// - ₹100 per day from due date (no upper cap for most forms post-2018)
/// - Amounts are returned in **paise** (1 ₹ = 100 paise) for precision.
class McaEFormService {
  McaEFormService._();

  static final McaEFormService instance = McaEFormService._();

  // -------------------------------------------------------------------------
  // XML generation
  // -------------------------------------------------------------------------

  /// Generate an MCA-compatible XML payload for an MGT-7 Annual Return.
  ///
  /// Root element is `<root>`, with child sections for company info,
  /// directors, shareholding, meetings, and penalties.
  String generateMgt7Xml(Mgt7Return form) {
    final buffer = StringBuffer();
    buffer.writeln('<root>');
    buffer.writeln('  <formType>MGT-7</formType>');
    buffer.writeln('  <company>');
    buffer.writeln('    <cin>${_escape(form.cin)}</cin>');
    buffer.writeln(
      '    <companyName>${_escape(form.companyName)}</companyName>',
    );
    buffer.writeln(
      '    <registeredOffice>${_escape(form.registeredOffice)}</registeredOffice>',
    );
    buffer.writeln('    <financialYear>${form.financialYear}</financialYear>');
    if (form.agmDate != null) {
      buffer.writeln('    <agmDate>${_formatDate(form.agmDate!)}</agmDate>');
    }
    buffer.writeln('  </company>');

    buffer.writeln('  <directors>');
    for (final director in form.directors) {
      buffer.writeln('    <director>');
      buffer.writeln('      <din>${_escape(director.din)}</din>');
      buffer.writeln('      <name>${_escape(director.name)}</name>');
      buffer.writeln(
        '      <designation>${_escape(director.designation)}</designation>',
      );
      buffer.writeln(
        '      <dateOfAppointment>${_formatDate(director.dateOfAppointment)}</dateOfAppointment>',
      );
      buffer.writeln(
        '      <shareholding>${director.shareholding}</shareholding>',
      );
      buffer.writeln('    </director>');
    }
    buffer.writeln('  </directors>');

    buffer.writeln('  <shareholdingPattern>');
    for (final entry in form.shareholdingPattern) {
      buffer.writeln('    <entry>');
      buffer.writeln(
        '      <category>${_escape(entry.category.name)}</category>',
      );
      buffer.writeln(
        '      <numberOfShares>${entry.numberOfShares}</numberOfShares>',
      );
      buffer.writeln('      <percentage>${entry.percentage}</percentage>');
      buffer.writeln('    </entry>');
    }
    buffer.writeln('  </shareholdingPattern>');

    buffer.writeln('  <meetings>');
    for (final meeting in form.meetings) {
      buffer.writeln('    <meeting>');
      buffer.writeln('      <type>${_escape(meeting.meetingType.name)}</type>');
      buffer.writeln('      <date>${_formatDate(meeting.date)}</date>');
      buffer.writeln('    </meeting>');
    }
    buffer.writeln('  </meetings>');

    buffer.writeln('  <penalties>');
    for (final penalty in form.penalties) {
      buffer.writeln('    <penalty>');
      buffer.writeln('      <section>${_escape(penalty.section)}</section>');
      buffer.writeln(
        '      <description>${_escape(penalty.description)}</description>',
      );
      buffer.writeln(
        '      <amountInRupees>${penalty.amountInRupees}</amountInRupees>',
      );
      buffer.writeln('    </penalty>');
    }
    buffer.writeln('  </penalties>');

    buffer.write('</root>');
    return buffer.toString();
  }

  /// Generate an MCA-compatible XML payload for an AOC-4 Financial Statement.
  String generateAoc4Xml(Aoc4FinancialStatement form) {
    final buffer = StringBuffer();
    buffer.writeln('<root>');
    buffer.writeln('  <formType>AOC-4</formType>');
    buffer.writeln('  <company>');
    buffer.writeln('    <cin>${_escape(form.cin)}</cin>');
    buffer.writeln('    <financialYear>${form.financialYear}</financialYear>');
    buffer.writeln(
      '    <auditReportDate>${_formatDate(form.auditReportDate)}</auditReportDate>',
    );
    buffer.writeln('    <agmDate>${_formatDate(form.agmDate)}</agmDate>');
    buffer.writeln('  </company>');

    buffer.writeln('  <financials>');
    buffer.writeln(
      '    <balanceSheetTotal>${form.balanceSheetTotal}</balanceSheetTotal>',
    );
    buffer.writeln(
      '    <profitAfterTax>${form.profitAfterTax}</profitAfterTax>',
    );
    buffer.writeln('    <dividendPaid>${form.dividendPaid}</dividendPaid>');
    buffer.writeln('  </financials>');

    buffer.writeln('  <auditQualifications>');
    for (final q in form.auditQualifications) {
      buffer.writeln('    <qualification>');
      buffer.writeln(
        '      <number>${_escape(q.qualificationNumber)}</number>',
      );
      buffer.writeln(
        '      <description>${_escape(q.description)}</description>',
      );
      buffer.writeln(
        '      <managementReply>${_escape(q.managementReply)}</managementReply>',
      );
      buffer.writeln('    </qualification>');
    }
    buffer.writeln('  </auditQualifications>');

    buffer.write('</root>');
    return buffer.toString();
  }

  // -------------------------------------------------------------------------
  // Penalty computation
  // -------------------------------------------------------------------------

  /// Compute the late filing penalty for [form] when filed on [filedDate].
  ///
  /// Returns the penalty amount in **paise** (₹1 = 100 paise).
  ///
  /// Rules (Section 454, Companies Act 2013 as amended):
  /// - Already-approved forms attract no penalty.
  /// - ₹100 per day (= 10,000 paise/day) from the day after the due date.
  int computePenalty(McaEForm form, DateTime filedDate) {
    // No penalty for approved forms
    if (form.status == EFormStatus.approved) return 0;

    final dueDate = getFilingDeadline(form.formType.label, _currentFy(form));
    if (!filedDate.isAfter(dueDate)) return 0;

    final daysLate = filedDate.difference(dueDate).inDays;
    // ₹100 per day × 100 paise/₹ = 10000 paise per day
    return daysLate * 10000;
  }

  // -------------------------------------------------------------------------
  // Filing deadlines
  // -------------------------------------------------------------------------

  /// Return the statutory filing deadline for [formType] in [financialYear].
  ///
  /// [financialYear] is the calendar year in which the FY ends.
  ///
  /// Deadlines (for March-end companies):
  /// - MGT-7:    60 days from AGM (September 30) → November 29
  /// - AOC-4:    30 days from AGM (September 30) → October 30
  ///   (MCA practice: October 29 from date perspective)
  /// - DIR-3 KYC: September 30 each year
  ///
  /// Returns a far-future date (December 31 of financialYear) for unknown forms.
  DateTime getFilingDeadline(String formType, int financialYear) {
    switch (formType.toUpperCase().trim()) {
      case 'MGT-7':
        // AGM by Sep 30; 60 days later = Nov 29
        return DateTime(financialYear, 11, 29);
      case 'AOC-4':
        // AGM by Sep 30; 30 days later = Oct 30; MCA uses Oct 29 in practice
        return DateTime(financialYear, 10, 29);
      case 'DIR-3 KYC':
        return DateTime(financialYear, 9, 30);
      case 'ADT-1':
        // Within 15 days from AGM (Oct 15 typically)
        return DateTime(financialYear, 10, 15);
      case 'MGT-14':
        // Within 30 days of board resolution
        // Return a representative date; actual deadline is event-based
        return DateTime(financialYear, 12, 31);
      default:
        return DateTime(financialYear, 12, 31);
    }
  }

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------

  /// Escape XML special characters in text content.
  String _escape(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  /// Format [date] as ISO-8601 date string (YYYY-MM-DD).
  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Extract the financial year from an [McaEForm] based on its creation date.
  int _currentFy(McaEForm form) {
    // FY ends in March; if created after April the year is the same calendar
    // year, otherwise use prior year.
    final created = form.createdAt;
    return created.month >= 4 ? created.year : created.year - 1;
  }
}
