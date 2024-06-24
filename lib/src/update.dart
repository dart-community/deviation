import 'package:meta/meta.dart';

/// The change, or lack of change, of a value between a source and target list.
@immutable
sealed class Update<T extends Object> {
  /// The value that is part of this update.
  final T value;

  /// The index of this update in the source list.
  final int indexInSource;

  /// The index of this update in the target list.
  final int indexInTarget;

  /// The super constructor all of all [Update] types.
  const Update(this.value, this.indexInSource, this.indexInTarget);

  /// A string representation of this [Update],
  /// generally containing a prefix to indicate the type of update.
  @override
  @mustBeOverridden
  String toString();
}

/// A value that is the same between both lists.
@immutable
final class Keep<T extends Object> extends Update<T> {
  /// Create a [Keep] that represents a value that persists
  /// between the source and target.
  const Keep(super.value, super.indexInSource, super.indexInTarget);

  @override
  String toString() => '  $value';
}

/// A value that is added in the target list.
@immutable
final class Insert<T extends Object> extends Update<T> {
  /// Create an [Insert] that represents a value that
  /// is added in the target list.
  const Insert(super.value, super.indexInSource, super.indexInTarget);

  @override
  String toString() => '+ $value';
}

/// A value that is removed from the source list.
@immutable
final class Remove<T extends Object> extends Update<T> {
  /// Create a [Remove] that represents a value that
  /// is removed from the source list.
  const Remove(super.value, super.indexInSource, super.indexInTarget);

  @override
  String toString() => '- $value';
}
