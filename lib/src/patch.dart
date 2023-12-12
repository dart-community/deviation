import 'package:meta/meta.dart';

import 'update.dart';

/// A collection of different [Update] types and values
/// that indicate the differences between a source and target list.
@immutable
final class Patch<T extends Object> {
  final List<Update<T>> _updates;

  /// Create a new [Patch] with the specified [Update] values.
  Patch(final Iterable<Update<T>> updates)
      : _updates = List<Update<T>>.unmodifiable(updates);

  /// The updates from a source to a target list.
  Iterable<Update<T>> get updates => _updates;
}
