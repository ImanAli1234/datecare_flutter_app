import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/state/user_state.dart';
import '../../../core/state/user_state_provider.dart';
import '../../../core/services/auth_repository.dart';
import '../../../core/services/profile_repository.dart';
import '../../../core/routing/app_routes.dart';

/// The Profile Editing screen — "The Curator's Desk."
///
/// Supports View Mode (static labels) and Edit Mode (input fields).
/// Includes a "Security & Access" vault accordion for password management.
/// Profile changes are now persisted to Supabase via repositories.
/// Sign-out button clears the session and returns to login.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  bool _isEditing = false;
  bool _securityExpanded = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  bool _isSaving = false;

  late TextEditingController _nameController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  final _authRepo = AuthRepository();
  final _profileRepo = ProfileRepository();

  String? _passwordError;
  String? _newPasswordStrengthError;
  bool _showToast = false;

  late AnimationController _toastController;
  late Animation<Offset> _toastSlide;
  late Animation<double> _toastOpacity;

  @override
  void initState() {
    super.initState();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    // Toast animation
    _toastController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _toastSlide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _toastController,
      curve: Curves.easeOutCubic,
    ));
    _toastOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _toastController, curve: Curves.easeOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize name controller with current user state
    final userState = UserStateProvider.of(context);
    _nameController = TextEditingController(text: userState.displayName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _toastController.dispose();
    super.dispose();
  }

  void _enterEditMode() {
    final userState = UserStateProvider.of(context);
    setState(() {
      _isEditing = true;
      _nameController.text = userState.displayName;
      _passwordError = null;
      _newPasswordStrengthError = null;
    });
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _securityExpanded = false;
      _passwordError = null;
      _newPasswordStrengthError = null;
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    });
  }

  /// Saves profile changes to Supabase.
  Future<void> _saveChanges() async {
    final userState = UserStateProvider.of(context);

    // Validate name
    final name = _nameController.text.trim();
    if (name.isEmpty || name.length > UserState.maxNameLength) {
      setState(() => _passwordError = 'Name must be 1–30 characters');
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Update display name in Supabase
      if (name != userState.displayName) {
        await _profileRepo.updateDisplayName(name);
        userState.updateDisplayName(name);
      }

      // Update password if fields are filled
      if (_newPasswordController.text.isNotEmpty ||
          _confirmPasswordController.text.isNotEmpty) {
        // Validate match
        if (_newPasswordController.text != _confirmPasswordController.text) {
          setState(() {
            _passwordError = 'Passwords do not match';
            _isSaving = false;
          });
          return;
        }

        // Validate strength
        final strengthError =
            UserState.validatePasswordStrength(_newPasswordController.text);
        if (strengthError != null) {
          setState(() {
            _newPasswordStrengthError = strengthError;
            _isSaving = false;
          });
          return;
        }

        // Update password via Supabase Auth
        await _profileRepo.updatePassword(_newPasswordController.text);
      }

      // Success
      if (mounted) {
        setState(() {
          _isEditing = false;
          _securityExpanded = false;
          _passwordError = null;
          _isSaving = false;
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        });
        _showSuccessToast();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _passwordError = e.toString();
          _isSaving = false;
        });
      }
    }
  }

  /// Signs out and navigates to login.
  Future<void> _handleSignOut() async {
    try {
      await _authRepo.signOut();
      if (mounted) {
        UserStateProvider.of(context).reset();
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign out failed: $e')),
        );
      }
    }
  }

  void _showSuccessToast() {
    setState(() => _showToast = true);
    _toastController.forward();
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        _toastController.reverse().then((_) {
          if (mounted) setState(() => _showToast = false);
        });
      }
    });
  }

  void _validateNewPassword(String value) {
    setState(() {
      _newPasswordStrengthError = UserState.validatePasswordStrength(value);
      // Also clear mismatch error if user is still typing
      if (_confirmPasswordController.text.isNotEmpty &&
          value != _confirmPasswordController.text) {
        _passwordError = 'Passwords do not match';
      } else {
        _passwordError = null;
      }
    });
  }

  void _validateConfirmPassword(String value) {
    setState(() {
      if (value.isNotEmpty && value != _newPasswordController.text) {
        _passwordError = 'Passwords do not match';
      } else {
        _passwordError = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userState = UserStateProvider.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Background watermark
            Positioned(
              bottom: -40,
              right: -60,
              child: Icon(
                Icons.shield_outlined,
                size: 220,
                color: AppColors.outlineVariant.withValues(alpha: 0.06),
              ),
            ),

            // Main content
            Column(
              children: [
                // ── App Bar ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.vanillaCustard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.ghostBorder),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'DATECARE',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          letterSpacing: 3.0,
                          fontSize: 18,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 36), // Balance the back button
                    ],
                  ),
                ),

                // ── Section Label ────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      const Icon(Icons.settings_outlined,
                          color: AppColors.onSurfaceVariant, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'ACCOUNT SETTINGS — THE CURATOR\'S DESK',
                        style: theme.textTheme.labelSmall?.copyWith(
                          letterSpacing: 2.0,
                          color: AppColors.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── Scrollable Content ───────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        // Profile Avatar
                        _buildProfileAvatar(userState, theme),
                        const SizedBox(height: 32),

                        // Name Section
                        _buildNameSection(userState, theme),
                        const SizedBox(height: 16),

                        // Email Section
                        _buildEmailSection(userState, theme),
                        const SizedBox(height: 24),

                        // Edit Profile button (View mode only)
                        if (!_isEditing) _buildEditButton(theme),

                        // Security & Access Vault
                        if (_isEditing) ...[
                          const SizedBox(height: 8),
                          _buildSecurityVault(theme),
                        ],

                        // Action Buttons (Edit mode only)
                        if (_isEditing) ...[
                          const SizedBox(height: 32),
                          _buildActionButtons(theme),
                        ],

                        // Sign Out Button
                        if (!_isEditing) ...[
                          const SizedBox(height: 24),
                          _buildSignOutButton(theme),
                        ],

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ── Glassmorphic Toast ────────────────────────────────────
            if (_showToast) _buildGlassmorphicToast(theme),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Widget Builders
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildProfileAvatar(UserState userState, ThemeData theme) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryContainer],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Text(
              userState.initial,
              style: theme.textTheme.displayMedium?.copyWith(
                color: AppColors.onPrimary,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Account Settings',
          style: theme.textTheme.headlineLarge?.copyWith(
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage your estate identity',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildNameSection(UserState userState, ThemeData theme) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _isEditing
          ? _buildEditableField(
              key: const ValueKey('name-edit'),
              label: 'DISPLAY NAME',
              controller: _nameController,
              maxLength: UserState.maxNameLength,
              hint: 'Enter your name',
            )
          : _buildStaticField(
              key: const ValueKey('name-view'),
              label: 'DISPLAY NAME',
              value: userState.displayName,
            ),
    );
  }

  Widget _buildEmailSection(UserState userState, ThemeData theme) {
    return _buildStaticField(
      label: 'EMAIL',
      value: userState.email,
      icon: Icons.email_outlined,
    );
  }

  Widget _buildEditButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: _enterEditMode,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.deepEspresso),
          foregroundColor: AppColors.deepEspresso,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.edit_outlined, size: 18),
        label: const Text(
          'EDIT PROFILE',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  /// Sign out button — shown in view mode below the edit button.
  Widget _buildSignOutButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: _handleSignOut,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.deepEspresso.withValues(alpha: 0.3)),
          foregroundColor: AppColors.onSurfaceVariant,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.logout, size: 18),
        label: const Text(
          'SIGN OUT',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  // ── Static Field (View Mode) ───────────────────────────────────────────

  Widget _buildStaticField({
    Key? key,
    required String label,
    required String value,
    IconData? icon,
  }) {
    return Container(
      key: key,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.0,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Editable Field (Edit Mode) ─────────────────────────────────────────

  Widget _buildEditableField({
    Key? key,
    required String label,
    required TextEditingController controller,
    int? maxLength,
    String? hint,
    bool obscureText = false,
    Widget? suffixIcon,
    ValueChanged<String>? onChanged,
    String? errorText,
  }) {
    return Container(
      key: key,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.vanillaCustard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.ghostBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
              if (maxLength != null)
                ListenableBuilder(
                  listenable: controller,
                  builder: (context, _) {
                    return Text(
                      '${controller.text.length}/$maxLength',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: controller.text.length > maxLength
                            ? AppColors.softTerracottaError
                            : AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            obscureText: obscureText,
            onChanged: onChanged,
            inputFormatters: maxLength != null
                ? [LengthLimitingTextInputFormatter(maxLength)]
                : null,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.35),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
              suffixIcon: suffixIcon,
              suffixIconConstraints:
                  const BoxConstraints(minWidth: 24, minHeight: 24),
            ),
          ),
          if (errorText != null) ...[
            const SizedBox(height: 8),
            Text(
              errorText,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.softTerracottaError,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Security & Access Vault ────────────────────────────────────────────

  Widget _buildSecurityVault(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.vanillaCustard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.ghostBorder),
      ),
      child: Column(
        children: [
          // Accordion Header
          InkWell(
            onTap: () => setState(() => _securityExpanded = !_securityExpanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(Icons.lock_outline,
                      color: AppColors.deepEspresso, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SECURITY & ACCESS',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: AppColors.deepEspresso
                                .withValues(alpha: 0.85),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Update your access key',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 11,
                            color: AppColors.onSurfaceVariant
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _securityExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.deepEspresso,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Accordion Body
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: _buildPasswordFields(),
            crossFadeState: _securityExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordFields() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        children: [
          Container(
            height: 1,
            color: AppColors.ghostBorder,
          ),
          const SizedBox(height: 20),

          // New Password
          _buildEditableField(
            label: 'NEW PASSWORD',
            controller: _newPasswordController,
            hint: 'Enter new access key',
            obscureText: !_showNewPassword,
            onChanged: _validateNewPassword,
            errorText: _newPasswordStrengthError,
            suffixIcon: GestureDetector(
              onTap: () =>
                  setState(() => _showNewPassword = !_showNewPassword),
              child: Icon(
                _showNewPassword
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: AppColors.deepEspresso,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Confirm New Password
          _buildEditableField(
            label: 'CONFIRM NEW PASSWORD',
            controller: _confirmPasswordController,
            hint: 'Re-enter new access key',
            obscureText: !_showConfirmPassword,
            onChanged: _validateConfirmPassword,
            errorText: _passwordError,
            suffixIcon: GestureDetector(
              onTap: () => setState(
                  () => _showConfirmPassword = !_showConfirmPassword),
              child: Icon(
                _showConfirmPassword
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: AppColors.deepEspresso,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Action Buttons ─────────────────────────────────────────────────────

  Widget _buildActionButtons(ThemeData theme) {
    return Row(
      children: [
        // Cancel
        Expanded(
          child: SizedBox(
            height: 52,
            child: OutlinedButton(
              onPressed: _isSaving ? null : _cancelEdit,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: AppColors.deepEspresso.withValues(alpha: 0.4),
                ),
                foregroundColor: AppColors.deepEspresso,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'CANCEL',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Save Changes
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deepEspresso,
                foregroundColor: AppColors.onPrimary,
                disabledBackgroundColor: AppColors.deepEspresso.withValues(alpha: 0.6),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.check, size: 18),
              label: Text(
                _isSaving ? 'SAVING...' : 'SAVE CHANGES',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Glassmorphic Toast ─────────────────────────────────────────────────

  Widget _buildGlassmorphicToast(ThemeData theme) {
    return Positioned(
      top: 16,
      left: 24,
      right: 24,
      child: SlideTransition(
        position: _toastSlide,
        child: FadeTransition(
          opacity: _toastOpacity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.deepEspresso.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.onPrimary.withValues(alpha: 0.1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.deepEspresso.withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.bullishGreen.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: AppColors.bullishGreen,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Profile Updated Successfully',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onPrimary,
                        ),
                      ),
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
}
