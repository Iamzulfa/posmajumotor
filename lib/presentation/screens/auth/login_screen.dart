import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/constants/app_constants.dart';
import '../../../config/constants/supabase_config.dart';
import '../../../config/routes/app_routes.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/responsive_utils.dart';
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
            padding: ResponsiveUtils.getResponsivePadding(context),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildLogo(),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      phoneSpacing: 32,
                      tabletSpacing: 40,
                      desktopSpacing: 48,
                    ),
                  ),
                  _buildEmailField(),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      phoneSpacing: 16,
                      tabletSpacing: 20,
                      desktopSpacing: 24,
                    ),
                  ),
                  _buildPasswordField(),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      phoneSpacing: 16,
                      tabletSpacing: 20,
                      desktopSpacing: 24,
                    ),
                  ),
                  _buildRememberMe(),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      phoneSpacing: 24,
                      tabletSpacing: 30,
                      desktopSpacing: 36,
                    ),
                  ),
                  _buildLoginButton(authState.isLoading),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      phoneSpacing: 16,
                      tabletSpacing: 20,
                      desktopSpacing: 24,
                    ),
                  ),
                  _buildForgotPassword(),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      phoneSpacing: 32,
                      tabletSpacing: 40,
                      desktopSpacing: 48,
                    ),
                  ),
                  _buildDemoCredentials(),
                  if (!SupabaseConfig.isConfigured) ...[
                    SizedBox(
                      height: ResponsiveUtils.getResponsiveSpacing(
                        context,
                        phoneSpacing: 16,
                        tabletSpacing: 20,
                        desktopSpacing: 24,
                      ),
                    ),
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
        Container(
          width: ResponsiveUtils.getResponsiveWidth(
            context,
            phoneWidth: 80,
            tabletWidth: 100,
            desktopWidth: 120,
          ),
          height: ResponsiveUtils.getResponsiveHeight(
            context,
            phoneHeight: 80,
            tabletHeight: 100,
            desktopHeight: 120,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.getResponsiveBorderRadius(context),
            ),
          ),
          child: Center(
            child: Text(
              'M',
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  phoneSize: 40,
                  tabletSize: 50,
                  desktopSize: 60,
                ),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(
          height: ResponsiveUtils.getResponsiveSpacing(
            context,
            phoneSpacing: 16,
            tabletSpacing: 20,
            desktopSpacing: 24,
          ),
        ),
        Text(
          AppConstants.appName,
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(
              context,
              phoneSize: 24,
              tabletSize: 28,
              desktopSize: 32,
            ),
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        SizedBox(
          height: ResponsiveUtils.getResponsiveSpacing(
            context,
            phoneSpacing: 8,
            tabletSpacing: 10,
            desktopSpacing: 12,
          ),
        ),
        Text(
          'Kelola toko suku cadang Anda',
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(
              context,
              phoneSize: 14,
              tabletSize: 16,
              desktopSize: 18,
            ),
            color: AppColors.textGray,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email',
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(
              context,
              phoneSize: 14,
              tabletSize: 16,
              desktopSize: 18,
            ),
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),
        SizedBox(
          height: ResponsiveUtils.getResponsiveSpacing(
            context,
            phoneSpacing: 8,
            tabletSpacing: 10,
            desktopSpacing: 12,
          ),
        ),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          validator: AppValidators.validateEmail,
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(
              context,
              phoneSize: 16,
              tabletSize: 18,
              desktopSize: 20,
            ),
          ),
          decoration: InputDecoration(
            hintText: 'email@example.com',
            filled: true,
            fillColor: AppColors.backgroundLight,
            contentPadding: ResponsiveUtils.getResponsivePaddingCustom(
              context,
              phoneValue: 16,
              tabletValue: 18,
              desktopValue: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(context),
              ),
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
        Text(
          'Password',
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(
              context,
              phoneSize: 14,
              tabletSize: 16,
              desktopSize: 18,
            ),
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),
        SizedBox(
          height: ResponsiveUtils.getResponsiveSpacing(
            context,
            phoneSpacing: 8,
            tabletSpacing: 10,
            desktopSpacing: 12,
          ),
        ),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          validator: AppValidators.validatePassword,
          onFieldSubmitted: (_) => _handleLogin(),
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(
              context,
              phoneSize: 16,
              tabletSize: 18,
              desktopSize: 20,
            ),
          ),
          decoration: InputDecoration(
            hintText: '••••••••',
            filled: true,
            fillColor: AppColors.backgroundLight,
            contentPadding: ResponsiveUtils.getResponsivePaddingCustom(
              context,
              phoneValue: 16,
              tabletValue: 18,
              desktopValue: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(context),
              ),
              borderSide: BorderSide.none,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: AppColors.textGray,
                size: ResponsiveUtils.getResponsiveIconSize(context),
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
          width: ResponsiveUtils.getResponsiveWidth(
            context,
            phoneWidth: 24,
            tabletWidth: 28,
            desktopWidth: 32,
          ),
          height: ResponsiveUtils.getResponsiveHeight(
            context,
            phoneHeight: 24,
            tabletHeight: 28,
            desktopHeight: 32,
          ),
          child: Checkbox(
            value: _rememberMe,
            onChanged: (value) => setState(() => _rememberMe = value ?? false),
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(context) * 0.3,
              ),
            ),
          ),
        ),
        SizedBox(
          width: ResponsiveUtils.getResponsiveSpacing(
            context,
            phoneSpacing: 8,
            tabletSpacing: 10,
            desktopSpacing: 12,
          ),
        ),
        Text(
          'Ingat saya',
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(
              context,
              phoneSize: 14,
              tabletSize: 16,
              desktopSize: 18,
            ),
            color: AppColors.textGray,
          ),
        ),
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
    return Container(
      padding: ResponsiveUtils.getResponsivePaddingCustom(
        context,
        phoneValue: 16,
        tabletValue: 20,
        desktopValue: 24,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Demo Credentials:',
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                phoneSize: 12,
                tabletSize: 14,
                desktopSize: 16,
              ),
              fontWeight: FontWeight.w600,
              color: AppColors.textGray,
            ),
          ),
          SizedBox(
            height: ResponsiveUtils.getResponsiveSpacing(
              context,
              phoneSpacing: 8,
              tabletSpacing: 10,
              desktopSpacing: 12,
            ),
          ),
          _buildCredentialRow('Admin', 'admin@toko.com', 'admin123'),
          SizedBox(
            height: ResponsiveUtils.getResponsiveSpacing(
              context,
              phoneSpacing: 4,
              tabletSpacing: 6,
              desktopSpacing: 8,
            ),
          ),
          _buildCredentialRow('Kasir', 'kasir@toko.com', 'kasir123'),
        ],
      ),
    );
  }

  Widget _buildCredentialRow(String role, String email, String password) {
    return Row(
      children: [
        SizedBox(
          width: ResponsiveUtils.getResponsiveWidth(
            context,
            phoneWidth: 50,
            tabletWidth: 60,
            desktopWidth: 70,
          ),
          child: Text(
            '$role:',
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                phoneSize: 12,
                tabletSize: 14,
                desktopSize: 16,
              ),
              color: AppColors.textGray,
            ),
          ),
        ),
        Expanded(
          child: Text(
            '$email / $password',
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                phoneSize: 12,
                tabletSize: 14,
                desktopSize: 16,
              ),
              color: AppColors.textDark,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOfflineModeWarning() {
    return Container(
      padding: ResponsiveUtils.getResponsivePaddingCustom(
        context,
        phoneValue: 12,
        tabletValue: 16,
        desktopValue: 20,
      ),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context) * 0.7,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: AppColors.warning,
            size: ResponsiveUtils.getResponsiveIconSize(context) * 0.8,
          ),
          SizedBox(
            width: ResponsiveUtils.getResponsiveSpacing(
              context,
              phoneSpacing: 8,
              tabletSpacing: 10,
              desktopSpacing: 12,
            ),
          ),
          Expanded(
            child: Text(
              'Mode Offline - Supabase belum dikonfigurasi',
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  phoneSize: 12,
                  tabletSize: 14,
                  desktopSize: 16,
                ),
                color: AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
