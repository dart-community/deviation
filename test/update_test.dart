import 'package:deviation/deviation.dart';
import 'package:test/test.dart';

void main() {
  group('Keep', () {
    test('constructor initializes properties correctly', () {
      const value = 'test';
      const sourceIndex = 1;
      const targetIndex = 1;

      const keep = Keep(value, sourceIndex, targetIndex);

      expect(keep.value, equals(value));
      expect(keep.indexInSource, equals(sourceIndex));
      expect(keep.indexInTarget, equals(targetIndex));
    });

    test('toString returns value with leading space', () {
      const value = 'test';
      const keep = Keep(value, 0, 0);

      expect(keep.toString(), equals(' $value'));
    });

    test('works with non-String values', () {
      const value = 10;
      const keep = Keep(value, 0, 0);

      expect(keep.value, equals(value));
      expect(keep.toString(), equals(' $value'));
    });
  });

  group('Insert', () {
    test('constructor initializes properties correctly', () {
      const value = 'test';
      const sourceIndex = 1;
      const targetIndex = 2;

      const insert = Insert(value, sourceIndex, targetIndex);

      expect(insert.value, equals(value));
      expect(insert.indexInSource, equals(sourceIndex));
      expect(insert.indexInTarget, equals(targetIndex));
    });

    test('toString returns value with leading plus character', () {
      const value = 'test';
      const insert = Insert(value, 0, 0);

      expect(insert.toString(), equals('+$value'));
    });

    test('works with non-String values', () {
      const value = 10;
      const insert = Insert(value, 0, 0);

      expect(insert.value, equals(value));
      expect(insert.toString(), equals('+$value'));
    });
  });

  group('Remove', () {
    test('constructor initializes properties correctly', () {
      const value = 'test';
      const sourceIndex = 1;
      const targetIndex = 0;

      const remove = Remove(value, sourceIndex, targetIndex);

      expect(remove.value, equals(value));
      expect(remove.indexInSource, equals(sourceIndex));
      expect(remove.indexInTarget, equals(targetIndex));
    });

    test('toString returns value with leading minus symbol', () {
      const value = 'test';
      const remove = Remove(value, 0, 0);

      expect(remove.toString(), equals('-$value'));
    });

    test('works with non-String values', () {
      const value = 10;
      const remove = Remove(value, 0, 0);

      expect(remove.value, equals(value));
      expect(remove.toString(), equals('-$value'));
    });
  });
}
