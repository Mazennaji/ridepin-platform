import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final service = context.read<AuthService>();
    final data = await service.fetchProfile();
    if (mounted) {
      setState(() {
        _user = data;
        _loading = false;
      });
    }
  }

  String get _role =>
      (_user?['role'] is Map ? _user!['role']['name'] : '') as String? ?? '';

  Map<String, dynamic>? get _driverProfile => _user?['driver_profile'] is Map
      ? Map<String, dynamic>.from(_user!['driver_profile'])
      : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.signal),
            )
          : _user == null
          ? const Center(
              child: Text(
                'Could not load profile',
                style: TextStyle(color: AppColors.textDim),
              ),
            )
          : _content(),
    );
  }

  Widget _content() {
    final name = _user?['name'] as String? ?? '';
    final email = _user?['email'] as String? ?? '';
    final phone = _user?['phone'] as String?;
    final initials = name.isNotEmpty
        ? name.trim().split(' ').map((p) => p[0]).take(2).join().toUpperCase()
        : '?';
    final dp = _driverProfile;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      children: [
        Center(
          child: Column(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.signal,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Color(0xFF1A1206),
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                name,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.signal.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.signal.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  _role.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.signal,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _section('ACCOUNT'),
        _card([
          _row(Icons.email_outlined, 'Email', email),
          if (phone != null && phone.isNotEmpty)
            _row(Icons.phone_outlined, 'Phone', phone),
        ]),
        if (dp != null) ...[
          const SizedBox(height: 24),
          _section('VEHICLE'),
          _card([
            _row(
              Icons.badge_outlined,
              'License',
              dp['license_number']?.toString() ?? '—',
            ),
            _row(
              Icons.directions_car_outlined,
              'Vehicle',
              '${dp['vehicle_type'] ?? ''} · ${dp['vehicle_model'] ?? ''}',
            ),
            _row(
              Icons.pin_outlined,
              'Plate',
              dp['plate_number']?.toString() ?? '—',
            ),
            _row(
              dp['verification_status'] == true ||
                      dp['verification_status'] == 1
                  ? Icons.verified
                  : Icons.pending_outlined,
              'Verified',
              dp['verification_status'] == true ||
                      dp['verification_status'] == 1
                  ? 'Yes'
                  : 'Pending',
            ),
          ]),
        ],
        const SizedBox(height: 32),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.danger,
            minimumSize: const Size.fromHeight(52),
            side: const BorderSide(color: AppColors.danger),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: () => context.read<AuthProvider>().logout(),
          icon: const Icon(Icons.logout, size: 18),
          label: const Text(
            'Sign out',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _section(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textFaint,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
        ),
      ),
    );
  }

  Widget _card(List<Widget> rows) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(children: rows),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textDim),
          const SizedBox(width: 14),
          Text(label, style: const TextStyle(color: AppColors.textDim)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
