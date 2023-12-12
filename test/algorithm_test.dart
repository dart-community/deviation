import 'package:deviation/deviation.dart';
import 'package:test/test.dart';

void main() {
  const algorithm = DiffAlgorithm.myers();

  test('empty lists', () {
    expect(
      algorithm.compute(<String>[], <String>[]).updates,
      isEmpty,
    );
  });

  test('equal lists', () {
    const sameList = ['Hello', 'Dash!'];
    expect(
      algorithm.compute(sameList, sameList).updates,
      everyElement(isA<Keep<String>>()),
    );
  });
}
