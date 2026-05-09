import 'package:flutter/material.dart';
import 'user_state.dart';

/// An [InheritedNotifier] that provides [UserState] to the entire widget tree.
///
/// Wrap the [MaterialApp] with this widget so any descendant can call
/// `UserStateProvider.of(context)` to read or update user profile data.
///
/// Because it extends [InheritedNotifier], widgets that depend on it will
/// automatically rebuild when [UserState] calls `notifyListeners()`.
class UserStateProvider extends InheritedNotifier<UserState> {
  const UserStateProvider({
    super.key,
    required UserState userState,
    required super.child,
  }) : super(notifier: userState);

  /// Retrieves the [UserState] from the nearest ancestor [UserStateProvider].
  static UserState of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<UserStateProvider>();
    assert(provider != null, 'No UserStateProvider found in context');
    return provider!.notifier!;
  }
}
