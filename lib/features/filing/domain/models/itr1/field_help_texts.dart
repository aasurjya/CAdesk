/// Contextual help text strings for ITR-1 form fields.
///
/// Each constant maps to a field in the ITR-1 wizard and provides
/// a concise explanation to assist the user while filling the form.
abstract final class Itr1HelpTexts {
  // ---- Personal Info ----
  static const pan =
      'Your 10-character Permanent Account Number (format: ABCDE1234F)';
  static const aadhaar = '12-digit unique identity number issued by UIDAI';
  static const dob = 'Date of birth as per PAN card records';
  static const employerTan =
      'Tax Deduction Account Number of your employer (format: MUMR12345A)';

  // ---- Salary Income ----
  static const grossSalary =
      'Total salary before any deductions, as shown in Form 16 Part B';
  static const hraExemption =
      'House Rent Allowance exemption under Section 10(13A). '
      'Includes HRA, LTA and other exempt allowances';
  static const perquisites =
      'Non-cash benefits provided by employer (e.g. car, accommodation)';
  static const profitsInLieu =
      'Any compensation received in lieu of salary, such as '
      'gratuity or leave encashment above exempt limits';

  // ---- Deductions ----
  static const section80C =
      'Investments up to \u20b91,50,000 in PPF, ELSS, LIC, NSC, '
      'tuition fees, home loan principal, etc.';
  static const section80CCD1B =
      'Additional NPS contribution up to \u20b950,000 over and above '
      'the \u20b91,50,000 limit under 80C';
  static const section80DSelf =
      'Health insurance premiums for self and family. '
      'Max \u20b925,000 (\u20b950,000 for senior citizens)';
  static const section80DParents =
      'Health insurance premiums for parents. '
      'Max \u20b925,000 (\u20b950,000 if parents are senior citizens)';
  static const section80E =
      'Interest paid on education loan for higher studies. '
      'No upper limit; available for up to 8 years';
  static const section80G =
      'Donations to approved charitable institutions. '
      'Deduction is 50% or 100% of the donated amount depending on the fund';
  static const section80TTA =
      'Interest earned on savings bank accounts up to \u20b910,000. '
      'Available for individuals below 60 years';
  static const section80TTB =
      'Interest on deposits (savings, FD, RD) up to \u20b950,000. '
      'Available only for senior citizens aged 60+';
}
