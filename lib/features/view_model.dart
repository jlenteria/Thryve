import 'package:flutter/foundation.dart';

/// Base view model class that provides common functionality for state management.
///
/// The [ViewModel] class extends [ChangeNotifier] and provides:
/// * Loading state management through [isLoading], [startLoading], and [stopLoading]
/// * Error handling through [onErrorListener] callback
/// * Safe disposal of resources with [dispose]
/// * Protection against updates after disposal
///
/// Example usage in a view model:
/// ```dart
/// class MyViewModel extends ViewModel {
///   Future<void> loadData() async {
///     startLoading();
///     try {
///       // Load data
///     } catch (e) {
///       onErrorListener?.call(e.toString());
///     } finally {
///       stopLoading();
///     }
///   }
/// }
/// ```
///
/// Example usage in StatefulWidget:
/// ```dart
/// class MyWidget extends StatefulWidget {
///   @override
///   State<MyWidget> createState() => _MyWidgetState();
/// }
///
/// class _MyWidgetState extends State<MyWidget> {
///   @override
///   void initState() {
///     super.initState();
///     context.read<MyViewModel>().onErrorListener = (String error) {
///       if (mounted) {
///         ScaffoldMessenger.of(context).showSnackBar(
///           SnackBar(content: Text(error)),
///         );
///       }
///     };
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return Consumer<MyViewModel>(
///       builder: (context, viewModel, child) {
///         ...
///       },
///     );
///   }
/// }
/// ```
///
/// Example usage in StatelessWidget:
/// ```dart
/// class MyStatelessWidget extends StatelessWidget {
///   MyStatelessWidget({super.key});
///
///   @override
///   Widget build(BuildContext context) {
///     // Set error listener in build, but use mounted check in callback
///     context.read<MyViewModel>().onErrorListener = (String error) {
///       ScaffoldMessenger.of(context).showSnackBar(
///         SnackBar(content: Text(error)),
///       );
///     };
///
///     return Consumer<MyViewModel>(
///       builder: (context, viewModel, child) {
///          ...
///       },
///     );
///   }
/// }
/// ```
///
/// The view model handles common patterns like:
/// * Preventing duplicate loading states
/// * Safely notifying listeners only when active
/// * Proper cleanup on disposal
///
/// See also:
/// * [ChangeNotifier] - The base class that enables observer pattern
/// * [ValueChanged] - Type for the error callback
///
class ViewModel with ChangeNotifier {
  /// Listener when error occurs.
  ValueChanged<String>? onErrorListener;

  /// State if viewmodel is processing something or not.
  bool get isLoading => _isLoading;
  bool _isLoading = false;
  bool _isDisposed = false;

  /// Start loading state.
  /// This will set the [isLoading] to TRUE.
  ///
  /// NOTE: This will notify the listeners of this viewmodel.
  @protected
  void startLoading() {
    if (isLoading) {
      return;
    }
    _isLoading = true;
    notifyListeners();
  }

  /// Stop loading state.
  /// This will set the [isLoading] to FALSE.
  ///
  /// NOTE: This will notify the listeners of this viewmodel.
  @protected
  void stopLoading() {
    _isLoading = false;
    notifyListeners();
  }

  @override
  void notifyListeners() {
    if (_isDisposed) {
      return;
    }
    super.notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
