import 'dart:collection';

import 'package:meta/meta.dart';

import '../deviation.dart';

/// A file diff format that closely resembles
/// the diffutils unified output format.
@immutable
final class UnifiedDiff {
  /// The header of this diff, often containing information
  /// such as source and target filename.
  final UnifiedDiffHeader header;

  /// The hunks of differences this diff is composed of.
  final Iterable<UnifiedDiffHunk> hunks;

  /// Create a new [UnifiedDiff] with the specified [header] and [hunks].
  const UnifiedDiff._(this.header, this.hunks);

  /// Create a [UnifiedDiff] from the specified [patch]
  /// using the information from the [header].
  ///
  /// By default [context] is `3`, resulting in 3 lines of code included
  /// on either side of a change for contextual purposes.
  ///
  /// To configure the header format for each hunk,
  /// pass in a custom [UnifiedDiffHunkHeaderConfig].
  factory UnifiedDiff.fromPatch(
    final Patch<String> patch, {
    required final UnifiedDiffHeader header,
    final int context = 3,
    final UnifiedDiffHunkHeaderConfig hunkHeaderConfig =
        const UnifiedDiffHunkHeaderConfig(),
  }) {
    final hunks = _calculateHunksFromPatch(patch, hunkHeaderConfig, context);

    return UnifiedDiff._(header, hunks);
  }

  /// Convert a [UnifiedDiff] back to a [Patch] between the
  /// source and target files.
  @useResult
  Patch<String> toPatch() =>
      Patch(hunks.map((final hunk) => hunk.updates).reduce(
            (final before, final after) => [...before, ...after],
          ));

  @override
  @useResult
  String toString() {
    final buffer = StringBuffer();
    buffer.write(header);
    for (final hunk in hunks) {
      buffer.write(hunk);
    }
    return buffer.toString();
  }
}

/// A unified diff hunk, including its [header] and [updates].
@immutable
final class UnifiedDiffHunk {
  /// The header of this diff hunk.
  final UnifiedDiffHunkHeader header;

  /// All updates included within this diff hunk.
  final Iterable<Update<String>> updates;

  /// Create a new [UnifiedDiffHunk] with the specified [header] and [updates].
  UnifiedDiffHunk._(this.header, final Iterable<Update<String>> updates)
      : updates = updates.toList(growable: false);

  @override
  @useResult
  String toString() {
    final buffer = StringBuffer();
    buffer.write(header);
    for (final update in updates) {
      buffer.writeln(update);
    }
    return buffer.toString();
  }
}

/// The header of a [UnifiedDiffHunk].
@immutable
final class UnifiedDiffHunkHeader {
  /// The configuration of how to format the
  /// [toString] representation of this header.
  final UnifiedDiffHunkHeaderConfig config;

  /// The line in the target list this hunk starts representing.
  final int sourceStartLine;

  /// The amount of lines in the source list this hunk represents.
  final int sourceCount;

  /// The line in the target file this hunk starts representing.
  final int targetStartLine;

  /// The amount of lines in the target list this hunk represents.
  final int targetCount;

  /// If the amount of lines should be output as well.
  ///
  /// Generally `true`, except if the hunk is only one line.
  final bool outputCounts;

  const UnifiedDiffHunkHeader._({
    required this.config,
    required this.sourceStartLine,
    required this.sourceCount,
    required this.targetStartLine,
    required this.targetCount,
    this.outputCounts = true,
  });

  @override
  @useResult
  String toString() {
    final buffer = StringBuffer();
    buffer.write(config.openTag);
    buffer.write(' -');
    buffer.write(sourceStartLine);
    if (outputCounts) {
      buffer.write(',');
      buffer.write(sourceCount);
    }
    buffer.write(' +');
    buffer.write(targetStartLine);
    if (outputCounts) {
      buffer.write(',');
      buffer.write(targetCount);
    }
    buffer.write(' ');
    buffer.write(config.closeTag);
    final labelToApply = config.defaultLabel;
    if (labelToApply != null) {
      buffer.write(' ');
      buffer.write(labelToApply);
    }
    buffer.writeln();
    return buffer.toString();
  }
}

/// A shared configuration for creating the
/// string representation of a [UnifiedDiffHunkHeader].
@immutable
final class UnifiedDiffHunkHeaderConfig {
  /// The tag that usually appears at the
  /// beginning of a unified diff hunk header.
  final String openTag;

  /// The tag that usually appears after the line information
  /// in a unified diff hunk header.
  final String closeTag;

  /// The optional text that usually appears after the [closeTag]
  /// in a unified diff hunk header.
  final String? defaultLabel;

  /// Create a new [UnifiedDiffHunkHeaderConfig] with the specified
  /// [openTag], [closeTag], and [defaultLabel].
  ///
  /// The [defaultLabel] if supplied, generally appears after the [closeTag].
  const UnifiedDiffHunkHeaderConfig({
    this.openTag = '@@',
    this.closeTag = '@@',
    this.defaultLabel,
  });
}

/// The header of a [UnifiedDiff], generally with two lines,
/// one [sourceLine] representing the source file, and
/// one [targetLine] representing the target file.
@immutable
abstract final class UnifiedDiffHeader {
  /// The line that represents the source file in a unified diff header.
  String get sourceLine;

  /// The line that represents the target file in a unified diff header.
  String get targetLine;

  /// The constant super constructor of [UnifiedDiffHeader] subtypes.
  const UnifiedDiffHeader();

  /// Create a custom [UnifiedDiffHeader] with
  /// [sourceLineContent] and [targetLineContent], and
  /// optionally a custom [sourceLineStart] and [targetLineStart].
  const factory UnifiedDiffHeader.custom({
    final String? sourceLineStart,
    final String? targetLineStart,
    required final String sourceLineContent,
    required final String targetLineContent,
  }) = _CustomUnifiedDiffHeader;

  /// Create a traditional [UnifiedDiffHeader] including the
  /// [sourcePath] and [sourceModificationTime] of the source file, and the
  /// [targetPath] and [targetModificationTime] of the target file.
  const factory UnifiedDiffHeader.traditional({
    required final String sourcePath,
    required final DateTime sourceModificationTime,
    required final String targetPath,
    required final DateTime targetModificationTime,
  }) = _TraditionalUnifiedDiffHeader;

  /// Create a simple [UnifiedDiffHeader] with no extra information
  /// in the header besides 'source' and 'target'.
  const factory UnifiedDiffHeader.simple() = _SimpleUnifiedDiffHeader;

  /// Create an empty [UnifiedDiffHeader] that doesn't add to the diff output.
  const factory UnifiedDiffHeader.none() = _EmptyUnifiedDiffHeader;

  @override
  String toString() {
    return '$sourceLine\n$targetLine\n';
  }
}

@immutable
final class _CustomUnifiedDiffHeader extends UnifiedDiffHeader {
  final String? sourceLineStart;
  final String? targetLineStart;

  final String sourceLineContent;
  final String targetLineContent;

  const _CustomUnifiedDiffHeader({
    this.sourceLineStart = '---',
    this.targetLineStart = '+++',
    required this.sourceLineContent,
    required this.targetLineContent,
  });

  @override
  String get sourceLine {
    final buffer = StringBuffer();
    if (sourceLineStart != null) {
      buffer.write(sourceLineStart);
      buffer.write(' ');
    }
    buffer.write(sourceLineContent);
    return buffer.toString();
  }

  @override
  String get targetLine {
    final buffer = StringBuffer();
    if (targetLineStart != null) {
      buffer.write(targetLineStart);
      buffer.write(' ');
    }
    buffer.write(targetLineContent);
    return buffer.toString();
  }
}

@immutable
final class _TraditionalUnifiedDiffHeader extends _CustomUnifiedDiffHeader {
  final String sourcePath;
  final DateTime sourceModificationTime;

  final String targetPath;
  final DateTime targetModificationTime;

  const _TraditionalUnifiedDiffHeader({
    required this.sourcePath,
    required this.sourceModificationTime,
    required this.targetPath,
    required this.targetModificationTime,
  }) : super(
          sourceLineContent: '$sourcePath $sourceModificationTime',
          targetLineContent: '$targetPath $targetModificationTime',
        );
}

@immutable
final class _SimpleUnifiedDiffHeader extends UnifiedDiffHeader {
  const _SimpleUnifiedDiffHeader() : super();

  @override
  String get sourceLine => 'source';

  @override
  String get targetLine => 'target';
}

@immutable
final class _EmptyUnifiedDiffHeader extends UnifiedDiffHeader {
  const _EmptyUnifiedDiffHeader() : super();

  @override
  String get sourceLine => '';

  @override
  String get targetLine => '';

  @override
  String toString() => '';
}

@useResult
Iterable<UnifiedDiffHunk> _calculateHunksFromPatch(
  final Patch<String> patch,
  final UnifiedDiffHunkHeaderConfig hunkHeaderConfig,
  final int context,
) {
  final updates = patch.updates;

  var currentContext = 0;
  var hasFoundChange = false;
  final currentHunk = Queue<Update<String>>();
  final hunks = <UnifiedDiffHunk>[];

  void nextHunk() {
    currentContext = 0;
    hasFoundChange = false;
    if (currentHunk.isEmpty) {
      return;
    }

    int? sourceStart;
    int? targetStart;
    var sourceLength = 0;
    var targetLength = 0;

    for (final update in currentHunk) {
      switch (update) {
        case Keep(:final indexInSource, :final indexInTarget):
          sourceStart ??= indexInSource + 1;
          targetStart ??= indexInTarget + 1;

          sourceLength += 1;
          targetLength += 1;
        case Insert(:final indexInTarget):
          targetStart ??= indexInTarget + 1;

          targetLength += 1;
        case Remove(:final indexInSource):
          sourceStart ??= indexInSource + 1;

          sourceLength += 1;
      }
    }

    final hunkHeader = UnifiedDiffHunkHeader._(
      config: hunkHeaderConfig,
      sourceStartLine: sourceStart ?? 1,
      sourceCount: sourceLength,
      targetStartLine: targetStart ?? 1,
      targetCount: targetLength,
      outputCounts: currentHunk.length != 1,
    );

    final hunk = UnifiedDiffHunk._(hunkHeader, currentHunk);

    hunks.add(hunk);
    currentHunk.clear();
  }

  for (final value in updates) {
    currentHunk.add(value);
    if (value is Keep) {
      currentContext += 1;
    } else {
      hasFoundChange = true;
      currentContext = 0;
    }

    if (hasFoundChange) {
      if (currentContext == context) {
        nextHunk();
      }
    } else if (currentContext > context) {
      currentHunk.removeFirst();
    }
  }

  if (hasFoundChange) {
    nextHunk();
  }

  return hunks;
}
