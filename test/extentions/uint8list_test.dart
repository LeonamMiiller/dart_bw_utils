import 'dart:typed_data';
import 'package:bw_utils/bw_utils.dart';
import 'package:test/test.dart';

main() {
  test('list to int', () {
    Uint8List list = Uint8List.fromList([127, 9, 0, 0]);
    expect(list.toInt32LE(), 2431);
  });
    test('int to list', () {
    int num = 16909060;
    expect(num.toUint32List(Endian.big), Uint32List.fromList([1, 2, 3, 4]));
  });
}
