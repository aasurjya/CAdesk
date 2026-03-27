import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/filing/data/providers/itr2_form_providers.dart';
import 'package:ca_app/features/filing/domain/models/itr1/personal_info.dart';

/// ITR-2 personal info step — same fields as ITR-1 (PAN, Aadhaar, name,
/// DOB, address, email, phone, employer, bank account).
class Itr2PersonalInfoStep extends ConsumerStatefulWidget {
  const Itr2PersonalInfoStep({super.key});

  @override
  ConsumerState<Itr2PersonalInfoStep> createState() =>
      _Itr2PersonalInfoStepState();
}

class _Itr2PersonalInfoStepState extends ConsumerState<Itr2PersonalInfoStep> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _middleNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _panCtrl;
  late final TextEditingController _aadhaarCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _mobileCtrl;
  late final TextEditingController _flatCtrl;
  late final TextEditingController _streetCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _stateCtrl;
  late final TextEditingController _pincodeCtrl;
  late final TextEditingController _employerNameCtrl;
  late final TextEditingController _employerTanCtrl;
  late final TextEditingController _bankAccountCtrl;
  late final TextEditingController _bankIfscCtrl;
  late final TextEditingController _bankNameCtrl;

  DateTime _dob = DateTime(1990, 1, 1);

  @override
  void initState() {
    super.initState();
    final info = ref.read(itr2FormDataProvider).personalInfo;
    _firstNameCtrl = TextEditingController(text: info.firstName);
    _middleNameCtrl = TextEditingController(text: info.middleName);
    _lastNameCtrl = TextEditingController(text: info.lastName);
    _panCtrl = TextEditingController(text: info.pan);
    _aadhaarCtrl = TextEditingController(text: info.aadhaarNumber);
    _emailCtrl = TextEditingController(text: info.email);
    _mobileCtrl = TextEditingController(text: info.mobile);
    _flatCtrl = TextEditingController(text: info.flatDoorBlock);
    _streetCtrl = TextEditingController(text: info.street);
    _cityCtrl = TextEditingController(text: info.city);
    _stateCtrl = TextEditingController(text: info.state);
    _pincodeCtrl = TextEditingController(text: info.pincode);
    _employerNameCtrl = TextEditingController(text: info.employerName);
    _employerTanCtrl = TextEditingController(text: info.employerTan);
    _bankAccountCtrl = TextEditingController(text: info.bankAccountNumber);
    _bankIfscCtrl = TextEditingController(text: info.bankIfsc);
    _bankNameCtrl = TextEditingController(text: info.bankName);
    _dob = info.dateOfBirth;
  }

  @override
  void dispose() {
    for (final c in [
      _firstNameCtrl,
      _middleNameCtrl,
      _lastNameCtrl,
      _panCtrl,
      _aadhaarCtrl,
      _emailCtrl,
      _mobileCtrl,
      _flatCtrl,
      _streetCtrl,
      _cityCtrl,
      _stateCtrl,
      _pincodeCtrl,
      _employerNameCtrl,
      _employerTanCtrl,
      _bankAccountCtrl,
      _bankIfscCtrl,
      _bankNameCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _persistToProvider() {
    if (!_formKey.currentState!.validate()) return;
    final info = PersonalInfo(
      firstName: _firstNameCtrl.text.trim(),
      middleName: _middleNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      pan: _panCtrl.text.trim().toUpperCase(),
      aadhaarNumber: _aadhaarCtrl.text.trim(),
      dateOfBirth: _dob,
      email: _emailCtrl.text.trim(),
      mobile: _mobileCtrl.text.trim(),
      flatDoorBlock: _flatCtrl.text.trim(),
      street: _streetCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      state: _stateCtrl.text.trim(),
      pincode: _pincodeCtrl.text.trim(),
      employerName: _employerNameCtrl.text.trim(),
      employerTan: _employerTanCtrl.text.trim().toUpperCase(),
      bankAccountNumber: _bankAccountCtrl.text.trim(),
      bankIfsc: _bankIfscCtrl.text.trim().toUpperCase(),
      bankName: _bankNameCtrl.text.trim(),
    );
    ref.read(itr2FormDataProvider.notifier).updatePersonalInfo(info);
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob,
      firstDate: DateTime(1920),
      lastDate: DateTime(2010),
      helpText: 'Select Date of Birth',
    );
    if (picked != null) {
      setState(() => _dob = picked);
      _persistToProvider();
    }
  }

  Widget _field(
    String label,
    TextEditingController ctrl, {
    TextInputType keyboardType = TextInputType.text,
    bool required = false,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          hintText: hint,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        onChanged: (_) => _persistToProvider(),
        validator: required
            ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
            : null,
      ),
    );
  }

  Widget _sectionHeader(String title) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 8),
    child: Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
        fontSize: 13,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('Name'),
            _field('First Name', _firstNameCtrl, required: true),
            _field('Middle Name', _middleNameCtrl),
            _field('Last Name', _lastNameCtrl, required: true),
            _sectionHeader('Identity'),
            _field('PAN', _panCtrl, required: true, hint: 'ABCDE1234F'),
            _field(
              'Aadhaar Number',
              _aadhaarCtrl,
              hint: '1234 5678 9012',
              keyboardType: TextInputType.number,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: _pickDob,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth *',
                    border: OutlineInputBorder(),
                    isDense: true,
                    suffixIcon: Icon(Icons.calendar_today_outlined, size: 18),
                  ),
                  child: Text(
                    '${_dob.day.toString().padLeft(2, '0')}/'
                    '${_dob.month.toString().padLeft(2, '0')}/'
                    '${_dob.year}',
                  ),
                ),
              ),
            ),
            _sectionHeader('Contact'),
            _field(
              'Email',
              _emailCtrl,
              keyboardType: TextInputType.emailAddress,
            ),
            _field(
              'Mobile',
              _mobileCtrl,
              keyboardType: TextInputType.phone,
              required: true,
            ),
            _sectionHeader('Address'),
            _field('Flat / Door / Block No.', _flatCtrl),
            _field('Street / Locality', _streetCtrl),
            _field('City / Town / District', _cityCtrl, required: true),
            _field('State', _stateCtrl, required: true),
            _field('Pincode', _pincodeCtrl, keyboardType: TextInputType.number),
            _sectionHeader('Employer'),
            _field('Employer Name', _employerNameCtrl),
            _field('Employer TAN', _employerTanCtrl, hint: 'MUMR12345A'),
            _sectionHeader('Bank Account (for refund)'),
            _field(
              'Account Number',
              _bankAccountCtrl,
              keyboardType: TextInputType.number,
            ),
            _field('IFSC Code', _bankIfscCtrl, hint: 'SBIN0001234'),
            _field('Bank Name', _bankNameCtrl),
          ],
        ),
      ),
    );
  }
}
