A package for determining the differences between two lists
and generating unified diff output similar to the `diffutils` CLI tool.

> [!WARNING]
> This package is still a work in progress,
> expect changes to its API in future releases.

## Installation

To use `package:deviation` to generate diffs,
first add it as a dependency in your `pubspec.yaml` file:

```shell
dart pub add deviation
```

## Usage

To compute the difference between two lists,
create an instance of one of the supplied diff algorithms
and pass the two lists to the algorithm's `compute` method.

```dart
import 'package:deviation/deviation.dart';

void main() {
  final diffPatch = const DiffAlgorithm.myers().compute(
    ['1', '2', '3'],
    ['2', '3', '4'],
  );
}
```

The `compute` method will return a `Patch` with a list of `Update` objects.
If the `Patch` above is converted to a string representation and printed,
you'd get an output similar to `(-1,  2,  3, +4)`.

```dart
// Prints (-1,  2,  3, +4).
print(diffPatch.updates.map((u) => u.toString()));
```

For a more sophisticated textual output,
you can convert a `Patch` into a `UnifiedDiff`
that closely resembles the diffutils unified output format.
For example, using the above patch with minimal configuration:

```dart
print(UnifiedDiff.fromPatch(
  diffPatch,
  header: const UnifiedDiffHeader.none(),
));
```

Would result in output similar to the following:

```text
@@ -1,3 +1,3 @@
-1
 2
 3
+4
```
