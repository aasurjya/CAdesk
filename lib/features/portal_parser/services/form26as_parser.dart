import 'package:ca_app/features/portal_parser/models/form26as_data.dart';
import 'package:ca_app/features/portal_parser/models/tds_entry_26as.dart';

/// Stateless singleton parser for Form 26AS data downloaded from the TRACES
/// portal.  Supports XML (native portal download) and CSV (alternative TRACES
/// export) formats.
///
/// All monetary amounts in the returned models are in **paise**
/// (input rupee values are multiplied by 100).
class Form26AsParser {
  Form26AsParser._();

  static final Form26AsParser instance = Form26AsParser._();

  // --------------- public API ---------------

  /// Parses [xmlContent] (Form 26AS XML from TRACES portal) into [Form26AsData].
  Form26AsData parseXml(String xmlContent) {
    final pan = _extractTag(xmlContent, 'PAN');
    final assessmentYear = _extractTag(xmlContent, 'AssessmentYear');

    final tdsEntries = _parseTdsEntriesFromXml(xmlContent);
    final totalTds = tdsEntries.fold<int>(0, (sum, e) => sum + e.tdsDeducted);

    return Form26AsData(
      pan: pan,
      assessmentYear: assessmentYear,
      tdsEntries: tdsEntries,
      tcsTcsEntries: const [],
      advanceTaxEntries: const [],
      selfAssessmentEntries: const [],
      refundEntries: const [],
      totalTdsCredited: totalTds,
      totalTcsCredited: 0,
    );
  }

  /// Parses [csvContent] (TRACES alternative CSV export) into [Form26AsData].
  ///
  /// Expected CSV columns (with header row):
  /// pan, assessmentYear, tan, deductorName, section, amount, tdsDeducted,
  /// dateOfDeduction, status
  Form26AsData parseCsv(String csvContent) {
    final lines = csvContent
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    if (lines.length < 2) {
      // Header only — no data rows.
      final pan = _inferPanFromCsvRows(lines);
      return Form26AsData(
        pan: pan,
        assessmentYear: '',
        tdsEntries: const [],
        tcsTcsEntries: const [],
        advanceTaxEntries: const [],
        selfAssessmentEntries: const [],
        refundEntries: const [],
        totalTdsCredited: 0,
        totalTcsCredited: 0,
      );
    }

    // Skip header row (index 0); parse data rows.
    final dataRows = lines.skip(1).toList();
    final tdsEntries = dataRows
        .map(_parseCsvRow)
        .whereType<TdsEntry26As>()
        .toList();

    final pan = tdsEntries.isNotEmpty ? _extractPanFromCsvLine(lines[1]) : '';
    final assessmentYear = tdsEntries.isNotEmpty
        ? _extractAssessmentYearFromCsvLine(lines[1])
        : '';
    final totalTds = tdsEntries.fold<int>(0, (sum, e) => sum + e.tdsDeducted);

    return Form26AsData(
      pan: pan,
      assessmentYear: assessmentYear,
      tdsEntries: tdsEntries,
      tcsTcsEntries: const [],
      advanceTaxEntries: const [],
      selfAssessmentEntries: const [],
      refundEntries: const [],
      totalTdsCredited: totalTds,
      totalTcsCredited: 0,
    );
  }

  // --------------- XML helpers ---------------

  /// Returns the text content of the first occurrence of [tag] in [xml].
  /// Returns an empty string if the tag is not found.
  String _extractTag(String xml, String tag) {
    final open = '<$tag>';
    final close = '</$tag>';
    final start = xml.indexOf(open);
    if (start == -1) return '';
    final contentStart = start + open.length;
    final end = xml.indexOf(close, contentStart);
    if (end == -1) return '';
    return xml.substring(contentStart, end).trim();
  }

  /// Returns all text contents of every occurrence of [tag] in [xml].
  List<String> _extractAllBlocks(String xml, String tag) {
    final blocks = <String>[];
    final open = '<$tag>';
    final close = '</$tag>';
    int searchFrom = 0;
    while (true) {
      final start = xml.indexOf(open, searchFrom);
      if (start == -1) break;
      final contentStart = start + open.length;
      final end = xml.indexOf(close, contentStart);
      if (end == -1) break;
      blocks.add(xml.substring(contentStart, end).trim());
      searchFrom = end + close.length;
    }
    return blocks;
  }

  List<TdsEntry26As> _parseTdsEntriesFromXml(String xml) {
    final deductorBlocks = _extractAllBlocks(xml, 'DeductorDetails');
    return deductorBlocks.map(_parseDeductorBlock).toList();
  }

  TdsEntry26As _parseDeductorBlock(String block) {
    final tan = _extractTag(block, 'TAN');
    final name = _extractTag(block, 'DeductorName');
    final section = _extractTag(block, 'Section');
    final amountRupees = int.tryParse(_extractTag(block, 'PaidCredit')) ?? 0;
    final tdsRupees = int.tryParse(_extractTag(block, 'TaxDeducted')) ?? 0;
    final dateStr = _extractTag(block, 'DateOfDeduction');
    final statusCode = _extractTag(block, 'BookingStatus');

    return TdsEntry26As(
      deductorTan: tan,
      deductorName: name,
      section: section,
      amount: amountRupees * 100,
      tdsDeducted: tdsRupees * 100,
      dateOfDeduction: _parseDdMmYyyy(dateStr),
      status: BookingStatus.fromCode(statusCode),
    );
  }

  DateTime? _parseDdMmYyyy(String dateStr) {
    if (dateStr.isEmpty) return null;
    final parts = dateStr.split('-');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    return DateTime(year, month, day);
  }

  // --------------- CSV helpers ---------------

  // CSV column indices:
  // 0=pan, 1=assessmentYear, 2=tan, 3=deductorName, 4=section,
  // 5=amount, 6=tdsDeducted, 7=dateOfDeduction, 8=status

  TdsEntry26As? _parseCsvRow(String row) {
    final cols = row.split(',');
    if (cols.length < 9) return null;
    final amountRupees = int.tryParse(cols[5].trim()) ?? 0;
    final tdsRupees = int.tryParse(cols[6].trim()) ?? 0;
    return TdsEntry26As(
      deductorTan: cols[2].trim(),
      deductorName: cols[3].trim(),
      section: cols[4].trim(),
      amount: amountRupees * 100,
      tdsDeducted: tdsRupees * 100,
      dateOfDeduction: _parseDdMmYyyy(cols[7].trim()),
      status: BookingStatus.fromCode(cols[8].trim()),
    );
  }

  String _extractPanFromCsvLine(String line) {
    final cols = line.split(',');
    if (cols.isEmpty) return '';
    return cols[0].trim();
  }

  String _extractAssessmentYearFromCsvLine(String line) {
    final cols = line.split(',');
    if (cols.length < 2) return '';
    return cols[1].trim();
  }

  String _inferPanFromCsvRows(List<String> lines) {
    // When there is only a header row there is no PAN to infer.
    return '';
  }
}
