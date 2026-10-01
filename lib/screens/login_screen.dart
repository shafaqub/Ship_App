import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_logo.dart';
import '../widgets/animated_logo_background.dart';
import 'home_screen.dart';

enum AuthMode { login, signUp, verifyEmail }

class LoginScreen extends StatefulWidget {
  final AuthService? authService;

  const LoginScreen({
    super.key,
    this.authService,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _codeController = TextEditingController();

  late final AnimationController _animationController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;

  late final AuthService _authService;

  AuthMode _authMode = AuthMode.login;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  String? _verificationEmail;

  @override
  void initState() {
    super.initState();
    _authService = widget.authService ?? AuthService();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    final curvedAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    _logoScale = Tween<double>(begin: 0.90, end: 1.0).animate(curvedAnimation);
    _logoOpacity = Tween<double>(begin: 0.2, end: 1.0).animate(curvedAnimation);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _switchAuthMode(AuthMode mode) {
    setState(() {
      _authMode = mode;
      _errorMessage = null;
      _formKey.currentState?.reset();
    });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (_authMode == AuthMode.login) {
      final result = await _authService.login(email: email, password: password);
      if (!mounted) return;
      _handleLoginResult(result);
    } else if (_authMode == AuthMode.signUp) {
      final name = _nameController.text.trim();
      final result = await _authService.register(
        name: name,
        email: email,
        password: password,
      );
      if (!mounted) return;
      _handleRegisterResult(result);
    } else if (_authMode == AuthMode.verifyEmail) {
      final code = _codeController.text.trim();
      final verificationEmail = (_verificationEmail ?? email).trim();
      final result = await _authService.verifyEmail(email: verificationEmail, code: code);
      if (!mounted) return;
      _handleVerifyResult(result);
    }
  }

  void _handleLoginResult(AuthResult result) {
    if (result.success) {
      final userName = (result.user?['name'] as String?) ?? 'Alex';
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => HomeScreen(userName: userName),
        ),
      );
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = result.message;
      });
    }
  }

  void _handleRegisterResult(AuthResult result) {
    setState(() {
      _isLoading = false;
    });

    if (result.success) {
      _verificationEmail = _emailController.text.trim();
      _switchAuthMode(AuthMode.verifyEmail);
    } else {
      setState(() {
        _errorMessage = result.message;
      });
    }
  }

  void _handleVerifyResult(AuthResult result) {
    if (result.success) {
      final userName = (result.user?['name'] as String?) ?? _nameController.text.trim().ifEmpty('Alex');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => HomeScreen(userName: userName.isNotEmpty ? userName : 'Alex'),
        ),
      );
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = result.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedLogoBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 850;
              return Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 48 : 24,
                    vertical: isDesktop ? 40 : 28,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 1100,
                      minHeight: constraints.maxHeight > 100 ? constraints.maxHeight - 68 : 0,
                    ),
                    child: isDesktop ? _desktopLayout() : _mobileLayout(),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _desktopLayout() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: _branding()),
        const SizedBox(width: 64),
        SizedBox(width: 440, child: _authFormCard()),
      ],
    );
  }

  Widget _mobileLayout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _branding(compact: true),
        const SizedBox(height: 32),
        SizedBox(width: double.infinity, child: _authFormCard()),
      ],
    );
  }

  Widget _branding({bool compact = false}) {
    final logoDimension = compact ? 180.0 : 240.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: compact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) => Opacity(
            opacity: _logoOpacity.value,
            child: Transform.scale(scale: _logoScale.value, child: child),
          ),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentCyan.withValues(alpha: 0.25),
                  blurRadius: 36,
                  spreadRadius: 2,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: AnimatedInterviewMeLogo(
              width: logoDimension,
              height: logoDimension,
            ),
          ),
        ),
        const SizedBox(height: 28),
        ShaderMask(
          shaderCallback: (bounds) => AppColors.logoGradient.createShader(bounds),
          child: Text(
            'Prepare for interviews\nwith AI confidence.',
            textAlign: compact ? TextAlign.center : TextAlign.left,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w800,
              height: 1.15,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Tailored practice, CV analysis, and real-time AI feedback.',
          textAlign: compact ? TextAlign.center : TextAlign.left,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _authFormCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.cardSurface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.cardBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _authMode == AuthMode.login
                  ? 'Welcome back'
                  : _authMode == AuthMode.signUp
                      ? 'Create an Account'
                      : 'Verify Email',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _authMode == AuthMode.login
                  ? 'Sign in to access your interview practice dashboard.'
                  : _authMode == AuthMode.signUp
                      ? 'Sign up to start your personalized AI interview prep.'
                      : 'Enter the 6-digit verification code sent to your email.',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: AppColors.error, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (_authMode == AuthMode.signUp) ...[
              TextFormField(
                key: const Key('nameField'),
                controller: _nameController,
                keyboardType: TextInputType.name,
                enabled: !_isLoading,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'Alex Johnson',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if ((value?.trim() ?? '').isEmpty) return 'Enter your full name';
                  return null;
                },
              ),
              const SizedBox(height: 18),
            ],
            if (_authMode != AuthMode.verifyEmail) ...[
              TextFormField(
                key: const Key('emailField'),
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                enabled: !_isLoading,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Email address',
                  hintText: 'alex@example.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  final email = value?.trim() ?? '';
                  if (email.isEmpty) return 'Enter your email address';
                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              TextFormField(
                key: const Key('passwordField'),
                controller: _passwordController,
                obscureText: _obscurePassword,
                enabled: !_isLoading,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                validator: (value) {
                  final pass = value ?? '';
                  if (pass.isEmpty) return 'Enter your password';
                  if (_authMode == AuthMode.signUp && pass.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
                textInputAction: _authMode == AuthMode.login ? TextInputAction.done : TextInputAction.next,
                onFieldSubmitted: _authMode == AuthMode.login ? (_) => _submit() : null,
              ),
              const SizedBox(height: 18),
            ],
            if (_authMode == AuthMode.signUp) ...[
              TextFormField(
                key: const Key('confirmPasswordField'),
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                enabled: !_isLoading,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: const Icon(Icons.lock_reset_outlined),
                  suffixIcon: IconButton(
                    tooltip: _obscureConfirmPassword ? 'Show password' : 'Hide password',
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 18),
            ],
            if (_authMode == AuthMode.verifyEmail) ...[
              TextFormField(
                key: const Key('verificationCodeField'),
                controller: _codeController,
                keyboardType: TextInputType.number,
                enabled: !_isLoading,
                style: const TextStyle(color: AppColors.textPrimary, letterSpacing: 4.0, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  labelText: '6-Digit Verification Code',
                  hintText: '123456',
                  prefixIcon: Icon(Icons.security_outlined),
                ),
                validator: (value) {
                  final code = value?.trim() ?? '';
                  if (code.isEmpty) return 'Enter the 6-digit code';
                  if (!RegExp(r'^\d{6}$').hasMatch(code)) return 'Enter all 6 digits';
                  return null;
                },
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 18),
            ],
            const SizedBox(height: 10),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.midnightNavy),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              _authMode == AuthMode.login
                                  ? 'Sign in'
                                  : _authMode == AuthMode.signUp
                                      ? 'Send Verification Code'
                                      : 'Verify & Continue',
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 2,
              children: [
                Text(
                  _authMode == AuthMode.login
                      ? "Don't have an account?"
                      : _authMode == AuthMode.signUp
                          ? "Already have an account?"
                          : "Didn't receive code?",
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          if (_authMode == AuthMode.login) {
                            _switchAuthMode(AuthMode.signUp);
                          } else if (_authMode == AuthMode.signUp) {
                            _switchAuthMode(AuthMode.login);
                          } else {
                            _switchAuthMode(AuthMode.signUp);
                          }
                        },
                  child: Text(
                    _authMode == AuthMode.login
                        ? 'Sign Up'
                        : _authMode == AuthMode.signUp
                            ? 'Sign In'
                            : 'Resend / Edit Info',
                    style: const TextStyle(
                      color: AppColors.accentCyan,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

extension _StringExt on String {
  String ifEmpty(String fallback) => isNotEmpty ? this : fallback;
}
