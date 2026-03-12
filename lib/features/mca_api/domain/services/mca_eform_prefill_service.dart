import 'package:ca_app/features/mca/domain/models/aoc4_financial_statement.dart';
import 'package:ca_app/features/mca/domain/models/director_detail.dart';
import 'package:ca_app/features/mca/domain/models/mgt7_return.dart';

/// Stateless service that builds MCA portal form field maps from domain models.
///
/// Each method returns an unmodifiable [Map<String, String>] where keys are
/// the MCA portal field names and values are the pre-filled string values.
class McaEFormPrefillService {
  const McaEFormPrefillService();

  // -------------------------------------------------------------------------
  // MGT-7 Annual Return
  // -------------------------------------------------------------------------

  /// Builds the prefill map for an MGT-7 Annual Return form.
  ///
  /// Portal field names:
  /// - `cin`, `company_name`, `financial_year`, `agm_date`, `total_shareholders`
  Map<String, String> buildMgt7Prefill(Mgt7Return form) {
    final agmDate = form.agmDate;
    return Map<String, String>.unmodifiable({
      'cin': form.cin,
      'company_name': form.companyName,
      'financial_year': form.financialYear.toString(),
      'agm_date': agmDate != null ? _formatDdMmYyyy(agmDate) : '',
      'total_shareholders': form.shareholdingPattern.length.toString(),
    });
  }

  // -------------------------------------------------------------------------
  // AOC-4 Financial Statements
  // -------------------------------------------------------------------------

  /// Builds the prefill map for an AOC-4 Financial Statements form.
  ///
  /// Portal field names:
  /// - `cin`, `financial_year`, `total_assets`, `profit_loss`, `agm_date`
  Map<String, String> buildAoc4Prefill(Aoc4FinancialStatement form) {
    return Map<String, String>.unmodifiable({
      'cin': form.cin,
      'financial_year': form.financialYear.toString(),
      'total_assets': form.balanceSheetTotal.toString(),
      'profit_loss': form.profitAfterTax.toString(),
      'agm_date': _formatDdMmYyyy(form.agmDate),
    });
  }

  // -------------------------------------------------------------------------
  // DIR-3 KYC
  // -------------------------------------------------------------------------

  /// Builds the prefill map for a DIR-3 KYC form.
  ///
  /// Portal field names:
  /// - `din`, `name`, `dob`, `mobile`, `email`, `aadhaar`
  ///
  /// `mobile`, `email`, and `aadhaar` are left as empty-string placeholders
  /// because they are not available from the domain [DirectorDetail] model.
  Map<String, String> buildDir3KycPrefill(DirectorDetail director) {
    return Map<String, String>.unmodifiable({
      'din': director.din,
      'name': director.name,
      'dob': _formatDdMmYyyy(director.dateOfAppointment),
      'mobile': '',
      'email': '',
      'aadhaar': '',
    });
  }

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------

  /// Formats a [DateTime] as `DD/MM/YYYY` — the MCA portal's date format.
  String _formatDdMmYyyy(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }
}
