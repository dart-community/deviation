import 'dart:collection';

import 'package:meta/meta.dart';

import 'patch.dart';
import 'update.dart';

/// An implementation if a diff algorithm that can calculate
/// a [Patch] to convert from one list to another.
abstract interface class DiffAlgorithm {
  /// Create an implementation of the
  /// (non-linear space) greedy diff algorithm by Myers (1986).
  const factory DiffAlgorithm.myers() = _MyersDiffAlgorithm;

  /// Compute the difference between the [source] and [target] lists,
  /// and determine a [Patch] to convert from the [source] to the [target].
  ///
  /// [T] must provide support comparisons using
  /// `equal` to other instances of [T].
  @useResult
  Patch<T> compute<T extends Object>(
      final List<T> source, final List<T> target);
}

/// A utility base class so implementers of [DiffAlgorithm]
/// can just worry about implementing [_computeUpdates]
/// and returning an iterable of the updates determined.
abstract base class _BaseDiffAlgorithm implements DiffAlgorithm {
  const _BaseDiffAlgorithm();

  @override
  Patch<T> compute<T extends Object>(
    final List<T> source,
    final List<T> target,
  ) {
    return Patch(_computeUpdates(source, target));
  }

  Iterable<Update<T>> _computeUpdates<T extends Object>(
    final List<T> source,
    final List<T> target,
  );
}

/// Implements the (non-linear space) greedy diff algorithm by Myers (1986).
///
/// References:
/// - http://www.xmailserver.org/diff2.pdf
/// - https://blog.jcoglan.com/2017/02/12/the-myers-diff-algorithm-part-1/
final class _MyersDiffAlgorithm extends _BaseDiffAlgorithm {
  const _MyersDiffAlgorithm();

  @override
  Iterable<Update<T>> _computeUpdates<T extends Object>(
    final List<T> source,
    final List<T> target,
  ) {
    if (source.isEmpty && target.isEmpty) {
      return [];
    }

    if (identical(source, target)) {
      return [
        for (var index = 0; index < source.length; index += 1)
          Keep(source[index], index, index)
      ];
    }

    final result = _shortestEdit(source, target);
    final updates = Queue<Update<T>>();

    // Backtrack through the shortest edit path to determine
    // a collection of edits that resulted in the target from the source.
    for (_HistoryNode? current = result, previous = current.previous;
        current != null && previous != null && previous.indexInTarget >= 0;
        current = previous, previous = previous.previous) {
      final currentIndexInSource = current.indexInSource;
      final currentIndexInTarget = current.indexInTarget;

      final previousIndexInSource = previous.indexInSource;
      final previousIndexInTarget = previous.indexInTarget;

      if (currentIndexInSource == previousIndexInSource) {
        assert(currentIndexInTarget != previousIndexInTarget);
        updates.addFirst(Insert(
          target[previousIndexInTarget],
          previousIndexInSource,
          previousIndexInTarget,
        ));
      } else if (currentIndexInTarget == previousIndexInTarget) {
        assert(currentIndexInSource != previousIndexInSource);
        updates.addFirst(Remove(
          source[previousIndexInSource],
          previousIndexInSource,
          previousIndexInTarget,
        ));
      } else {
        updates.addFirst(Keep(
          source[previousIndexInSource],
          previousIndexInSource,
          previousIndexInTarget,
        ));
      }
    }

    return updates;
  }
}

_HistoryNode _shortestEdit<T>(
  final List<T> source,
  final List<T> target,
) {
  final sourceCount = source.length;
  final targetCount = target.length;
  final max = sourceCount + targetCount;

  /// The nodes containing the furthest reaching end point (indices) possible
  /// from a specific distance from the center diagonal.
  final furthestReaching = List<_HistoryNode?>.filled(
    max * 2 + 1,
    null,
    growable: false,
  );

  // Both directions have an initial previous furthest of index 0 in the source
  // and -1 in the target (since none of it exists yet).
  furthestReaching.setFromEitherSide(1, const _HistoryNode(0, -1, null));

  for (var step = 0; step <= max; step += 1) {
    for (var distanceFromOther = -step;
        distanceFromOther <= step;
        distanceFromOther += 2) {
      int nextIndexInSource;
      final _HistoryNode previousFurthest;
      if (distanceFromOther == -step ||
          (distanceFromOther != step &&
              furthestReaching
                      .getFromEitherSide(distanceFromOther + 1)
                      .indexInSource >
                  furthestReaching
                      .getFromEitherSide(distanceFromOther - 1)
                      .indexInSource)) {
        // Move downward.
        previousFurthest =
            furthestReaching.getFromEitherSide(distanceFromOther + 1);
        nextIndexInSource = previousFurthest.indexInSource;
      } else {
        // Move right.
        previousFurthest =
            furthestReaching.getFromEitherSide(distanceFromOther - 1);
        nextIndexInSource = previousFurthest.indexInSource + 1;
      }

      var nextIndexInTarget = nextIndexInSource - distanceFromOther;

      var currentPosition =
          _HistoryNode(nextIndexInSource, nextIndexInTarget, previousFurthest);

      // Take as many common steps as possible.
      // We can do so if we haven't consumed the entire source and target and
      // the elements at the current position of each are the same.
      while (nextIndexInSource < sourceCount &&
          nextIndexInTarget < targetCount &&
          source[nextIndexInSource] == target[nextIndexInTarget]) {
        nextIndexInSource += 1;
        nextIndexInTarget += 1;

        currentPosition =
            _HistoryNode(nextIndexInSource, nextIndexInTarget, currentPosition);
      }

      // If we've reached the end of the original and target text,
      // we've made the necessary edits to become the target text.
      if (nextIndexInSource >= sourceCount &&
          nextIndexInTarget >= targetCount) {
        return currentPosition;
      }

      furthestReaching.setFromEitherSide(distanceFromOther, currentPosition);
    }
  }

  // This should not happen as we search from 0 to max (source + target length),
  // which should find a path even if the contents are completely different.
  throw StateError(
    'No edit script less than the combined length of source and target exists. '
    'Report this error at https://github.com/dart-community/deviation.',
  );
}

@immutable
final class _HistoryNode {
  final int indexInSource;
  final int indexInTarget;
  final _HistoryNode? previous;

  const _HistoryNode(this.indexInSource, this.indexInTarget, this.previous);
}

extension on List<_HistoryNode?> {
  _HistoryNode getFromEitherSide(final int index) => this[_middle + index]!;

  void setFromEitherSide(final int index, final _HistoryNode value) =>
      this[_middle + index] = value;

  int get _middle => length ~/ 2;
}
