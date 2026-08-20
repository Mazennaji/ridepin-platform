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

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
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
          // Ambient gradient backdrop
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF12161F), AppColors.bg],
              ),
            ),
          ),
          // Soft signal glow, top-left
          Positioned(
            top: -80,
            left: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.signal.withValues(alpha: 0.18),
                    AppColors.signal.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Hero(),
                        const SizedBox(height: 40),
                        Text(
                          'Welcome back',
                          style: TextStyle(
                            color: AppColors.text,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.9,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign in to book a ride or hit the road.',
                          style: TextStyle(
                            color: AppColors.textDim,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 36),
                        _FieldLabel('EMAIL'),
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
                          validator: (v) => (v == null || !v.contains('@'))
                              ? 'Enter a valid email'
                              : null,
                        ),
                        const SizedBox(height: 18),
                        _FieldLabel('PASSWORD'),
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
                        const SizedBox(height: 32),
                        _GlowButton(
                          loading: loading,
                          onPressed: loading ? null : _submit,
                        ),
                        const SizedBox(height: 24),
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
}

class _Hero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.signal,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.signal.withValues(alpha: 0.45),
                blurRadius: 32,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.navigation_rounded,
            color: Color(0xFF1A1206),
            size: 38,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'RidePin',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
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
}

class _GlowButton extends StatelessWidget {
  final bool loading;
  final VoidCallback? onPressed;
  const _GlowButton({required this.loading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: loading
            ? []
            : [
                BoxShadow(
                  color: AppColors.signal.withValues(alpha: 0.35),
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
            : const Text('Sign in'),
      ),
    );
  }
}
