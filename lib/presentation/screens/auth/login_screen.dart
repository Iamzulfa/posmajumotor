import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/constants/app_constants.dart';
import '../../../config/constants/supabase_config.dart';
import '../../../config/routes/app_routes.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/auto_responsive.dart';
import '../../widgets/common/custom_button.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Check if Supabase is configured
    if (SupabaseConfig.isConfigured) {
      // Real login with Supabase
      final success = await ref
          .read(authProvider.notifier)
          .signIn(email, password);

      if (success && mounted) {
        final user = ref.read(authProvider).user;
        if (user?.role == 'ADMIN') {
          context.go(AppRoutes.adminMain);
        } else {
          context.go(AppRoutes.kasirMain);
        }
      }
    } else {
      // Demo mode - validate credentials and redirect
      const demoCredentials = {
        'admin@toko.com': 'admin123',
        'kasir@toko.com': 'kasir123',
      };

      if (demoCredentials[email] == password) {
        // Valid demo credentials
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          if (email == 'admin@toko.com') {
            context.go(AppRoutes.adminMain);
          } else {
            context.go(AppRoutes.kasirMain);
          }
        }
      } else {
        // Invalid demo credentials
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Invalid demo credentials. Please use the provided demo accounts.',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Show error snackbar if there's an error
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.error != null && previous?.error != next.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
          ),
        );
        ref.read(authProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AR.p(24), // Auto-responsive padding
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildLogo(),
                  AR.hCompact(32), // Compact vertical spacing
                  _buildEmailField(),
                  AR.hCompact(16), // Compact vertical spacing
                  _buildPasswordField(),
                  AR.hCompact(16), // Compact vertical spacing
                  _buildRememberMe(),
                  AR.hCompact(24), // Compact vertical spacing
                  _buildLoginButton(authState.isLoading),
                  AR.hCompact(16), // Compact vertical spacing
                  _buildForgotPassword(),
                  AR.hCompact(32), // Compact vertical spacing
                  _buildDemoCredentials(),
                  if (!SupabaseConfig.isConfigured) ...[
                    AR.hCompact(16), // Compact vertical spacing
                    _buildOfflineModeWarning(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        AContainer(
          width: 80,
          height: 80,
          borderRadius: 16,
          color: AppColors.primary,
          child: const Center(
            child: AText(
              'M',
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        AR.hCompact(16), // Compact spacing
        const AText(
          AppConstants.appName,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
        AR.hCompact(8), // Compact spacing
        const AText(
          'Kelola toko suku cadang Anda',
          fontSize: 14,
          color: AppColors.textGray,
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AText(
          'Email',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textDark,
        ),
        AR.hCompact(8), // Compact spacing
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          validator: AppValidators.validateEmail,
          decoration: InputDecoration(
            hintText: 'email@example.com',
            filled: true,
            fillColor: AppColors.backgroundLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                12.ar,
              ), // Auto-responsive radius
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AText(
          'Password',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textDark,
        ),
        AR.hCompact(8), // Compact spacing
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          validator: AppValidators.validatePassword,
          onFieldSubmitted: (_) => _handleLogin(),
          decoration: InputDecoration(
            hintText: '••••••••',
            filled: true,
            fillColor: AppColors.backgroundLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                12.ar,
              ), // Auto-responsive radius
              borderSide: BorderSide.none,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: AppColors.textGray,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRememberMe() {
    return Row(
      children: [
        SizedBox(
          width: 24.aw, // Auto-responsive width
          height: 24.ah, // Auto-responsive height
          child: Checkbox(
            value: _rememberMe,
            onChanged: (value) => setState(() => _rememberMe = value ?? false),
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                4.ar,
              ), // Auto-responsive radius
            ),
          ),
        ),
        AR.w(8), // Auto-responsive horizontal spacing
        const AText('Ingat saya', fontSize: 14, color: AppColors.textGray),
      ],
    );
  }

  Widget _buildLoginButton(bool isLoading) {
    return CustomButton(
      text: 'Masuk',
      onPressed: _handleLogin,
      isLoading: isLoading,
    );
  }

  Widget _buildForgotPassword() {
    return Center(
      child: TextButton(
        onPressed: () {},
        child: const Text(
          'Lupa Password?',
          style: TextStyle(color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildDemoCredentials() {
    return AContainer(
      padding: AR.p(16), // Auto-responsive padding
      borderRadius: 12, // Auto-responsive radius
      color: AppColors.backgroundLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AText(
            'Demo Credentials:',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textGray,
          ),
          AR.hCompact(8), // Compact spacing
          _buildCredentialRow('Admin', 'admin@toko.com', 'admin123'),
          AR.h(4), // Auto-responsive spacing
          _buildCredentialRow('Kasir', 'kasir@toko.com', 'kasir123'),
        ],
      ),
    );
  }

  Widget _buildCredentialRow(String role, String email, String password) {
    return Row(
      children: [
        SizedBox(
          width: 50.aw, // Auto-responsive width
          child: AText('$role:', fontSize: 12, color: AppColors.textGray),
        ),
        Expanded(
          child: AText(
            '$email / $password',
            fontSize: 12,
            color: AppColors.textDark,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ),
      ],
    );
  }

  Widget _buildOfflineModeWarning() {
    return AContainer(
      padding: AR.p(12), // Auto-responsive padding
      borderRadius: 8, // Auto-responsive radius
      color: AppColors.warning.withValues(alpha: 0.1),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: AppColors.warning,
            size: 16.aw, // Auto-responsive icon size
          ),
          AR.w(8), // Auto-responsive spacing
          const Expanded(
            child: AText(
              'Mode Offline - Supabase belum dikonfigurasi',
              fontSize: 12,
              color: AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }
}
