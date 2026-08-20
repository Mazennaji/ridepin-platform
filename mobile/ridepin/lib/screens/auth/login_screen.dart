import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  late final AnimationController _entrance;
  late final AnimationController _glow;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _glow = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _entrance.dispose();
    _glow.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_email.text.trim(), _password.text);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Could not sign in'),
          backgroundColor: AppColors.surfaceAlt,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().loading;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.surface, AppColors.bg],
              ),
            ),
          ),
          // Animated pulsing glow
          AnimatedBuilder(
            animation: _glow,
            builder: (context, _) {
              return Positioned(
                top: -90,
                left: -70,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.signal.withValues(
                          alpha: 0.10 + 0.12 * _glow.value,
                        ),
                        AppColors.signal.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: _Animated(
                    controller: _entrance,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _GlowingMark(glow: _glow),
                        const SizedBox(height: 36),
                        _GlassCard(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Welcome back',
                                  style: TextStyle(
                                    color: AppColors.text,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.8,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Sign in to book or drive.',
                                  style: TextStyle(
                                    color: AppColors.textDim,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 28),
                                _label('EMAIL'),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _email,
                                  keyboardType: TextInputType.emailAddress,
                                  style: TextStyle(color: AppColors.text),
                                  decoration: InputDecoration(
                                    hintText: 'you@example.com',
                                    prefixIcon: Icon(
                                      Icons.mail_outline,
                                      color: AppColors.textFaint,
                                      size: 20,
                                    ),
                                  ),
                                  validator: (v) =>
                                      (v == null || !v.contains('@'))
                                      ? 'Enter a valid email'
                                      : null,
                                ),
                                const SizedBox(height: 18),
                                _label('PASSWORD'),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _password,
                                  obscureText: _obscure,
                                  style: TextStyle(color: AppColors.text),
                                  decoration: InputDecoration(
                                    hintText: '••••••••',
                                    prefixIcon: Icon(
                                      Icons.lock_outline,
                                      color: AppColors.textFaint,
                                      size: 20,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscure
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: AppColors.textFaint,
                                      ),
                                      onPressed: () =>
                                          setState(() => _obscure = !_obscure),
                                    ),
                                  ),
                                  validator: (v) => (v == null || v.isEmpty)
                                      ? 'Enter your password'
                                      : null,
                                ),
                                const SizedBox(height: 28),
                                _GlowButton(
                                  loading: loading,
                                  label: 'Sign in',
                                  onPressed: loading ? null : _submit,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "New to RidePin?",
                              style: TextStyle(color: AppColors.textDim),
                            ),
                            TextButton(
                              onPressed: loading
                                  ? null
                                  : () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const RegisterScreen(),
                                      ),
                                    ),
                              child: const Text('Create account'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(left: 4),
    child: Text(
      text,
      style: TextStyle(
        color: AppColors.textFaint,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.4,
      ),
    ),
  );
}

class _Animated extends StatelessWidget {
  final AnimationController controller;
  final Widget child;
  const _Animated({required this.controller, required this.child});

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(parent: controller, curve: Curves.easeOut);
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutCubic));
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: child),
    );
  }
}

class _GlowingMark extends StatelessWidget {
  final AnimationController glow;
  const _GlowingMark({required this.glow});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: glow,
        builder: (context, _) {
          return Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              color: AppColors.signal,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: AppColors.signal.withValues(
                    alpha: 0.35 + 0.25 * glow.value,
                  ),
                  blurRadius: 28 + 16 * glow.value,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.navigation_rounded,
              color: Color(0xFF1A1206),
              size: 38,
            ),
          );
        },
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.line.withValues(alpha: 0.8)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _GlowButton extends StatelessWidget {
  final bool loading;
  final String label;
  final VoidCallback? onPressed;
  const _GlowButton({
    required this.loading,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: loading
            ? []
            : [
                BoxShadow(
                  color: AppColors.signal.withValues(alpha: 0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        child: loading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Color(0xFF1A1206),
                ),
              )
            : Text(label),
      ),
    );
  }
}
