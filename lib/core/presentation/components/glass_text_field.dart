/// Glass Text Field Component - Glassmorphism Input Fields
///
/// PATTERN: Decorator Pattern + Observer Pattern - Enhanced input fields with validation
/// WHERE: Core presentation components for user input
/// HOW: Decorates standard TextField with glass effects and reactive validation
/// WHY: Consistent input experience with Tower Defense visual theme and real-time feedback
library;

import 'package:design_patterns/core/logging/logging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../themes/app_theme.dart';
import 'glass_container.dart';

/// Observer interface for text field validation
abstract class TextFieldObserver {
  void onTextChanged(String text, bool isValid);

  void onFocusChanged(bool hasFocus);

  void onSubmitted(String text);
}

/// Validation strategy interface
abstract class ValidationStrategy {
  String? validate(String text);

  String get hint;

  TextInputType get inputType => TextInputType.text;

  List<TextInputFormatter> get formatters => [];
}

/// Email validation strategy
class EmailValidationStrategy implements ValidationStrategy {
  @override
  String? validate(String text) {
    if (text.isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(text)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  @override
  String get hint => 'Enter your email address';

  @override
  TextInputType get inputType => TextInputType.emailAddress;

  @override
  List<TextInputFormatter> get formatters => [];
}

/// Password validation strategy
class PasswordValidationStrategy implements ValidationStrategy {
  final int minLength;
  final bool requireSpecialChars;

  const PasswordValidationStrategy({
    this.minLength = 8,
    this.requireSpecialChars = true,
  });

  @override
  String? validate(String text) {
    if (text.isEmpty) return 'Password is required';
    if (text.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    if (requireSpecialChars &&
        !RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(text)) {
      return 'Password must contain special characters';
    }
    return null;
  }

  @override
  String get hint => 'Enter your password';

  @override
  TextInputType get inputType => TextInputType.visiblePassword;

  @override
  List<TextInputFormatter> get formatters => [];
}

/// Username validation strategy
class UsernameValidationStrategy implements ValidationStrategy {
  final int minLength;
  final int maxLength;

  const UsernameValidationStrategy({this.minLength = 3, this.maxLength = 20});

  @override
  String? validate(String text) {
    if (text.isEmpty) return 'Username is required';
    if (text.length < minLength) {
      return 'Username must be at least $minLength characters';
    }
    if (text.length > maxLength) {
      return 'Username cannot exceed $maxLength characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(text)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }

  @override
  String get hint => 'Enter your username';

  @override
  TextInputType get inputType => TextInputType.text;

  @override
  List<TextInputFormatter> get formatters => [];
}

/// Glass Text Field with decorative glassmorphism effects
class GlassTextField extends StatefulWidget {
  /// Text controller
  final TextEditingController? controller;

  /// Field label
  final String? label;

  /// Validation strategy
  final ValidationStrategy? validationStrategy;

  /// Observers for text changes
  final List<TextFieldObserver> observers;

  /// Whether field is obscured (password)
  final bool obscureText;

  /// Whether field is enabled
  final bool enabled;

  /// Maximum lines (null for unlimited)
  final int? maxLines;

  /// Maximum length
  final int? maxLength;

  /// Prefix icon
  final IconData? prefixIcon;

  /// Suffix icon
  final IconData? suffixIcon;

  /// Suffix icon callback
  final VoidCallback? onSuffixIconTap;

  /// Custom hint text (overrides validation strategy hint)
  final String? hintText;

  /// Initial value
  final String? initialValue;

  /// Focus node
  final FocusNode? focusNode;

  /// Text capitalization
  final TextCapitalization textCapitalization;

  /// Auto focus
  final bool autofocus;

  /// Read only
  final bool readOnly;

  /// On changed callback
  final ValueChanged<String>? onChanged;

  /// On submitted callback
  final ValueChanged<String>? onSubmitted;

  const GlassTextField({
    super.key,
    this.controller,
    this.label,
    this.validationStrategy,
    this.observers = const [],
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.hintText,
    this.initialValue,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
    this.autofocus = false,
    this.readOnly = false,
    this.onChanged,
    this.onSubmitted,
  });

  /// Factory constructor for email fields
  factory GlassTextField.email({
    Key? key,
    TextEditingController? controller,
    String? label = 'Email',
    List<TextFieldObserver> observers = const [],
    bool enabled = true,
    String? initialValue,
    FocusNode? focusNode,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
  }) {
    return GlassTextField(
      key: key,
      controller: controller,
      label: label,
      validationStrategy: EmailValidationStrategy(),
      observers: observers,
      enabled: enabled,
      prefixIcon: Icons.email_outlined,
      initialValue: initialValue,
      focusNode: focusNode,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );
  }

  /// Factory constructor for password fields
  factory GlassTextField.password({
    Key? key,
    TextEditingController? controller,
    String? label = 'Password',
    List<TextFieldObserver> observers = const [],
    bool enabled = true,
    String? initialValue,
    FocusNode? focusNode,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
  }) {
    return GlassTextField(
      key: key,
      controller: controller,
      label: label,
      validationStrategy: const PasswordValidationStrategy(),
      observers: observers,
      obscureText: true,
      enabled: enabled,
      prefixIcon: Icons.lock_outlined,
      suffixIcon: Icons.visibility_outlined,
      initialValue: initialValue,
      focusNode: focusNode,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );
  }

  /// Factory constructor for username fields
  factory GlassTextField.username({
    Key? key,
    TextEditingController? controller,
    String? label = 'Username',
    List<TextFieldObserver> observers = const [],
    bool enabled = true,
    String? initialValue,
    FocusNode? focusNode,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
  }) {
    return GlassTextField(
      key: key,
      controller: controller,
      label: label,
      validationStrategy: const UsernameValidationStrategy(),
      observers: observers,
      enabled: enabled,
      prefixIcon: Icons.person_outlined,
      initialValue: initialValue,
      focusNode: focusNode,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );
  }

  @override
  State<GlassTextField> createState() => _GlassTextFieldState();
}

class _GlassTextFieldState extends State<GlassTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  String? _errorText;
  bool _hasFocus = false;
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _obscureText = widget.obscureText;

    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }

    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);

    Log.debug('GlassTextField: Initialized with label "${widget.label}"');
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text;
    final isValid = _validateText(text);

    widget.onChanged?.call(text);

    // Notify observers - Observer pattern
    for (final observer in widget.observers) {
      observer.onTextChanged(text, isValid);
    }
  }

  void _onFocusChanged() {
    final hasFocus = _focusNode.hasFocus;

    setState(() {
      _hasFocus = hasFocus;
    });

    // Validate on focus loss
    if (!hasFocus) {
      _validateText(_controller.text);
    }

    // Notify observers - Observer pattern
    for (final observer in widget.observers) {
      observer.onFocusChanged(hasFocus);
    }
  }

  bool _validateText(String text) {
    if (widget.validationStrategy == null) return true;

    final errorText = widget.validationStrategy!.validate(text);

    setState(() {
      _errorText = errorText;
    });

    return errorText == null;
  }

  void _onSubmitted(String value) {
    widget.onSubmitted?.call(value);

    // Notify observers - Observer pattern
    for (final observer in widget.observers) {
      observer.onSubmitted(value);
    }
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
        ],

        // Glass text field
        GlassContainer(
          padding: EdgeInsets.zero,
          borderWidth: _hasFocus ? 1.5 : 1.0,
          borderColor: _hasFocus
              ? AppTheme.primaryColor.withValues(alpha: 0.5)
              : _errorText != null
              ? Colors.red.withValues(alpha: 0.5)
              : AppTheme.glassBorder,
          opacity: _hasFocus ? 0.15 : 0.1,
          child: TextFormField(
            controller: _controller,
            focusNode: _focusNode,
            obscureText: _obscureText,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            autofocus: widget.autofocus,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            keyboardType: widget.validationStrategy?.inputType,
            inputFormatters: widget.validationStrategy?.formatters,
            textCapitalization: widget.textCapitalization,
            onFieldSubmitted: _onSubmitted,
            style: TextStyle(color: AppTheme.textPrimary, fontSize: 16),
            decoration: InputDecoration(
              hintText: widget.hintText ?? widget.validationStrategy?.hint,
              hintStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(AppTheme.spacingM),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(widget.prefixIcon, color: AppTheme.textSecondary)
                  : null,
              suffixIcon: widget.suffixIcon != null
                  ? GestureDetector(
                      onTap: widget.obscureText
                          ? _toggleObscureText
                          : widget.onSuffixIconTap,
                      child: Icon(
                        widget.obscureText
                            ? (_obscureText
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined)
                            : widget.suffixIcon,
                        color: AppTheme.textSecondary,
                      ),
                    )
                  : null,
              counterText: '', // Hide character counter
            ),
          ),
        ),

        // Error text
        if (_errorText != null) ...[
          const SizedBox(height: AppTheme.spacingS),
          Text(
            _errorText!,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.red),
          ),
        ],
      ],
    );
  }
}

/// Specialized glass search field
class GlassSearchField extends StatefulWidget {
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final List<TextFieldObserver> observers;

  const GlassSearchField({
    super.key,
    this.hintText = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.observers = const [],
  });

  @override
  State<GlassSearchField> createState() => _GlassSearchFieldState();
}

class _GlassSearchFieldState extends State<GlassSearchField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasFocus = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text;
    final hasText = text.isNotEmpty;

    setState(() {
      _hasText = hasText;
    });

    widget.onChanged?.call(text);

    // Notify observers
    for (final observer in widget.observers) {
      observer.onTextChanged(text, true);
    }
  }

  void _onFocusChanged() {
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });

    // Notify observers
    for (final observer in widget.observers) {
      observer.onFocusChanged(_hasFocus);
    }
  }

  void _onClear() {
    _controller.clear();
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: EdgeInsets.zero,
      borderWidth: _hasFocus ? 1.5 : 1.0,
      borderColor: _hasFocus
          ? AppTheme.primaryColor.withValues(alpha: 0.5)
          : AppTheme.glassBorder,
      opacity: _hasFocus ? 0.15 : 0.1,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onSubmitted: widget.onSubmitted,
        style: TextStyle(color: AppTheme.textPrimary, fontSize: 16),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(AppTheme.spacingM),
          prefixIcon: Icon(
            Icons.search,
            color: _hasFocus ? AppTheme.primaryColor : AppTheme.textSecondary,
          ),
          suffixIcon: _hasText
              ? GestureDetector(
                  onTap: _onClear,
                  child: const Icon(Icons.clear, color: AppTheme.textSecondary),
                )
              : null,
        ),
      ),
    );
  }
}
