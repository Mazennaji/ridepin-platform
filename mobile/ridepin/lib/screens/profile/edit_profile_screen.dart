import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  final _password = TextEditingController();
  final _passwordConfirm = TextEditingController();

  late final TextEditingController _license;
  late final TextEditingController _vehicleType;
  late final TextEditingController _vehicleModel;
  late final TextEditingController _plate;

  bool _saving = false;

  bool get _isDriver =>
      (widget.user['role'] is Map ? widget.user['role']['name'] : '') ==
      'driver';

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.user['name']?.toString() ?? '');
    _phone = TextEditingController(
      text: widget.user['phone']?.toString() ?? '',
    );

    final dp = widget.user['driver_profile'] is Map
        ? Map<String, dynamic>.from(widget.user['driver_profile'])
        : <String, dynamic>{};
    _license = TextEditingController(
      text: dp['license_number']?.toString() ?? '',
    );
    _vehicleType = TextEditingController(
      text: dp['vehicle_type']?.toString() ?? '',
    );
    _vehicleModel = TextEditingController(
      text: dp['vehicle_model']?.toString() ?? '',
    );
    _plate = TextEditingController(text: dp['plate_number']?.toString() ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _password.dispose();
    _passwordConfirm.dispose();
    _license.dispose();
    _vehicleType.dispose();
    _vehicleModel.dispose();
    _plate.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final data = <String, dynamic>{
      'name': _name.text.trim(),
      'phone': _phone.text.trim(),
    };
    if (_password.text.isNotEmpty) {
      data['password'] = _password.text;
      data['password_confirmation'] = _passwordConfirm.text;
    }
    if (_isDriver) {
      data['license_number'] = _license.text.trim();
      data['vehicle_type'] = _vehicleType.text.trim();
      data['vehicle_model'] = _vehicleModel.text.trim();
      data['plate_number'] = _plate.text.trim();
    }

    final service = context.read<AuthService>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final res = await service.updateProfile(data);
    if (!mounted) return;
    setState(() => _saving = false);

    if (res.success) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Profile updated'),
          backgroundColor: AppColors.surfaceAlt,
        ),
      );
      navigator.pop(true);
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(res.error ?? 'Update failed'),
          backgroundColor: AppColors.surfaceAlt,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _label('Name'),
                    TextFormField(
                      controller: _name,
                      style: TextStyle(color: AppColors.text),
                      decoration: const InputDecoration(hintText: 'Full name'),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Enter your name'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _label('Phone'),
                    TextFormField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(color: AppColors.text),
                      decoration: const InputDecoration(
                        hintText: 'Phone (optional)',
                      ),
                    ),
                    if (_isDriver) ...[
                      const SizedBox(height: 24),
                      _sectionTitle('Vehicle'),
                      const SizedBox(height: 12),
                      _label('License number'),
                      TextFormField(
                        controller: _license,
                        style: TextStyle(color: AppColors.text),
                        decoration: const InputDecoration(
                          hintText: 'License number',
                        ),
                      ),
                      const SizedBox(height: 16),
                      _label('Vehicle type'),
                      TextFormField(
                        controller: _vehicleType,
                        style: TextStyle(color: AppColors.text),
                        decoration: const InputDecoration(
                          hintText: 'e.g. Sedan, SUV',
                        ),
                      ),
                      const SizedBox(height: 16),
                      _label('Vehicle model'),
                      TextFormField(
                        controller: _vehicleModel,
                        style: TextStyle(color: AppColors.text),
                        decoration: const InputDecoration(
                          hintText: 'e.g. Toyota Corolla 2020',
                        ),
                      ),
                      const SizedBox(height: 16),
                      _label('Plate number'),
                      TextFormField(
                        controller: _plate,
                        style: TextStyle(color: AppColors.text),
                        decoration: const InputDecoration(
                          hintText: 'Plate number',
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    _sectionTitle('Change password'),
                    const SizedBox(height: 4),
                    Text(
                      'Leave blank to keep your current password.',
                      style: TextStyle(
                        color: AppColors.textFaint,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _label('New password'),
                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      style: TextStyle(color: AppColors.text),
                      decoration: const InputDecoration(
                        hintText: 'New password',
                      ),
                      validator: (v) {
                        if (v != null && v.isNotEmpty && v.length < 8) {
                          return 'At least 8 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _label('Confirm new password'),
                    TextFormField(
                      controller: _passwordConfirm,
                      obscureText: true,
                      style: TextStyle(color: AppColors.text),
                      decoration: const InputDecoration(
                        hintText: 'Confirm password',
                      ),
                      validator: (v) {
                        if (_password.text.isNotEmpty && v != _password.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),
                    ElevatedButton(
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Color(0xFF1A1206),
                              ),
                            )
                          : const Text('Save changes'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 2),
    child: Text(
      text,
      style: TextStyle(
        color: AppColors.textDim,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  Widget _sectionTitle(String text) => Text(
    text.toUpperCase(),
    style: TextStyle(
      color: AppColors.textFaint,
      fontSize: 11,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.4,
    ),
  );
}
