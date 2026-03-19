import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ca_app/core/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// Mock data model
// ---------------------------------------------------------------------------

class _FirmProfile {
  const _FirmProfile({
    required this.firmName,
    required this.registrationNumber,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.phone,
    required this.email,
    required this.website,
    required this.gstNumber,
    required this.partners,
    required this.bankName,
    required this.bankAccountNumber,
    required this.bankIfsc,
    required this.bankBranch,
    required this.hasLogo,
    required this.letterheadTemplate,
  });

  final String firmName;
  final String registrationNumber;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String phone;
  final String email;
  final String website;
  final String gstNumber;
  final List<_Partner> partners;
  final String bankName;
  final String bankAccountNumber;
  final String bankIfsc;
  final String bankBranch;
  final bool hasLogo;
  final String letterheadTemplate;
}

class _Partner {
  const _Partner({
    required this.name,
    required this.membershipNumber,
    required this.designation,
  });

  final String name;
  final String membershipNumber;
  final String designation;
}

const _mockProfile = _FirmProfile(
  firmName: 'Sharma & Associates',
  registrationNumber: 'FRN-012345W',
  address: '301, Commerce House, M.G. Road',
  city: 'Mumbai',
  state: 'Maharashtra',
  pincode: '400001',
  phone: '+91 22 2345 6789',
  email: 'info@sharmaassociates.com',
  website: 'www.sharmaassociates.com',
  gstNumber: '27AABFS1234A1Z5',
  partners: [
    _Partner(
      name: 'CA Suresh Sharma',
      membershipNumber: 'M-123456',
      designation: 'Managing Partner',
    ),
    _Partner(
      name: 'CA Priya Iyer',
      membershipNumber: 'M-234567',
      designation: 'Senior Partner',
    ),
    _Partner(
      name: 'CA Rahul Desai',
      membershipNumber: 'M-345678',
      designation: 'Partner',
    ),
  ],
  bankName: 'HDFC Bank',
  bankAccountNumber: '50100123456789',
  bankIfsc: 'HDFC0001234',
  bankBranch: 'Fort Branch, Mumbai',
  hasLogo: true,
  letterheadTemplate: 'Professional A4',
);

/// Firm profile management screen with firm details, partner info,
/// GST registration, bank account, and letterhead settings.
class FirmProfileScreen extends ConsumerStatefulWidget {
  const FirmProfileScreen({super.key});

  @override
  ConsumerState<FirmProfileScreen> createState() => _FirmProfileScreenState();
}

class _FirmProfileScreenState extends ConsumerState<FirmProfileScreen> {
  bool _isEditing = false;

  void _toggleEdit() {
    setState(() => _isEditing = !_isEditing);
  }

  void _save() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Firm profile saved')));
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    const profile = _mockProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Firm Profile'),
        actions: [
          TextButton.icon(
            onPressed: _isEditing ? _save : _toggleEdit,
            icon: Icon(
              _isEditing ? Icons.check : Icons.edit_outlined,
              size: 18,
            ),
            label: Text(_isEditing ? 'Save' : 'Edit'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Logo section
          _LogoSection(hasLogo: profile.hasLogo, isEditing: _isEditing),
          const SizedBox(height: 20),

          // Firm details
          _SectionCard(
            title: 'Firm Details',
            icon: Icons.business_rounded,
            children: [
              _ProfileField(
                label: 'Firm Name',
                value: profile.firmName,
                isEditing: _isEditing,
              ),
              _ProfileField(
                label: 'Registration Number (FRN)',
                value: profile.registrationNumber,
                isEditing: _isEditing,
              ),
              _ProfileField(
                label: 'Address',
                value: profile.address,
                isEditing: _isEditing,
              ),
              Row(
                children: [
                  Expanded(
                    child: _ProfileField(
                      label: 'City',
                      value: profile.city,
                      isEditing: _isEditing,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ProfileField(
                      label: 'State',
                      value: profile.state,
                      isEditing: _isEditing,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 100,
                    child: _ProfileField(
                      label: 'PIN',
                      value: profile.pincode,
                      isEditing: _isEditing,
                    ),
                  ),
                ],
              ),
              _ProfileField(
                label: 'Phone',
                value: profile.phone,
                isEditing: _isEditing,
              ),
              _ProfileField(
                label: 'Email',
                value: profile.email,
                isEditing: _isEditing,
              ),
              _ProfileField(
                label: 'Website',
                value: profile.website,
                isEditing: _isEditing,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // GST details
          _SectionCard(
            title: 'GST Registration',
            icon: Icons.receipt_rounded,
            children: [
              _ProfileField(
                label: 'GSTIN',
                value: profile.gstNumber,
                isEditing: _isEditing,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Partners
          _PartnersSection(partners: profile.partners, isEditing: _isEditing),
          const SizedBox(height: 16),

          // Bank details
          _SectionCard(
            title: 'Bank Account (for Billing)',
            icon: Icons.account_balance_rounded,
            children: [
              _ProfileField(
                label: 'Bank Name',
                value: profile.bankName,
                isEditing: _isEditing,
              ),
              _ProfileField(
                label: 'Account Number',
                value: profile.bankAccountNumber,
                isEditing: _isEditing,
              ),
              _ProfileField(
                label: 'IFSC Code',
                value: profile.bankIfsc,
                isEditing: _isEditing,
              ),
              _ProfileField(
                label: 'Branch',
                value: profile.bankBranch,
                isEditing: _isEditing,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Letterhead settings
          _SectionCard(
            title: 'Letterhead & Template',
            icon: Icons.article_rounded,
            children: [
              _ProfileField(
                label: 'Active Template',
                value: profile.letterheadTemplate,
                isEditing: _isEditing,
              ),
              if (_isEditing)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.upload_rounded, size: 18),
                    label: const Text('Upload Custom Letterhead'),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),

          if (_isEditing)
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_rounded),
              label: const Text('Save Changes'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Logo section
// ---------------------------------------------------------------------------

class _LogoSection extends StatelessWidget {
  const _LogoSection({required this.hasLogo, required this.isEditing});

  final bool hasLogo;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.neutral200),
            ),
            child: hasLogo
                ? Icon(Icons.business, size: 36, color: AppColors.primary)
                : Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 36,
                    color: AppColors.neutral400,
                  ),
          ),
          if (isEditing) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {},
              child: Text(
                hasLogo ? 'Change Logo' : 'Upload Logo',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
          if (!isEditing && hasLogo) ...[
            const SizedBox(height: 8),
            Text(
              'Firm Logo',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.neutral400,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section card
// ---------------------------------------------------------------------------

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Partners section
// ---------------------------------------------------------------------------

class _PartnersSection extends StatelessWidget {
  const _PartnersSection({required this.partners, required this.isEditing});

  final List<_Partner> partners;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.people_rounded, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Partners',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...partners.map(
              (partner) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.neutral50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.neutral200),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primary.withAlpha(20),
                      child: Text(
                        partner.name.split(' ').last[0],
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            partner.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${partner.designation} \u2022 ${partner.membershipNumber}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.neutral400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isEditing)
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: AppColors.neutral400,
                        ),
                        onPressed: () {},
                      ),
                  ],
                ),
              ),
            ),
            if (isEditing)
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.person_add_outlined, size: 18),
                label: const Text('Add Partner'),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Profile field (view/edit mode)
// ---------------------------------------------------------------------------

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.label,
    required this.value,
    required this.isEditing,
  });

  final String label;
  final String value;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isEditing) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          initialValue: value,
          decoration: InputDecoration(labelText: label, isDense: true),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral400,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
