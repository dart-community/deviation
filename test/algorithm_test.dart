import 'package:deviation/deviation.dart';
import 'package:test/test.dart';

void main() {
  const diffAlgorithm = DiffAlgorithm.myers();

  group('algorithm', () {
    group('simple cases', () {
      test('handles empty lists', () {
        expect(
          diffAlgorithm.compute(<String>[], <String>[]).updates,
          isEmpty,
        );
      });

      test('handles equal lists', () {
        final original = ['Hello', 'Dash!'];
        final equivalent = ['Hello', 'Dash!'];

        final diffResult = diffAlgorithm.compute(original, equivalent);

        expect(diffResult.updates, hasLength(original.length));
        expect(diffResult.updates, everyElement(isA<Keep<String>>()));

        for (var i = 0; i < original.length; i++) {
          final update = diffResult.updates.elementAt(i) as Keep<String>;
          expect(update.value, equals(original[i]));
          expect(update.indexInSource, equals(i));
          expect(update.indexInTarget, equals(i));
        }
      });

      test('handles identical list references', () {
        final values = ['Hello', 'Dash!'];
        final diffResult = diffAlgorithm.compute(values, values);

        expect(diffResult.updates, hasLength(values.length));
        expect(diffResult.updates, everyElement(isA<Keep<String>>()));

        for (var i = 0; i < values.length; i++) {
          final update = diffResult.updates.elementAt(i) as Keep<String>;
          expect(update.value, equals(values[i]));
          expect(update.indexInSource, equals(i));
          expect(update.indexInTarget, equals(i));
        }
      });
    });

    group('insertions', () {
      test('handles single insertion at beginning', () {
        final source = ['b', 'c'];
        final target = ['a', 'b', 'c'];
        final result = diffAlgorithm.compute(source, target);

        expect(result.updates, hasLength(3));
        expect(result.updates.elementAt(0), isA<Insert<String>>());
        expect(result.updates.elementAt(1), isA<Keep<String>>());
        expect(result.updates.elementAt(2), isA<Keep<String>>());

        final insert = result.updates.elementAt(0) as Insert<String>;
        expect(insert.value, equals('a'));
        expect(insert.indexInSource, equals(0));
        expect(insert.indexInTarget, equals(0));
      });

      test('handles single insertion at end', () {
        final source = ['a', 'b'];
        final target = ['a', 'b', 'c'];
        final result = diffAlgorithm.compute(source, target);

        expect(result.updates, hasLength(3));
        expect(result.updates.elementAt(0), isA<Keep<String>>());
        expect(result.updates.elementAt(1), isA<Keep<String>>());
        expect(result.updates.elementAt(2), isA<Insert<String>>());

        final insert = result.updates.elementAt(2) as Insert<String>;
        expect(insert.value, equals('c'));
        expect(insert.indexInSource, equals(2));
        expect(insert.indexInTarget, equals(2));
      });

      test('handles single insertion in middle', () {
        final source = ['a', 'c'];
        final target = ['a', 'b', 'c'];
        final result = diffAlgorithm.compute(source, target);

        expect(result.updates, hasLength(3));
        expect(result.updates.elementAt(0), isA<Keep<String>>());
        expect(result.updates.elementAt(1), isA<Insert<String>>());
        expect(result.updates.elementAt(2), isA<Keep<String>>());

        final insert = result.updates.elementAt(1) as Insert<String>;
        expect(insert.value, equals('b'));
        expect(insert.indexInSource, equals(1));
        expect(insert.indexInTarget, equals(1));
      });

      test('handles multiple insertions', () {
        final source = ['b', 'd'];
        final target = ['a', 'b', 'c', 'd', 'e'];
        final result = diffAlgorithm.compute(source, target);

        expect(result.updates, hasLength(5));
        expect(result.updates.elementAt(0), isA<Insert<String>>());
        expect(result.updates.elementAt(1), isA<Keep<String>>());
        expect(result.updates.elementAt(2), isA<Insert<String>>());
        expect(result.updates.elementAt(3), isA<Keep<String>>());
        expect(result.updates.elementAt(4), isA<Insert<String>>());

        final insert1 = result.updates.elementAt(0) as Insert<String>;
        expect(insert1.value, equals('a'));

        final insert2 = result.updates.elementAt(2) as Insert<String>;
        expect(insert2.value, equals('c'));

        final insert3 = result.updates.elementAt(4) as Insert<String>;
        expect(insert3.value, equals('e'));
      });

      test('handles insertion into empty list', () {
        final source = <String>[];
        final target = ['a', 'b', 'c'];
        final result = diffAlgorithm.compute(source, target);

        expect(result.updates, hasLength(3));
        expect(result.updates, everyElement(isA<Insert<String>>()));

        for (var i = 0; i < target.length; i++) {
          final insert = result.updates.elementAt(i) as Insert<String>;
          expect(insert.value, equals(target[i]));
          expect(insert.indexInSource, equals(0));
          expect(insert.indexInTarget, equals(i));
        }
      });
    });

    group('removals', () {
      test('handles single removal at beginning', () {
        final source = ['a', 'b', 'c'];
        final target = ['b', 'c'];
        final result = diffAlgorithm.compute(source, target);

        expect(result.updates, hasLength(3));
        expect(result.updates.elementAt(0), isA<Remove<String>>());
        expect(result.updates.elementAt(1), isA<Keep<String>>());
        expect(result.updates.elementAt(2), isA<Keep<String>>());

        final remove = result.updates.elementAt(0) as Remove<String>;
        expect(remove.value, equals('a'));
        expect(remove.indexInSource, equals(0));
        expect(remove.indexInTarget, equals(0));
      });

      test('handles single removal at end', () {
        final source = ['a', 'b', 'c'];
        final target = ['a', 'b'];
        final result = diffAlgorithm.compute(source, target);

        expect(result.updates, hasLength(3));
        expect(result.updates.elementAt(0), isA<Keep<String>>());
        expect(result.updates.elementAt(1), isA<Keep<String>>());
        expect(result.updates.elementAt(2), isA<Remove<String>>());

        final remove = result.updates.elementAt(2) as Remove<String>;
        expect(remove.value, equals('c'));
        expect(remove.indexInSource, equals(2));
        expect(remove.indexInTarget, equals(2));
      });

      test('handles single removal in middle', () {
        final source = ['a', 'b', 'c'];
        final target = ['a', 'c'];
        final result = diffAlgorithm.compute(source, target);

        expect(result.updates, hasLength(3));
        expect(result.updates.elementAt(0), isA<Keep<String>>());
        expect(result.updates.elementAt(1), isA<Remove<String>>());
        expect(result.updates.elementAt(2), isA<Keep<String>>());

        final remove = result.updates.elementAt(1) as Remove<String>;
        expect(remove.value, equals('b'));
        expect(remove.indexInSource, equals(1));
        expect(remove.indexInTarget, equals(1));
      });

      test('handles multiple removals', () {
        final source = ['a', 'b', 'c', 'd', 'e'];
        final target = ['b', 'd'];
        final result = diffAlgorithm.compute(source, target);

        expect(result.updates, hasLength(5));
        expect(result.updates.elementAt(0), isA<Remove<String>>());
        expect(result.updates.elementAt(1), isA<Keep<String>>());
        expect(result.updates.elementAt(2), isA<Remove<String>>());
        expect(result.updates.elementAt(3), isA<Keep<String>>());
        expect(result.updates.elementAt(4), isA<Remove<String>>());

        final remove1 = result.updates.elementAt(0) as Remove<String>;
        expect(remove1.value, equals('a'));

        final remove2 = result.updates.elementAt(2) as Remove<String>;
        expect(remove2.value, equals('c'));

        final remove3 = result.updates.elementAt(4) as Remove<String>;
        expect(remove3.value, equals('e'));
      });

      test('handles removal of all elements', () {
        final source = ['a', 'b', 'c'];
        final target = <String>[];
        final result = diffAlgorithm.compute(source, target);

        expect(result.updates, hasLength(3));
        expect(result.updates, everyElement(isA<Remove<String>>()));

        for (var i = 0; i < source.length; i++) {
          final remove = result.updates.elementAt(i) as Remove<String>;
          expect(remove.value, equals(source[i]));
          expect(remove.indexInSource, equals(i));
          expect(remove.indexInTarget, equals(0));
        }
      });
    });

    group('mixed operations', () {
      test('handles insertions and removals', () {
        final source = ['a', 'b', 'c', 'd'];
        final target = ['a', 'x', 'c', 'y'];
        final result = diffAlgorithm.compute(source, target);

        expect(result.updates, hasLength(6));
        expect(result.updates.elementAt(0), isA<Keep<String>>());
        expect(result.updates.elementAt(0).value, equals('a'));
        expect(result.updates.elementAt(1), isA<Remove<String>>());
        expect(result.updates.elementAt(1).value, equals('b'));
        expect(result.updates.elementAt(2), isA<Insert<String>>());
        expect(result.updates.elementAt(2).value, equals('x'));
        expect(result.updates.elementAt(3), isA<Keep<String>>());
        expect(result.updates.elementAt(3).value, equals('c'));
        expect(result.updates.elementAt(4), isA<Remove<String>>());
        expect(result.updates.elementAt(4).value, equals('d'));
        expect(result.updates.elementAt(5), isA<Insert<String>>());
        expect(result.updates.elementAt(5).value, equals('y'));
      });

      test('handles replacements (remove then insert)', () {
        final source = ['a', 'b', 'c'];
        final target = ['a', 'x', 'c'];
        final result = diffAlgorithm.compute(source, target);

        expect(result.updates, hasLength(4));
        expect(result.updates.elementAt(0), isA<Keep<String>>());
        expect(result.updates.elementAt(0).value, equals('a'));
        expect(result.updates.elementAt(1), isA<Remove<String>>());
        expect(result.updates.elementAt(1).value, equals('b'));
        expect(result.updates.elementAt(2), isA<Insert<String>>());
        expect(result.updates.elementAt(2).value, equals('x'));
        expect(result.updates.elementAt(3), isA<Keep<String>>());
        expect(result.updates.elementAt(3).value, equals('c'));
      });

      test('handles complex mixed operations', () {
        final source = ['a', 'b', 'c', 'd', 'e', 'f'];
        final target = ['x', 'b', 'y', 'z', 'e', 'p'];
        final result = diffAlgorithm.compute(source, target);

        expect(result.updates, hasLength(10));

        final keeps = result.updates.whereType<Keep<String>>();
        final inserts = result.updates.whereType<Insert<String>>();
        final removes = result.updates.whereType<Remove<String>>();

        expect(keeps, hasLength(2)); // 'b' and 'e'
        expect(inserts, hasLength(4)); // 'x', 'y', 'z', 'p'
        expect(removes, hasLength(4)); // 'a', 'c', 'd', 'f'

        expect(keeps.map((k) => k.value), containsAll(['b', 'e']));
        expect(inserts.map((i) => i.value), containsAll(['x', 'y', 'z', 'p']));
        expect(removes.map((r) => r.value), containsAll(['a', 'c', 'd', 'f']));

        // Verify the specific sequence based on the debug output
        expect(result.updates.elementAt(0), isA<Remove<String>>());
        expect(result.updates.elementAt(0).value, equals('a'));
        expect(result.updates.elementAt(1), isA<Insert<String>>());
        expect(result.updates.elementAt(1).value, equals('x'));
        expect(result.updates.elementAt(2), isA<Keep<String>>());
        expect(result.updates.elementAt(2).value, equals('b'));
        expect(result.updates.elementAt(3), isA<Remove<String>>());
        expect(result.updates.elementAt(3).value, equals('c'));
        expect(result.updates.elementAt(4), isA<Remove<String>>());
        expect(result.updates.elementAt(4).value, equals('d'));
        expect(result.updates.elementAt(5), isA<Insert<String>>());
        expect(result.updates.elementAt(5).value, equals('y'));
        expect(result.updates.elementAt(6), isA<Insert<String>>());
        expect(result.updates.elementAt(6).value, equals('z'));
        expect(result.updates.elementAt(7), isA<Keep<String>>());
        expect(result.updates.elementAt(7).value, equals('e'));
        expect(result.updates.elementAt(8), isA<Remove<String>>());
        expect(result.updates.elementAt(8).value, equals('f'));
        expect(result.updates.elementAt(9), isA<Insert<String>>());
        expect(result.updates.elementAt(9).value, equals('p'));
      });
    });

    group('special cases', () {
      test('handles completely different lists', () {
        final source = ['a', 'b', 'c'];
        final target = ['x', 'y', 'z'];
        final result = diffAlgorithm.compute(source, target);

        expect(result.updates, hasLength(6));

        final removes = result.updates.whereType<Remove<String>>();
        final inserts = result.updates.whereType<Insert<String>>();

        expect(removes, hasLength(3));
        expect(inserts, hasLength(3));

        expect(removes.map((r) => r.value), containsAll(['a', 'b', 'c']));
        expect(inserts.map((i) => i.value), containsAll(['x', 'y', 'z']));
      });

      test('handles lists with repeated elements', () {
        final source = ['a', 'a', 'b', 'c'];
        final target = ['a', 'b', 'b', 'c'];
        final result = diffAlgorithm.compute(source, target);

        expect(result.updates, hasLength(5));

        expect(result.updates.elementAt(0), isA<Keep<String>>());
        expect(result.updates.elementAt(0).value, equals('a'));
        expect(result.updates.elementAt(1), isA<Remove<String>>());
        expect(result.updates.elementAt(1).value, equals('a'));
        expect(result.updates.elementAt(2), isA<Keep<String>>());
        expect(result.updates.elementAt(2).value, equals('b'));
        expect(result.updates.elementAt(3), isA<Insert<String>>());
        expect(result.updates.elementAt(3).value, equals('b'));
        expect(result.updates.elementAt(4), isA<Keep<String>>());
        expect(result.updates.elementAt(4).value, equals('c'));
      });

      test('handles large lists', () {
        final source = [
          for (var index = 0; index < 100; index += 1) 'source $index',
        ];
        final target = [
          for (var index = 0; index < 100; index += 1) 'target $index',
        ];
        final result = diffAlgorithm.compute(source, target);

        expect(result.updates, hasLength(200));

        final removes = result.updates.whereType<Remove<String>>();
        final inserts = result.updates.whereType<Insert<String>>();

        expect(removes, hasLength(100));
        expect(inserts, hasLength(100));
      });
    });

    group('non-string types', () {
      test('handles integers', () {
        final source = [1, 2, 3];
        final target = [1, 4, 3];
        final result = diffAlgorithm.compute(source, target);

        expect(result.updates, hasLength(4));
        expect(result.updates.elementAt(0), isA<Keep<int>>());
        expect(result.updates.elementAt(0).value, equals(1));
        expect(result.updates.elementAt(1), isA<Remove<int>>());
        expect(result.updates.elementAt(1).value, equals(2));
        expect(result.updates.elementAt(2), isA<Insert<int>>());
        expect(result.updates.elementAt(2).value, equals(4));
        expect(result.updates.elementAt(3), isA<Keep<int>>());
        expect(result.updates.elementAt(3).value, equals(3));
      });

      test('handles custom objects that implement custom equality', () {
        final source = [
          _TestObjectWithEquality('a', 1),
          _TestObjectWithEquality('b', 2),
          _TestObjectWithEquality('c', 3),
        ];
        final target = [
          _TestObjectWithEquality('a', 1),
          _TestObjectWithEquality('b', 2),
          _TestObjectWithEquality('d', 4),
        ];
        final result = diffAlgorithm.compute(source, target);

        expect(result.updates, hasLength(4));
        expect(
            result.updates.elementAt(0), isA<Keep<_TestObjectWithEquality>>());
        expect(result.updates.elementAt(0).value,
            equals(_TestObjectWithEquality('a', 1)));
        expect(
            result.updates.elementAt(1), isA<Keep<_TestObjectWithEquality>>());
        expect(result.updates.elementAt(1).value,
            equals(_TestObjectWithEquality('b', 2)));
        expect(result.updates.elementAt(2),
            isA<Remove<_TestObjectWithEquality>>());
        expect(result.updates.elementAt(2).value,
            equals(_TestObjectWithEquality('c', 3)));
        expect(result.updates.elementAt(3),
            isA<Insert<_TestObjectWithEquality>>());
        expect(result.updates.elementAt(3).value,
            equals(_TestObjectWithEquality('d', 4)));
      });
    });
  });
}

/// A test object that implements custom equality.
class _TestObjectWithEquality {
  final String name;
  final int value;

  _TestObjectWithEquality(this.name, this.value);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _TestObjectWithEquality &&
        other.name == name &&
        other.value == value;
  }

  @override
  int get hashCode => Object.hash(name, value);
}
