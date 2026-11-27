import 'package:building_charge_fund/core/utils/currency_formatter.dart';
import 'package:building_charge_fund/core/utils/validators.dart';
import 'package:building_charge_fund/shared/enums/goal_status.dart';
import 'package:building_charge_fund/shared/models/goal.dart';
import 'package:flutter_test/flutter_test.dart';

Goal _goal(double target, double current) => Goal(id: '1', title: 't', targetAmount: target, currentAmount: current, status: GoalStatus.collecting, createdAt: DateTime(2026));

void main() {
  group('Goal progress (rule 6)', () {
    test('computes percentage', () => expect(_goal(1000, 250).progressPercent, 25));
    test('caps at 100', () => expect(_goal(1000, 5000).progressPercent, 100));
    test('zero target is 0', () => expect(_goal(0, 10).progressPercent, 0));
  });

  group('CurrencyFormatter', () {
    test('persian digits', () => expect(CurrencyFormatter.toPersianDigits('1234'), '۱۲۳۴'));
    test('english digits', () => expect(CurrencyFormatter.toEnglishDigits('۱۲۳۴'), '1234'));
    test('formats with separators', () => expect(CurrencyFormatter.formatAmount(1500000), '۱,۵۰۰,۰۰۰'));
    test('parses formatted input', () => expect(CurrencyFormatter.parseToInt('۱,۵۰۰,۰۰۰'), 1500000));
    test('parse empty is null', () => expect(CurrencyFormatter.parseToInt(''), isNull));
  });

  group('Validators', () {
    test('amount rejects zero/empty', () {
      expect(Validators.amount('0'), isNotNull);
      expect(Validators.amount(''), isNotNull);
      expect(Validators.amount('۵۰۰۰۰'), isNull);
    });
    test('phone', () {
      expect(Validators.phone('09123456789'), isNull);
      expect(Validators.phone('۰۹۱۲۳۴۵۶۷۸۹'), isNull);
      expect(Validators.phone('123'), isNotNull);
    });
    test('password min length', () {
      expect(Validators.password('12345'), isNotNull);
      expect(Validators.password('123456'), isNull);
    });
  });

  test('GoalStatus db mapping', () {
    expect(GoalStatus.fromDbValue('in_progress'), GoalStatus.inProgress);
    expect(GoalStatus.fromDbValue('bogus'), GoalStatus.collecting);
  });
}
