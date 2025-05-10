import 'package:deviation/deviation.dart';
import 'package:test/test.dart';

void main() {
  group('Patch', () {
    test('constructor initializes with updates correctly', () {
      final updates = [
        const Keep('test1', 0, 0),
        const Insert('test2', 0, 1),
        const Remove('test3', 1, 1),
      ];

      final patch = Patch(updates);

      expect(patch.updates, equals(updates));
    });

    test('updates getter returns an unmodifiable list', () {
      final updates = [
        const Keep('test1', 0, 0),
        const Insert('test2', 0, 1),
      ];

      final patch = Patch(updates);

      expect(
        () => (patch.updates as List<Update<String>>)
            .add(const Remove('test3', 1, 1)),
        throwsUnsupportedError,
      );
    });

    test('updates getter includes all specified updates', () {
      final updates = [
        const Keep('test1', 0, 0),
        const Insert('test2', 0, 1),
        const Remove('test3', 1, 1),
      ];

      final patch = Patch(updates);

      expect(patch.updates.length, equals(3));
      expect(patch.updates.elementAt(0), equals(updates[0]));
      expect(patch.updates.elementAt(1), equals(updates[1]));
      expect(patch.updates.elementAt(2), equals(updates[2]));
    });

    test('works with empty updates list', () {
      final patch = Patch<String>(const []);

      expect(patch.updates, isEmpty);
    });

    test('updates getter returns iterable with correct type', () {
      final stringPatch = Patch(const [Keep('test', 0, 0)]);
      final intPatch = Patch(const [Keep(10, 0, 0)]);

      expect(stringPatch.updates, isA<Iterable<Update<String>>>());
      expect(stringPatch.updates.first.value, isA<String>());
      expect(intPatch.updates, isA<Iterable<Update<int>>>());
      expect(intPatch.updates.first.value, isA<int>());
    });

    test('original updates list modifications do not affect patch', () {
      final updates = [
        const Keep('test1', 0, 0),
        const Insert('test2', 0, 1),
      ];

      final patch = Patch(updates);

      updates.add(const Remove('test3', 1, 1));

      // Updates to the original list shouldn't affect the patch's updates.
      expect(patch.updates.length, equals(2));
    });

    test('updates are preserved as the same type', () {
      final updates = [
        const Keep('keep1', 0, 0),
        const Keep('keep2', 1, 1),
        const Insert('insert1', 1, 2),
        const Remove('remove1', 2, 2),
      ];

      final patch = Patch(updates);

      final keeps = patch.updates.whereType<Keep<String>>();
      final inserts = patch.updates.whereType<Insert<String>>();
      final removes = patch.updates.whereType<Remove<String>>();

      expect(keeps.length, equals(2));
      expect(inserts.length, equals(1));
      expect(removes.length, equals(1));

      expect(keeps.first.value, equals('keep1'));
      expect(inserts.first.value, equals('insert1'));
      expect(removes.first.value, equals('remove1'));
    });
  });
}
