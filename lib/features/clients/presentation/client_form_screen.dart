import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import 'package:ca_app/features/clients/data/providers/client_providers.dart';
import 'package:ca_app/features/clients/data/providers/client_repository_providers.dart';
import 'package:ca_app/features/clients/domain/models/client.dart';
import 'package:ca_app/features/clients/domain/models/client_type.dart';

class ClientFormScreen extends ConsumerStatefulWidget {
  final String? clientId;

  const ClientFormScreen({this.clientId, super.key});

  @override
  ConsumerState<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends ConsumerState<ClientFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _panController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _alternatePhoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _gstinController = TextEditingController();
  final _tanController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _notesController = TextEditingController();

  ClientType _selectedType = ClientType.individual;
  ClientStatus _selectedStatus = ClientStatus.active;
  List<ServiceType> _selectedServices = const [];
  bool _isLoading = false;
  bool _isInitialized = false;

  bool get _isEditMode => widget.clientId != null;

  @override
  void dispose() {
    _nameController.dispose();
    _panController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _alternatePhoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _gstinController.dispose();
    _tanController.dispose();
    _aadhaarController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _initFromClient(Client client) {
    if (_isInitialized) return;
    _nameController.text = client.name;
    _panController.text = client.pan;
    _emailController.text = client.email ?? '';
    _phoneController.text = client.phone ?? '';
    _alternatePhoneController.text = client.alternatePhone ?? '';
    _addressController.text = client.address ?? '';
    _cityController.text = client.city ?? '';
    _stateController.text = client.state ?? '';
    _pincodeController.text = client.pincode ?? '';
    _gstinController.text = client.gstin ?? '';
    _tanController.text = client.tan ?? '';
    _aadhaarController.text = client.aadhaar ?? '';
    _notesController.text = client.notes ?? '';
    _selectedType = client.clientType;
    _selectedStatus = client.status;
    _selectedServices = List<ServiceType>.unmodifiable(client.servicesAvailed);
    _isInitialized = true;
  }

  void _toggleService(ServiceType service) {
    final current = List<ServiceType>.of(_selectedServices);
    if (current.contains(service)) {
      setState(() {
        _selectedServices = List.unmodifiable(
          current.where((s) => s != service).toList(),
        );
      });
    } else {
      setState(() {
        _selectedServices = List.unmodifiable([...current, service]);
      });
    }
  }

  String? _trimOrNull(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(clientRepositoryProvider);
      final now = DateTime.now();

      if (_isEditMode) {
        final existing = ref.read(clientByIdProvider(widget.clientId!));
        if (existing == null) {
          _showError('Client not found.');
          return;
        }
        final updated = existing.copyWith(
          name: _nameController.text.trim(),
          pan: _panController.text.trim().toUpperCase(),
          email: _trimOrNull(_emailController),
          phone: _trimOrNull(_phoneController),
          alternatePhone: _trimOrNull(_alternatePhoneController),
          address: _trimOrNull(_addressController),
          city: _trimOrNull(_cityController),
          state: _trimOrNull(_stateController),
          pincode: _trimOrNull(_pincodeController),
          gstin: _trimOrNull(_gstinController),
          tan: _trimOrNull(_tanController),
          aadhaar: _trimOrNull(_aadhaarController),
          notes: _trimOrNull(_notesController),
          clientType: _selectedType,
          status: _selectedStatus,
          servicesAvailed: _selectedServices,
          updatedAt: now,
        );
        final result = await repo.update(updated);
        ref.read(allClientsProvider.notifier).updateClient(result);
      } else {
        const uuid = Uuid();
        final newClient = Client(
          id: uuid.v4(),
          name: _nameController.text.trim(),
          pan: _panController.text.trim().toUpperCase(),
          email: _trimOrNull(_emailController),
          phone: _trimOrNull(_phoneController),
          alternatePhone: _trimOrNull(_alternatePhoneController),
          address: _trimOrNull(_addressController),
          city: _trimOrNull(_cityController),
          state: _trimOrNull(_stateController),
          pincode: _trimOrNull(_pincodeController),
          gstin: _trimOrNull(_gstinController),
          tan: _trimOrNull(_tanController),
          aadhaar: _trimOrNull(_aadhaarController),
          notes: _trimOrNull(_notesController),
          clientType: _selectedType,
          status: _selectedStatus,
          servicesAvailed: _selectedServices,
          createdAt: now,
          updatedAt: now,
        );
        await repo.create(newClient);
        ref.invalidate(allClientsProvider);
      }

      if (mounted) {
        final successMessage = _isEditMode
            ? 'Client updated successfully.'
            : 'Client created successfully.';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(successMessage)));
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/clients');
        }
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditMode) {
      final client = ref.watch(clientByIdProvider(widget.clientId!));
      if (client == null) {
        final clientsAsync = ref.watch(allClientsProvider);
        if (clientsAsync.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Edit Client')),
          body: const Center(child: Text('Client not found.')),
        );
      }
      _initFromClient(client);
    }

    final title = _isEditMode ? 'Edit Client' : 'New Client';
    final submitLabel = _isEditMode ? 'Update Client' : 'Create Client';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _SectionHeader(label: 'Basic Information'),
            const SizedBox(height: 12),
            _NameField(controller: _nameController),
            const SizedBox(height: 16),
            _PanField(controller: _panController),
            const SizedBox(height: 16),
            _ClientTypeDropdown(
              selected: _selectedType,
              onChanged: (type) {
                if (type != null) setState(() => _selectedType = type);
              },
            ),
            const SizedBox(height: 16),
            _StatusDropdown(
              selected: _selectedStatus,
              onChanged: (status) {
                if (status != null) setState(() => _selectedStatus = status);
              },
            ),
            const SizedBox(height: 24),
            const _SectionHeader(label: 'Contact Details'),
            const SizedBox(height: 12),
            _EmailField(controller: _emailController),
            const SizedBox(height: 16),
            _PhoneField(controller: _phoneController),
            const SizedBox(height: 16),
            _AlternatePhoneField(controller: _alternatePhoneController),
            const SizedBox(height: 16),
            _AddressField(controller: _addressController),
            const SizedBox(height: 16),
            _CityField(controller: _cityController),
            const SizedBox(height: 16),
            _StateField(controller: _stateController),
            const SizedBox(height: 16),
            _PincodeField(controller: _pincodeController),
            const SizedBox(height: 24),
            const _SectionHeader(label: 'Tax & Compliance'),
            const SizedBox(height: 12),
            _GstinField(controller: _gstinController),
            const SizedBox(height: 16),
            _TanField(controller: _tanController),
            const SizedBox(height: 16),
            _AadhaarField(controller: _aadhaarController),
            const SizedBox(height: 24),
            const _SectionHeader(label: 'Notes'),
            const SizedBox(height: 12),
            _NotesField(controller: _notesController),
            const SizedBox(height: 24),
            const _SectionHeader(label: 'Services Availed'),
            const SizedBox(height: 12),
            _ServicesChips(
              selected: _selectedServices,
              onToggle: _toggleService,
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(submitLabel),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Form fields
// ---------------------------------------------------------------------------

class _NameField extends StatelessWidget {
  const _NameField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      decoration: const InputDecoration(
        labelText: 'Full Name *',
        hintText: 'e.g. Rajesh Kumar Sharma',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.person_outline),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Name is required.';
        }
        return null;
      },
    );
  }
}

class _PanField extends StatelessWidget {
  const _PanField({required this.controller});

  final TextEditingController controller;

  static final _panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textCapitalization: TextCapitalization.characters,
      maxLength: 10,
      decoration: const InputDecoration(
        labelText: 'PAN *',
        hintText: 'ABCDE1234F',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.credit_card_outlined),
        counterText: '',
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'PAN is required.';
        }
        if (!_panRegex.hasMatch(value.trim().toUpperCase())) {
          return 'Enter a valid PAN (e.g. ABCDE1234F).';
        }
        return null;
      },
    );
  }
}

class _EmailField extends StatelessWidget {
  const _EmailField({required this.controller});

  final TextEditingController controller;

  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
  );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: 'Email',
        hintText: 'name@example.com',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.email_outlined),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return null;
        if (!_emailRegex.hasMatch(value.trim())) {
          return 'Enter a valid email address.';
        }
        return null;
      },
    );
  }
}

class _PhoneField extends StatelessWidget {
  const _PhoneField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      maxLength: 15,
      decoration: const InputDecoration(
        labelText: 'Phone',
        hintText: '9876543210',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.phone_outlined),
        counterText: '',
      ),
    );
  }
}

class _CityField extends StatelessWidget {
  const _CityField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      decoration: const InputDecoration(
        labelText: 'City',
        hintText: 'e.g. Mumbai',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.location_city_outlined),
      ),
    );
  }
}

class _StateField extends StatelessWidget {
  const _StateField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      decoration: const InputDecoration(
        labelText: 'State',
        hintText: 'e.g. Maharashtra',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.map_outlined),
      ),
    );
  }
}

class _AlternatePhoneField extends StatelessWidget {
  const _AlternatePhoneField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      maxLength: 15,
      decoration: const InputDecoration(
        labelText: 'Alternate Phone',
        hintText: '9876543210',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.phone_forwarded_outlined),
        counterText: '',
      ),
    );
  }
}

class _AddressField extends StatelessWidget {
  const _AddressField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textCapitalization: TextCapitalization.sentences,
      maxLines: 2,
      decoration: const InputDecoration(
        labelText: 'Address',
        hintText: 'e.g. 42, MG Road, Bandra West',
        border: OutlineInputBorder(),
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: 24),
          child: Icon(Icons.location_on_outlined),
        ),
        alignLabelWithHint: true,
      ),
    );
  }
}

class _PincodeField extends StatelessWidget {
  const _PincodeField({required this.controller});

  final TextEditingController controller;

  static final _pincodeRegex = RegExp(r'^\d{6}$');

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      maxLength: 6,
      decoration: const InputDecoration(
        labelText: 'Pincode',
        hintText: '400050',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.pin_drop_outlined),
        counterText: '',
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return null;
        if (!_pincodeRegex.hasMatch(value.trim())) {
          return 'Enter a valid 6-digit pincode.';
        }
        return null;
      },
    );
  }
}

class _GstinField extends StatelessWidget {
  const _GstinField({required this.controller});

  final TextEditingController controller;

  static final _gstinRegex = RegExp(r'^\d{2}[A-Z]{5}\d{4}[A-Z]\d[Z][A-Z\d]$');

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textCapitalization: TextCapitalization.characters,
      maxLength: 15,
      decoration: const InputDecoration(
        labelText: 'GSTIN',
        hintText: '27AABCA1234C1Z5',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.assignment_outlined),
        counterText: '',
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return null;
        if (!_gstinRegex.hasMatch(value.trim().toUpperCase())) {
          return 'Enter a valid 15-character GSTIN.';
        }
        return null;
      },
    );
  }
}

class _TanField extends StatelessWidget {
  const _TanField({required this.controller});

  final TextEditingController controller;

  static final _tanRegex = RegExp(r'^[A-Z]{4}\d{5}[A-Z]$');

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textCapitalization: TextCapitalization.characters,
      maxLength: 10,
      decoration: const InputDecoration(
        labelText: 'TAN',
        hintText: 'DELA12345B',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.badge_outlined),
        counterText: '',
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return null;
        if (!_tanRegex.hasMatch(value.trim().toUpperCase())) {
          return 'Enter a valid TAN (e.g. DELA12345B).';
        }
        return null;
      },
    );
  }
}

class _AadhaarField extends StatelessWidget {
  const _AadhaarField({required this.controller});

  final TextEditingController controller;

  static final _aadhaarRegex = RegExp(r'^\d{4}\s?\d{4}\s?\d{4}$');

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      maxLength: 14,
      decoration: const InputDecoration(
        labelText: 'Aadhaar',
        hintText: '1234 5678 9012',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.fingerprint_outlined),
        counterText: '',
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return null;
        if (!_aadhaarRegex.hasMatch(value.trim())) {
          return 'Enter a valid 12-digit Aadhaar number.';
        }
        return null;
      },
    );
  }
}

class _NotesField extends StatelessWidget {
  const _NotesField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textCapitalization: TextCapitalization.sentences,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: 'Notes',
        hintText: 'Any additional notes about the client...',
        border: OutlineInputBorder(),
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: 48),
          child: Icon(Icons.notes_outlined),
        ),
        alignLabelWithHint: true,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dropdowns
// ---------------------------------------------------------------------------

class _ClientTypeDropdown extends StatelessWidget {
  const _ClientTypeDropdown({required this.selected, required this.onChanged});

  final ClientType selected;
  final ValueChanged<ClientType?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<ClientType>(
      initialValue: selected,
      decoration: const InputDecoration(
        labelText: 'Client Type *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.business_center_outlined),
      ),
      items: ClientType.values.map((type) {
        return DropdownMenuItem(value: type, child: Text(type.label));
      }).toList(),
      onChanged: onChanged,
      validator: (v) {
        if (v == null) return 'Client type is required.';
        return null;
      },
    );
  }
}

class _StatusDropdown extends StatelessWidget {
  const _StatusDropdown({required this.selected, required this.onChanged});

  final ClientStatus selected;
  final ValueChanged<ClientStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<ClientStatus>(
      initialValue: selected,
      decoration: const InputDecoration(
        labelText: 'Status *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.toggle_on_outlined),
      ),
      items: ClientStatus.values.map((status) {
        return DropdownMenuItem(value: status, child: Text(status.label));
      }).toList(),
      onChanged: onChanged,
      validator: (v) {
        if (v == null) return 'Status is required.';
        return null;
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Services multi-select chips
// ---------------------------------------------------------------------------

class _ServicesChips extends StatelessWidget {
  const _ServicesChips({required this.selected, required this.onToggle});

  final List<ServiceType> selected;
  final ValueChanged<ServiceType> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ServiceType.values.map((service) {
        final isSelected = selected.contains(service);
        return FilterChip(
          label: Text(service.label),
          selected: isSelected,
          onSelected: (_) => onToggle(service),
          selectedColor: Theme.of(context).colorScheme.primaryContainer,
          checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
        );
      }).toList(),
    );
  }
}
