import 'dart:io';

import 'package:deviation/deviation.dart';
import 'package:deviation/unified_diff.dart';

void main() {
  final sourceFile = File('source.txt');
  final targetFile = File('target.txt');

  final diffPatch = const DiffAlgorithm.myers().compute(
    sourceFile.readAsLinesSync(),
    targetFile.readAsLinesSync(),
  );

  print(UnifiedDiff.fromPatch(
    diffPatch,
    header: UnifiedDiffHeader.traditional(
      sourcePath: sourceFile.path,
      sourceModificationTime: sourceFile.lastModifiedSync(),
      targetPath: targetFile.path,
      targetModificationTime: targetFile.lastModifiedSync(),
    ),
  ));
}
