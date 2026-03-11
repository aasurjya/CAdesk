import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/constants/app_constants.dart';

void main() {
  group('AppConstants', () {
    group('app identity', () {
      test('appName is CADesk', () {
        expect(AppConstants.appName, 'CADesk');
      });

      test('appVersion is a non-empty string', () {
        expect(AppConstants.appVersion, isNotEmpty);
      });
    });

    group('breakpoints', () {
      test('phoneMaxWidth is 600', () {
        expect(AppConstants.phoneMaxWidth, 600.0);
      });

      test('tabletMaxWidth is 1200', () {
        expect(AppConstants.tabletMaxWidth, 1200.0);
      });

      test('phoneMaxWidth is less than tabletMaxWidth', () {
        expect(
          AppConstants.phoneMaxWidth,
          lessThan(AppConstants.tabletMaxWidth),
        );
      });

      test('breakpoints are positive', () {
        expect(AppConstants.phoneMaxWidth, isPositive);
        expect(AppConstants.tabletMaxWidth, isPositive);
      });
    });

    group('padding values', () {
      test('paddingXS is positive', () {
        expect(AppConstants.paddingXS, isPositive);
      });

      test('paddingSM is positive', () {
        expect(AppConstants.paddingSM, isPositive);
      });

      test('paddingMD is positive', () {
        expect(AppConstants.paddingMD, isPositive);
      });

      test('paddingLG is positive', () {
        expect(AppConstants.paddingLG, isPositive);
      });

      test('paddingXL is positive', () {
        expect(AppConstants.paddingXL, isPositive);
      });

      test('padding values are in ascending order', () {
        expect(AppConstants.paddingXS, lessThan(AppConstants.paddingSM));
        expect(AppConstants.paddingSM, lessThan(AppConstants.paddingMD));
        expect(AppConstants.paddingMD, lessThan(AppConstants.paddingLG));
        expect(AppConstants.paddingLG, lessThan(AppConstants.paddingXL));
      });

      test('paddingXS is 4', () {
        expect(AppConstants.paddingXS, 4.0);
      });

      test('paddingSM is 8', () {
        expect(AppConstants.paddingSM, 8.0);
      });

      test('paddingMD is 16', () {
        expect(AppConstants.paddingMD, 16.0);
      });

      test('paddingLG is 24', () {
        expect(AppConstants.paddingLG, 24.0);
      });

      test('paddingXL is 32', () {
        expect(AppConstants.paddingXL, 32.0);
      });
    });

    group('radius values', () {
      test('radiusSM is positive', () {
        expect(AppConstants.radiusSM, isPositive);
      });

      test('radiusMD is positive', () {
        expect(AppConstants.radiusMD, isPositive);
      });

      test('radiusLG is positive', () {
        expect(AppConstants.radiusLG, isPositive);
      });

      test('radiusXL is positive', () {
        expect(AppConstants.radiusXL, isPositive);
      });

      test('radius values are in ascending order', () {
        expect(AppConstants.radiusSM, lessThan(AppConstants.radiusMD));
        expect(AppConstants.radiusMD, lessThan(AppConstants.radiusLG));
        expect(AppConstants.radiusLG, lessThan(AppConstants.radiusXL));
      });

      test('radiusSM is 8', () {
        expect(AppConstants.radiusSM, 8.0);
      });

      test('radiusMD is 12', () {
        expect(AppConstants.radiusMD, 12.0);
      });

      test('radiusLG is 16', () {
        expect(AppConstants.radiusLG, 16.0);
      });

      test('radiusXL is 24', () {
        expect(AppConstants.radiusXL, 24.0);
      });
    });

    group('compliance constants', () {
      test('GST return day is 20', () {
        expect(AppConstants.gstReturnDay, 20);
      });

      test('TDS return quarters has 4 entries', () {
        expect(AppConstants.tdsReturnQuarters, hasLength(4));
      });

      test('ITR due date is July 31', () {
        expect(AppConstants.itrDueDate, 'July 31');
      });

      test('tax audit due date is September 30', () {
        expect(AppConstants.taxAuditDueDate, 'September 30');
      });
    });
  });
}
