import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/brand.dart';

class DriverHome extends StatelessWidget {
  const DriverHome({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: const BrandMark(size: 30),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textDim),
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Text(
          'Driver: ${auth.user?.name ?? ''}',
          style: const TextStyle(color: AppColors.text),
        ),
      ),
    );
  }
}
