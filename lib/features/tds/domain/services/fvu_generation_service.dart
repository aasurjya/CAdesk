import 'package:ca_app/features/tds/domain/models/fvu/fvu_batch_header.dart';
import 'package:ca_app/features/tds/domain/models/fvu/fvu_challan_record.dart';
import 'package:ca_app/features/tds/domain/models/fvu/fvu_deductee_record.dart';
import 'package:ca_app/features/tds/domain/models/fvu/fvu_file_structure.dart';

/// Static service for generating NSDL TIN 2.0 fixed-width FVU file content.
///
/// The FVU (File Validation Utility) format is a text file with fixed-width
/// records, one per line. Record types: BH (batch header), CD (challan detail),
/// DD (deductee detail), BT (batch trailer).
class FvuGenerationService {
  FvuGenerationService._();

  // ---------------------------------------------------------------------------
  // Field widths (per NSDL TIN 2.0 spec)
  // ---------------------------------------------------------------------------

  static const int _tanWidth = 10;
  static const int _panWidth = 10;
  static const int _nameWidth = 40;
  static const int _fyWidth = 7;
  static const int _dateWidth = 8;
  static const int _countWidth = 10;
  static const int _amountWidth = 15;
  static const int _bsrWidth = 7;
  static const int _challanSerialWidth = 10;
  static const int _sectionWidth = 10;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Generates the complete FVU file content as a newline-delimited string.
  ///
  /// The output contains:
  /// - One BH (batch header) line
  /// - For each challan: one CD line followed by its DD lines
  /// - One BT (batch trailer) line
  static String generate(FvuFileStructure structure) {
    final buffer = StringBuffer();

    buffer.writeln(_buildBhRecord(structure.batchHeader));

    for (final group in structure.challans) {
      buffer.writeln(_buildCdRecord(group.challan));
      for (final deductee in group.deductees) {
        buffer.writeln(_buildDdRecord(deductee));
      }
    }

    buffer.write(_buildBtRecord(structure));

    return buffer.toString();
  }

  /// Formats a monetary amount as a 15-digit zero-padded integer string
  /// (no decimal point; last 2 digits represent paise).
  ///
  /// Example: 25000.50 → "000000002500050"
  static String formatAmount(double amount) {
    final paise = (amount * 100).round();
    return paise.toString().padLeft(_amountWidth, '0');
  }

  /// Right-pads [value] with spaces to exactly [width] characters.
  /// Truncates to [width] if [value] is longer.
  static String padRight(String value, int width) {
    if (value.length >= width) return value.substring(0, width);
    return value.padRight(width);
  }

  /// Left-pads [value] with zeros to exactly [width] characters.
  /// Truncates to [width] if [value] is longer.
  static String padLeft(String value, int width) {
    if (value.length >= width) return value.substring(0, width);
    return value.padLeft(width, '0');
  }

  // ---------------------------------------------------------------------------
  // BH record builder
  // ---------------------------------------------------------------------------

  static String _buildBhRecord(FvuBatchHeader header) {
    final buf = StringBuffer('BH');
    buf.write(padRight(header.tan, _tanWidth));
    buf.write(padRight(header.pan, _panWidth));
    buf.write(padRight(header.deductorName, _nameWidth));
    buf.write(padRight(header.financialYear, _fyWidth));
    buf.write(header.quarterNumber.toString());
    buf.write(padRight(header.formTypeCode, 2));
    buf.write(padRight(header.preparationDate, _dateWidth));
    buf.write(padLeft(header.totalChallans.toString(), _countWidth));
    buf.write(padLeft(header.totalDeductees.toString(), _countWidth));
    buf.write(formatAmount(header.totalTaxDeducted));
    return buf.toString();
  }

  // ---------------------------------------------------------------------------
  // CD record builder
  // ---------------------------------------------------------------------------

  static String _buildCdRecord(FvuChallanRecord challan) {
    final buf = StringBuffer('CD');
    buf.write(padRight(challan.bsrCode, _bsrWidth));
    buf.write(padRight(challan.challanTenderDate, _dateWidth));
    buf.write(padLeft(challan.challanSerialNumber, _challanSerialWidth));
    buf.write(formatAmount(challan.totalTaxDeposited));
    buf.write(padLeft(challan.deducteeCount.toString(), _countWidth));
    buf.write(padRight(challan.sectionCode, _sectionWidth));
    return buf.toString();
  }

  // ---------------------------------------------------------------------------
  // DD record builder
  // ---------------------------------------------------------------------------

  static String _buildDdRecord(FvuDeducteeRecord deductee) {
    final buf = StringBuffer('DD');
    buf.write(padRight(deductee.pan, _panWidth));
    buf.write(padRight(deductee.deducteeName, _nameWidth));
    buf.write(formatAmount(deductee.amountPaid));
    buf.write(formatAmount(deductee.tdsAmount));
    buf.write(padRight(deductee.dateOfPayment, _dateWidth));
    buf.write(padRight(deductee.sectionCode, _sectionWidth));
    buf.write(deductee.deducteeTypeCode.code);
    return buf.toString();
  }

  // ---------------------------------------------------------------------------
  // BT record builder
  // ---------------------------------------------------------------------------

  static String _buildBtRecord(FvuFileStructure structure) {
    final buf = StringBuffer('BT');
    buf.write(padLeft(structure.totalChallanCount.toString(), _countWidth));
    buf.write(padLeft(structure.totalDeducteeCount.toString(), _countWidth));
    buf.write(formatAmount(structure.totalTaxDeducted));
    return buf.toString();
  }
}
