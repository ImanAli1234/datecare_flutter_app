/// ═══════════════════════════════════════════════════════════════════════════════
/// login_screen.dart — Authentication: Sign In
/// ═══════════════════════════════════════════════════════════════════════════════
///
/// The first screen the user sees. Collects email + password and authenticates
/// via Supabase Auth. On success, navigates to the MainScaffold (4-tab home).
///
/// FEATURES:
///   - Email format validation
///   - Non-empty password validation
///   - Loading state on the login button while authenticating
///   - Error messages for invalid credentials, network errors, etc.
///   - "Recover Access Key" (password reset) via Supabase Auth
///   - Loads user profile into UserState after successful login
/// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../core/widgets/datecare_app_bar.dart';
import '../../core/widgets/datecare_input_card.dart';
import '../../core/routing/app_routes.dart';
import '../../core/services/auth_repository.dart';
import '../../core/services/profile_repository.dart';
import '../../core/state/user_state_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authRepo = AuthRepository();
  final _profileRepo = ProfileRepository();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Validates input and attempts Supabase sign-in.
  Future<void> _handleLogin() async {
    // Clear previous error
    setState(() => _errorMessage = null);

    // Validate fields
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email address.');
      return;
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email)) {
      setState(() => _errorMessage = 'Please enter a valid email address.');
      return;
    }
    if (password.isEmpty) {
      setState(() => _errorMessage = 'Please enter your access key.');
      return;
    }

    // Attempt sign-in
    setState(() => _isLoading = true);
    try {
      await _authRepo.signIn(email: email, password: password);

      // Load profile into UserState
      if (mounted) {
        final userState = UserStateProvider.of(context);
        final profile = await _profileRepo.fetchProfile();
        if (!mounted) return;
        if (profile != null) {
          userState.updateDisplayName(profile.displayName);
          userState.updateEmail(profile.email);
        }

        // Navigate to main app
        Navigator.pushReplacementNamed(context, AppRoutes.mainScaffold);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DatecareAppBar(),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Sign In to your Estate.',
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Access your curated field guide and manage your botanical almanac.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              
              // Error Message
              if (_errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0EE),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE8A090),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Color(0xFFB85C49), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFFB85C49),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Email Input
              DatecareInputCard(
                label: 'Manager Email',
                hint: 'Curator@estate.com',
                controller: _emailController,
              ),
              const SizedBox(height: 24),
              
              // Password Input
              DatecareInputCard(
                label: 'Access Key',
                hint: '••••••••',
                obscureText: true,
                controller: _passwordController,
              ),
              const SizedBox(height: 32),
              
              // Login Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    disabledBackgroundColor: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'ENTER MY GROVE',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                                letterSpacing: 2.0,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, size: 18),
                          ],
                        ),
                ),
              ),
              
              const SizedBox(height: 24),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Recover Access Key',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.register);
                },
                child: Text(
                  'Create new estate',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
