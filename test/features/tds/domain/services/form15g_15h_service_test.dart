import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/tds/domain/models/form15g.dart';
import 'package:ca_app/features/tds/domain/models/form15h.dart';
import 'package:ca_app/features/tds/domain/services/form15g_15h_service.dart';

void main() {
  group('Form15g15hService', () {
    final form15g = Form15G(
      formNumber: 'F15G/2025-26/001',
      pan: 'ABCDE1234F',
      declarantName: 'Ravi Kumar',
      assessmentYear: '2026-27',
      financialYear: '2025-26',
      dateSubmitted: DateTime(2025, 4, 10),
      estimatedTotalIncome: 200000.0,
      estimatedIncomeFromSection: 15000.0,
      aggregateDeclaredAmount: 15000.0,
      deductorTan: 'MUMA12345B',
      deductorName: 'ABC Bank',
      sectionCode: '194A',
    );

    final form15h = Form15H(
      formNumber: 'F15H/2025-26/001',
      pan: 'PQRST5678X',
      declarantName: 'Ramesh Sharma',
      dateOfBirth: DateTime(1958, 6, 15),
      assessmentYear: '2026-27',
      financialYear: '2025-26',
      dateSubmitted: DateTime(2025, 4, 5),
      estimatedTotalIncome: 280000.0,
      estimatedIncomeFromSection: 30000.0,
      aggregateDeclaredAmount: 30000.0,
      deductorTan: 'MUMA12345B',
      deductorName: 'ABC Bank',
      sectionCode: '194A',
    );

    group('registerForm15G', () {
      test('adds form 15G to register', () {
        final register = Form15g15hService.registerForm15G(
          register: const Form15g15hRegister(forms15g: [], forms15h: []),
          form: form15g,
        );
        expect(register.forms15g.length, 1);
        expect(register.forms15g.first, form15g);
      });

      test('does not mutate original register', () {
        const original = Form15g15hRegister(forms15g: [], forms15h: []);
        Form15g15hService.registerForm15G(register: original, form: form15g);
        expect(original.forms15g, isEmpty);
      });
    });

    group('registerForm15H', () {
      test('adds form 15H to register', () {
        final register = Form15g15hService.registerForm15H(
          register: const Form15g15hRegister(forms15g: [], forms15h: []),
          form: form15h,
        );
        expect(register.forms15h.length, 1);
        expect(register.forms15h.first, form15h);
      });
    });

    group('hasValidDeclaration', () {
      test('returns true when valid Form 15G is on record for PAN', () {
        final register = Form15g15hService.registerForm15G(
          register: const Form15g15hRegister(forms15g: [], forms15h: []),
          form: form15g,
        );
        final result = Form15g15hService.hasValidDeclaration(
          register: register,
          pan: 'ABCDE1234F',
          deductorTan: 'MUMA12345B',
          sectionCode: '194A',
          asOf: DateTime(2025, 12, 1),
        );
        expect(result, isTrue);
      });

      test('returns true when valid Form 15H is on record for PAN', () {
        final register = Form15g15hService.registerForm15H(
          register: const Form15g15hRegister(forms15g: [], forms15h: []),
          form: form15h,
        );
        final result = Form15g15hService.hasValidDeclaration(
          register: register,
          pan: 'PQRST5678X',
          deductorTan: 'MUMA12345B',
          sectionCode: '194A',
          asOf: DateTime(2025, 12, 1),
        );
        expect(result, isTrue);
      });

      test('returns false when no declaration for PAN', () {
        const register = Form15g15hRegister(forms15g: [], forms15h: []);
        final result = Form15g15hService.hasValidDeclaration(
          register: register,
          pan: 'ABCDE1234F',
          deductorTan: 'MUMA12345B',
          sectionCode: '194A',
          asOf: DateTime(2025, 12, 1),
        );
        expect(result, isFalse);
      });

      test('returns false when Form 15G is expired', () {
        final register = Form15g15hService.registerForm15G(
          register: const Form15g15hRegister(forms15g: [], forms15h: []),
          form: form15g,
        );
        // After financial year ends
        final result = Form15g15hService.hasValidDeclaration(
          register: register,
          pan: 'ABCDE1234F',
          deductorTan: 'MUMA12345B',
          sectionCode: '194A',
          asOf: DateTime(2026, 4, 1),
        );
        expect(result, isFalse);
      });

      test('returns false when section code does not match', () {
        final register = Form15g15hService.registerForm15G(
          register: const Form15g15hRegister(forms15g: [], forms15h: []),
          form: form15g,
        );
        final result = Form15g15hService.hasValidDeclaration(
          register: register,
          pan: 'ABCDE1234F',
          deductorTan: 'MUMA12345B',
          sectionCode: '194C', // different section
          asOf: DateTime(2025, 12, 1),
        );
        expect(result, isFalse);
      });

      test('returns false when deductor TAN does not match', () {
        final register = Form15g15hService.registerForm15G(
          register: const Form15g15hRegister(forms15g: [], forms15h: []),
          form: form15g,
        );
        final result = Form15g15hService.hasValidDeclaration(
          register: register,
          pan: 'ABCDE1234F',
          deductorTan: 'OTHR99999Z', // different TAN
          sectionCode: '194A',
          asOf: DateTime(2025, 12, 1),
        );
        expect(result, isFalse);
      });
    });

    group('Form15g15hRegister', () {
      test('totalAggregateDeclared returns sum of all declared amounts', () {
        final register = Form15g15hService.registerForm15G(
          register: Form15g15hService.registerForm15H(
            register: const Form15g15hRegister(forms15g: [], forms15h: []),
            form: form15h,
          ),
          form: form15g,
        );
        // 15G: 15000, 15H: 30000
        expect(register.totalAggregateDeclared, closeTo(45000.0, 0.01));
      });

      test('activeDeclarations filters by asOf date', () {
        final register = Form15g15hService.registerForm15G(
          register: const Form15g15hRegister(forms15g: [], forms15h: []),
          form: form15g,
        );
        final active = Form15g15hService.activeDeclarations(
          register: register,
          asOf: DateTime(2025, 9, 1),
        );
        expect(active.forms15g.length, 1);
      });

      test('activeDeclarations excludes expired forms', () {
        final register = Form15g15hService.registerForm15G(
          register: const Form15g15hRegister(forms15g: [], forms15h: []),
          form: form15g,
        );
        final active = Form15g15hService.activeDeclarations(
          register: register,
          asOf: DateTime(2026, 5, 1),
        );
        expect(active.forms15g, isEmpty);
      });
    });

    group('generateFormNumber', () {
      test('generates sequential form number for 15G', () {
        final num1 = Form15g15hService.generateFormNumber(
          formType: DeclarationFormType.form15G,
          financialYear: '2025-26',
          sequenceNumber: 1,
        );
        expect(num1, 'F15G/2025-26/001');
      });

      test('generates sequential form number for 15H', () {
        final num = Form15g15hService.generateFormNumber(
          formType: DeclarationFormType.form15H,
          financialYear: '2025-26',
          sequenceNumber: 42,
        );
        expect(num, 'F15H/2025-26/042');
      });
    });
  });
}
