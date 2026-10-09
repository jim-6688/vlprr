import 'package:flutter_test/flutter_test.dart';
import 'package:tail_limit/domain/value_objects/restriction_type.dart';
import 'package:tail_limit/domain/value_objects/tail_number.dart';

void main() {
  group('extractTailNumber', () {
    test('普通蓝牌取最后一位数字', () {
      expect(extractTailNumber('京A12345', TailDigitRule.lastDigit)?.value, 5);
      expect(extractTailNumber('川B8A239', TailDigitRule.lastDigit)?.value, 9);
    });

    test('末位为字母时按城市规则取前一位数字', () {
      // 北京规则：末位字母取前一位
      expect(
        extractTailNumber('京A1234A', TailDigitRule.digitBeforeTrailingLetter)
            ?.value,
        4,
      );
    });

    test('末位为字母按 0 处理的城市规则', () {
      expect(
        extractTailNumber('津A8888B', TailDigitRule.treatTrailingLetterAsZero)
            ?.value,
        0,
      );
    });

    test('lastDigit 规则遇字母牌回退到最近数字', () {
      expect(extractTailNumber('京A1234A', TailDigitRule.lastDigit)?.value, 4);
    });

    test('带分隔符的车牌可正常解析', () {
      expect(extractTailNumber('京A·12345', TailDigitRule.lastDigit)?.value, 5);
      expect(extractTailNumber(' 川A 9 8 7 6 5 ', TailDigitRule.lastDigit)?.value,
          5);
    });

    test('无效车牌返回 null', () {
      expect(extractTailNumber('A123', TailDigitRule.lastDigit), isNull);
    });
  });

  group('isNewEnergyPlate', () {
    test('小型新能源 D 开头序号', () {
      expect(isNewEnergyPlate('京AD12345'), isTrue);
    });

    test('小型新能源 F 开头序号', () {
      expect(isNewEnergyPlate('粤BF12345'), isTrue);
    });

    test('大型新能源末位 D/F', () {
      expect(isNewEnergyPlate('沪A12345D'), isTrue);
    });

    test('普通蓝牌 7 位不是新能源', () {
      expect(isNewEnergyPlate('京A12345'), isFalse);
    });
  });

  group('isLocalPlate', () {
    test('省份简称匹配判为本地牌', () {
      expect(isLocalPlate('京A12345', '京'), isTrue);
      expect(isLocalPlate('沪A12345', '京'), isFalse);
    });

    test('空省份简称无法判定', () {
      expect(isLocalPlate('京A12345', ''), isFalse);
    });
  });
}
