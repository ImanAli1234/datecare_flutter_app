/// ═══════════════════════════════════════════════════════════════════════════════
/// specimen_log_screen.dart — Add or Edit a Palm Specimen
/// ═══════════════════════════════════════════════════════════════════════════════
///
/// A form screen where the user logs a new palm tree or edits an existing one.
///
/// MODES:
///   - Create: All fields empty, button says "LOG SPECIMEN"
///   - Edit: Fields pre-filled from existing specimen, button says "UPDATE SPECIMEN"
///
/// The variety selector includes common varieties as chips + an "Other" option
/// that opens a custom text input for unlisted varieties.
/// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/specimen_model.dart';

class SpecimenLogScreen extends StatefulWidget {
  /// If provided, the form opens in edit mode with pre-filled data.
  final SpecimenModel? existingSpecimen;

  const SpecimenLogScreen({super.key, this.existingSpecimen});

  @override
  State<SpecimenLogScreen> createState() => _SpecimenLogScreenState();
}

class _SpecimenLogScreenState extends State<SpecimenLogScreen> {
  final _plotController = TextEditingController();
  final _vitalityController = TextEditingController();
  final _customVarietyController = TextEditingController();
  DateTime _originDate = DateTime.now();
  String _selectedVariety = 'Medjool';
  bool _isCustomVariety = false;

  final List<String> _varieties = [
    'Medjool', 'Barhi', 'Deglet Noor', 'Ajwa', 'Zahidi', 'Khalas', 'Sukkari',
  ];

  bool get _isEditMode => widget.existingSpecimen != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final s = widget.existingSpecimen!;
      _originDate = s.originDate;
      _plotController.text = s.plotLocation;
      _vitalityController.text = s.vitalityNote;

      // Check if the variety is one of the presets or a custom one
      final matchIndex = _varieties.indexWhere(
        (v) => v.toUpperCase() == s.variety.toUpperCase(),
      );
      if (matchIndex != -1) {
        _selectedVariety = _varieties[matchIndex];
        _isCustomVariety = false;
      } else {
        // It's a custom variety the user typed previously
        _isCustomVariety = true;
        _customVarietyController.text = s.variety;
        _selectedVariety = ''; // no preset selected
      }
    }
  }

  @override
  void dispose() {
    _plotController.dispose();
    _vitalityController.dispose();
    _customVarietyController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _originDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.onPrimary,
              surface: AppColors.background,
              onSurface: AppColors.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _originDate = picked);
    }
  }

  /// Gets the final variety name — either the selected preset or the custom text.
  String get _finalVariety {
    if (_isCustomVariety) {
      final custom = _customVarietyController.text.trim();
      return custom.isNotEmpty ? custom.toUpperCase() : 'CUSTOM';
    }
    return _selectedVariety.toUpperCase();
  }

  void _submitForm() {
    // Validate custom variety if "Other" is selected
    if (_isCustomVariety && _customVarietyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your custom variety name.')),
      );
      return;
    }

    final result = {
      'variety': _finalVariety,
      'originDate': _originDate.toIso8601String(),
      'plot': _plotController.text.isNotEmpty ? _plotController.text : 'Unspecified',
      'vitality': _vitalityController.text,
    };
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dateStr = '${_originDate.day} ${months[_originDate.month - 1]} ${_originDate.year}';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: AppColors.primary, size: 22),
                  ),
                  Text(
                    'DATECARE',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      letterSpacing: 3.0,
                      fontSize: 18,
                    ),
                  ),
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primaryContainer,
                    child: Icon(Icons.person, color: AppColors.onPrimary, size: 18),
                  ),
                ],
              ),
            ),
            // Section label
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  const Icon(Icons.eco, color: AppColors.onSurfaceVariant, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    _isEditMode ? 'SPECIMEN LOG — EDIT ENTRY' : 'SPECIMEN LOG — NEW ENTRY',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      letterSpacing: 2.0,
                      color: AppColors.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Origin Date
                    _buildSectionLabel('ORIGIN DATE'),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.15)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              dateStr,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Icon(Icons.calendar_today, color: AppColors.primaryContainer, size: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 2. Date Variety (with "Other" option)
                    _buildSectionLabel('DATE VARIETY'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        // Preset variety chips
                        ..._varieties.map((v) {
                          final isSelected = !_isCustomVariety && _selectedVariety == v;
                          return GestureDetector(
                            onTap: () => setState(() {
                              _selectedVariety = v;
                              _isCustomVariety = false;
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primaryContainer : AppColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                v,
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          );
                        }),
                        // "Other" chip
                        GestureDetector(
                          onTap: () => setState(() {
                            _isCustomVariety = true;
                            _selectedVariety = '';
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            decoration: BoxDecoration(
                              color: _isCustomVariety ? AppColors.primaryContainer : AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(8),
                              border: _isCustomVariety
                                  ? null
                                  : Border.all(
                                      color: AppColors.outlineVariant.withValues(alpha: 0.3),
                                      style: BorderStyle.solid,
                                    ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.add,
                                  size: 16,
                                  color: _isCustomVariety ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Other',
                                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: _isCustomVariety ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                                    fontWeight: _isCustomVariety ? FontWeight.bold : FontWeight.normal,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Custom variety text field (shows when "Other" is selected)
                    if (_isCustomVariety) ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: _customVarietyController,
                        autofocus: true,
                        textCapitalization: TextCapitalization.words,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter your date variety name...',
                          hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.outlineVariant,
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceContainerLow,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primaryContainer, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          prefixIcon: const Icon(Icons.edit, color: AppColors.primaryContainer, size: 18),
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),

                    // 3. Plot Location
                    _buildSectionLabel('PLOT LOCATION'),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _plotController,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.onSurface),
                      decoration: InputDecoration(
                        hintText: 'e.g., North Grove, Section 4',
                        hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.outlineVariant,
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 4. Initial Vitality Note
                    _buildSectionLabel('INITIAL VITALITY NOTE'),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _vitalityController,
                      maxLines: 4,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurface,
                        height: 1.6,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Record the tree\'s health at the moment of entry...',
                        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.outlineVariant,
                          height: 1.6,
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceContainerLow,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(20),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Bottom action
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isEditMode ? 'UPDATE SPECIMEN' : 'LOG SPECIMEN',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.onPrimary,
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(_isEditMode ? Icons.check : Icons.arrow_forward, size: 16, color: AppColors.onPrimary),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        letterSpacing: 2.5,
        color: AppColors.onSurfaceVariant,
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
