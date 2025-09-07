/// Lifecycle Aware Widget Mixin - Automatic state preservation for widgets
///
/// PATTERN: Mixin Pattern + Template Method + Observer
/// WHERE: Core lifecycle management - Widget state preservation
/// HOW: Provides automatic state capture and restoration for StatefulWidgets
/// WHY: Simplifies lifecycle management for UI components
library;

import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../core/logging/logging.dart';
import '../entities/lifecycle_event.dart';
import '../patterns/lifecycle_observer_pattern.dart';
import '../services/lifecycle_manager.dart';

/// Mixin that provides automatic state preservation for StatefulWidgets.
///
/// Widgets using this mixin will automatically save and restore their state
/// during app lifecycle events without manual intervention.
mixin LifecycleAwareWidget<T extends StatefulWidget> on State<T>
    implements StateAwareObserver {
  StreamSubscription<LifecycleEvent>? _lifecycleSubscription;
  Map<String, dynamic>? _savedState;
  bool _isStateRestored = false;
  bool _isRegistered = false;

  /// Override this to specify which state should be preserved
  Map<String, dynamic> captureWidgetState();

  /// Override this to restore widget state
  Future<void> restoreWidgetState(Map<String, dynamic> state);

  /// Override this to validate saved state
  bool validateWidgetState(Map<String, dynamic> state) => true;

  /// Override this to provide a unique state key for this widget
  @override
  String get stateKey => runtimeType.toString();

  @override
  String get observerId => 'widget_${stateKey}_$hashCode';

  @override
  EventPriority get priority => EventPriority.medium;

  @override
  void initState() {
    super.initState();
    _registerLifecycleObserver();
  }

  @override
  void dispose() {
    _unregisterLifecycleObserver();
    super.dispose();
  }

  // StateAwareObserver implementation
  @override
  Map<String, dynamic> captureState() {
    try {
      Log.debug('LifecycleAwareWidget: Capturing state for $stateKey');
      final state = captureWidgetState();
      _savedState = state;
      return state;
    } catch (e) {
      Log.error(
        'LifecycleAwareWidget: Failed to capture state for $stateKey: $e',
      );
      return {};
    }
  }

  @override
  Future<void> restoreState(Map<String, dynamic> state) async {
    try {
      if (!validateWidgetState(state)) {
        Log.warning(
          'LifecycleAwareWidget: Invalid state for $stateKey, skipping restore',
        );
        return;
      }

      Log.debug('LifecycleAwareWidget: Restoring state for $stateKey');
      await restoreWidgetState(state);
      _savedState = state;
      _isStateRestored = true;
    } catch (e) {
      Log.error(
        'LifecycleAwareWidget: Failed to restore state for $stateKey: $e',
      );
    }
  }

  @override
  bool validateState(Map<String, dynamic> state) {
    return validateWidgetState(state);
  }

  @override
  void onLifecycleEvent(LifecycleEvent event) {
    if (mounted) {
      if (event.shouldPersistState) {
        captureState();
      } else if (event.isForegrounding &&
          !_isStateRestored &&
          _savedState != null) {
        restoreState(_savedState!);
      }
    }
  }

  @override
  void onRegistered() {
    Log.debug('LifecycleAwareWidget: Observer registered for $stateKey');
  }

  @override
  void onUnregistered() {
    Log.debug('LifecycleAwareWidget: Observer unregistered for $stateKey');
  }

  // Private methods
  void _registerLifecycleObserver() {
    if (!_isRegistered) {
      try {
        final lifecycleManager = LifecycleManager.instance;
        lifecycleManager.addObserver(this);

        // Subscribe to lifecycle events stream
        _lifecycleSubscription = lifecycleManager.eventStream.listen(
          (event) {
            if (shouldHandleEvent(event)) {
              onLifecycleEvent(event);
            }
          },
          onError: (error) {
            Log.error(
              'LifecycleAwareWidget: Lifecycle event stream error: $error',
            );
          },
        );

        _isRegistered = true;
        onRegistered();
      } catch (e) {
        Log.error(
          'LifecycleAwareWidget: Failed to register lifecycle observer: $e',
        );
      }
    }
  }

  void _unregisterLifecycleObserver() {
    if (_isRegistered) {
      try {
        final lifecycleManager = LifecycleManager.instance;
        lifecycleManager.removeObserver(this);
        _lifecycleSubscription?.cancel();
        _lifecycleSubscription = null;
        _isRegistered = false;
        onUnregistered();
      } catch (e) {
        Log.error(
          'LifecycleAwareWidget: Failed to unregister lifecycle observer: $e',
        );
      }
    }
  }

  // Utility getters
  bool get isStateRestored => _isStateRestored;

  Map<String, dynamic>? get savedState => _savedState;

  bool get hasLifecycleManager {
    try {
      LifecycleManager.instance;
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Specialized mixin for form widgets with automatic field preservation
mixin LifecycleAwareForm<T extends StatefulWidget>
    on State<T>, LifecycleAwareWidget<T> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};
  final Map<String, bool> _validationStates = {};

  @override
  String get stateKey => 'form_${super.stateKey}';

  /// Register a text controller for automatic state management
  void registerController(String fieldName, TextEditingController controller) {
    _controllers[fieldName] = controller;
  }

  /// Register a focus node for automatic state management
  void registerFocusNode(String fieldName, FocusNode focusNode) {
    _focusNodes[fieldName] = focusNode;
  }

  /// Register validation state for a field
  void setFieldValidation(String fieldName, bool isValid) {
    _validationStates[fieldName] = isValid;
  }

  @override
  Map<String, dynamic> captureWidgetState() {
    final formState = <String, dynamic>{};

    // Capture text field values
    final textFields = <String, String>{};
    for (final entry in _controllers.entries) {
      textFields[entry.key] = entry.value.text;
    }
    formState['textFields'] = textFields;

    // Capture focus states
    final focusStates = <String, bool>{};
    for (final entry in _focusNodes.entries) {
      focusStates[entry.key] = entry.value.hasFocus;
    }
    formState['focusStates'] = focusStates;

    // Capture validation states
    formState['validationStates'] = Map.from(_validationStates);

    // Add timestamp
    formState['capturedAt'] = DateTime.now().toIso8601String();

    return formState;
  }

  @override
  Future<void> restoreWidgetState(Map<String, dynamic> state) async {
    // Restore text field values
    final textFields = state['textFields'] as Map<String, dynamic>? ?? {};
    for (final entry in textFields.entries) {
      final controller = _controllers[entry.key];
      if (controller != null && entry.value is String) {
        controller.text = entry.value;
      }
    }

    // Restore focus states (after a small delay to allow widget tree to build)
    final focusStates = state['focusStates'] as Map<String, dynamic>? ?? {};
    await Future.delayed(const Duration(milliseconds: 100));
    for (final entry in focusStates.entries) {
      final focusNode = _focusNodes[entry.key];
      if (focusNode != null && entry.value is bool && entry.value) {
        focusNode.requestFocus();
        break; // Only one field can have focus
      }
    }

    // Restore validation states
    final validationStates =
        state['validationStates'] as Map<String, dynamic>? ?? {};
    for (final entry in validationStates.entries) {
      if (entry.value is bool) {
        _validationStates[entry.key] = entry.value;
      }
    }
  }

  @override
  bool validateWidgetState(Map<String, dynamic> state) {
    return state.containsKey('textFields') &&
        state.containsKey('focusStates') &&
        state.containsKey('validationStates');
  }

  @override
  void dispose() {
    // Dispose controllers and focus nodes
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes.values) {
      focusNode.dispose();
    }
    _controllers.clear();
    _focusNodes.clear();
    super.dispose();
  }
}

/// Specialized mixin for scroll-aware widgets
mixin LifecycleAwareScrollable<T extends StatefulWidget>
    on State<T>, LifecycleAwareWidget<T> {
  final Map<String, ScrollController> _scrollControllers = {};

  @override
  String get stateKey => 'scroll_${super.stateKey}';

  /// Register a scroll controller for automatic state management
  void registerScrollController(String scrollKey, ScrollController controller) {
    _scrollControllers[scrollKey] = controller;
  }

  @override
  Map<String, dynamic> captureWidgetState() {
    final scrollState = <String, dynamic>{};
    final scrollPositions = <String, double>{};

    for (final entry in _scrollControllers.entries) {
      if (entry.value.hasClients) {
        scrollPositions[entry.key] = entry.value.offset;
      }
    }

    scrollState['scrollPositions'] = scrollPositions;
    scrollState['capturedAt'] = DateTime.now().toIso8601String();

    return scrollState;
  }

  @override
  Future<void> restoreWidgetState(Map<String, dynamic> state) async {
    final scrollPositions =
        state['scrollPositions'] as Map<String, dynamic>? ?? {};

    // Restore scroll positions after a delay to allow list to build
    await Future.delayed(const Duration(milliseconds: 300));

    for (final entry in scrollPositions.entries) {
      final controller = _scrollControllers[entry.key];
      if (controller != null && controller.hasClients && entry.value is num) {
        try {
          await controller.animateTo(
            entry.value.toDouble(),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } catch (e) {
          // If animation fails, try direct jump
          controller.jumpTo(entry.value.toDouble());
        }
      }
    }
  }

  @override
  bool validateWidgetState(Map<String, dynamic> state) {
    return state.containsKey('scrollPositions');
  }

  @override
  void dispose() {
    for (final controller in _scrollControllers.values) {
      controller.dispose();
    }
    _scrollControllers.clear();
    super.dispose();
  }
}

/// Specialized mixin for animation-aware widgets
mixin LifecycleAwareAnimations<T extends StatefulWidget>
    on State<T>, LifecycleAwareWidget<T> {
  final Map<String, AnimationController> _animationControllers = {};
  final Map<String, bool> _wasAnimating = {};

  @override
  String get stateKey => 'animation_${super.stateKey}';

  /// Register an animation controller for automatic state management
  void registerAnimationController(
    String animationKey,
    AnimationController controller,
  ) {
    _animationControllers[animationKey] = controller;
  }

  @override
  Map<String, dynamic> captureWidgetState() {
    final animationState = <String, dynamic>{};
    final animationValues = <String, double>{};
    final animatingStates = <String, bool>{};

    for (final entry in _animationControllers.entries) {
      animationValues[entry.key] = entry.value.value;
      animatingStates[entry.key] = entry.value.isAnimating;
      _wasAnimating[entry.key] = entry.value.isAnimating;

      // Pause animation to save resources
      if (entry.value.isAnimating) {
        entry.value.stop();
      }
    }

    animationState['animationValues'] = animationValues;
    animationState['animatingStates'] = animatingStates;
    animationState['capturedAt'] = DateTime.now().toIso8601String();

    return animationState;
  }

  @override
  Future<void> restoreWidgetState(Map<String, dynamic> state) async {
    final animationValues =
        state['animationValues'] as Map<String, dynamic>? ?? {};
    final animatingStates =
        state['animatingStates'] as Map<String, dynamic>? ?? {};

    for (final entry in animationValues.entries) {
      final controller = _animationControllers[entry.key];
      if (controller != null && entry.value is num) {
        controller.value = entry.value.toDouble();
      }
    }

    // Resume animations that were running
    for (final entry in animatingStates.entries) {
      final controller = _animationControllers[entry.key];
      if (controller != null && entry.value is bool && entry.value) {
        // Resume animation (this might need customization based on animation type)
        controller.repeat();
      }
    }
  }

  @override
  bool validateWidgetState(Map<String, dynamic> state) {
    return state.containsKey('animationValues') &&
        state.containsKey('animatingStates');
  }

  @override
  void dispose() {
    for (final controller in _animationControllers.values) {
      controller.dispose();
    }
    _animationControllers.clear();
    super.dispose();
  }
}

/// Extension to make lifecycle registration easier
extension LifecycleRegistration on State {
  /// Quick registration for lifecycle awareness (if widget uses the mixin)
  void enableLifecycleAwareness() {
    if (this is LifecycleAwareWidget) {
      // Already handled by mixin
    } else {
      Log.warning(
        'LifecycleRegistration: Widget does not use LifecycleAwareWidget mixin',
      );
    }
  }
}

/// Utility class for manual lifecycle management without mixins
class LifecycleStateManager extends StateAwareObserver {
  final String _stateKey;
  final Map<String, dynamic> Function() _captureCallback;
  final Future<void> Function(Map<String, dynamic>) _restoreCallback;
  final bool Function(Map<String, dynamic>)? _validateCallback;

  LifecycleStateManager({
    required String stateKey,
    required Map<String, dynamic> Function() captureCallback,
    required Future<void> Function(Map<String, dynamic>) restoreCallback,
    bool Function(Map<String, dynamic>)? validateCallback,
  }) : _stateKey = stateKey,
       _captureCallback = captureCallback,
       _restoreCallback = restoreCallback,
       _validateCallback = validateCallback;

  @override
  String get stateKey => _stateKey;

  @override
  String get observerId => 'manual_${_stateKey}_$hashCode';

  @override
  Map<String, dynamic> captureState() => _captureCallback();

  @override
  Future<void> restoreState(Map<String, dynamic> state) =>
      _restoreCallback(state);

  @override
  bool validateState(Map<String, dynamic> state) {
    return _validateCallback?.call(state) ?? true;
  }

  @override
  void onLifecycleEvent(LifecycleEvent event) {
    if (event.shouldPersistState) {
      captureState();
    } else if (event.isForegrounding) {
      // Note: This would need to be connected to the StateManager
      // to actually restore state - this is a simplified version
    }
  }
}
