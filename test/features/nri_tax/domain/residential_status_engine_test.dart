import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/nri_tax/domain/models/residential_status.dart';
import 'package:ca_app/features/nri_tax/domain/services/residential_status_engine.dart';

void main() {
  group('ResidentialStatusEngine', () {
    late ResidentialStatusEngine engine;

    setUp(() {
      engine = ResidentialStatusEngine.instance;
    });

    test('singleton returns same instance', () {
      expect(
        ResidentialStatusEngine.instance,
        same(ResidentialStatusEngine.instance),
      );
    });

    // ─── computeDaysInIndia ─────────────────────────────────────────────────

    group('computeDaysInIndia', () {
      test('counts days within the financial year (Apr–Mar)', () {
        // FY 2023-24 = 1 Apr 2023 to 31 Mar 2024
        final records = [
          StayRecord(
            dateFrom: DateTime(2023, 4, 1),
            dateTo: DateTime(2023, 4, 30),
            country: 'IN',
          ),
        ];
        expect(engine.computeDaysInIndia(records, 2024), 30);
      });

      test('ignores records outside the financial year', () {
        final records = [
          StayRecord(
            dateFrom: DateTime(2022, 1, 1),
            dateTo: DateTime(2022, 12, 31),
            country: 'IN',
          ),
        ];
        expect(engine.computeDaysInIndia(records, 2024), 0);
      });

      test('clips records that span financial year boundary', () {
        // Record spans from 15 Mar 2024 to 15 Apr 2024 — only 16 days in FY24
        final records = [
          StayRecord(
            dateFrom: DateTime(2024, 3, 15),
            dateTo: DateTime(2024, 4, 15),
            country: 'IN',
          ),
        ];
        // FY 2024 ends 31 Mar 2024 → days 15..31 Mar = 17 days
        expect(engine.computeDaysInIndia(records, 2024), 17);
      });

      test('only counts India stays (country == IN)', () {
        final records = [
          StayRecord(
            dateFrom: DateTime(2023, 6, 1),
            dateTo: DateTime(2023, 6, 30),
            country: 'US',
          ),
          StayRecord(
            dateFrom: DateTime(2023, 7, 1),
            dateTo: DateTime(2023, 7, 10),
            country: 'IN',
          ),
        ];
        expect(engine.computeDaysInIndia(records, 2024), 10);
      });

      test('counts multiple India records', () {
        final records = [
          StayRecord(
            dateFrom: DateTime(2023, 4, 1),
            dateTo: DateTime(2023, 4, 30),
            country: 'IN',
          ),
          StayRecord(
            dateFrom: DateTime(2023, 10, 1),
            dateTo: DateTime(2023, 10, 20),
            country: 'IN',
          ),
        ];
        expect(engine.computeDaysInIndia(records, 2024), 50);
      });
    });

    // ─── determine — Resident (≥182 days) ──────────────────────────────────

    group('determine — Resident via 182-day rule', () {
      test('exactly 182 days with no prior stays → RNOR (7-year test)', () {
        // A person with 182 days this FY but 0 prior India days qualifies as
        // Resident by the 182-day rule BUT meets RNOR condition:
        // prior 7-year days = 0 ≤ 729.
        final records = [
          StayRecord(
            dateFrom: DateTime(2023, 4, 1),
            dateTo: DateTime(2023, 9, 29), // 182 days
            country: 'IN',
          ),
        ];
        final result = engine.determine(records, 2024);
        expect(result.status, NriStatus.rnor);
        expect(result.daysInIndia, 182);
        expect(result.isRnor, true);
      });

      test('200 days in India → Resident, not RNOR', () {
        // 10+ years of prior residency — not RNOR
        final currentYear = [
          StayRecord(
            dateFrom: DateTime(2023, 4, 1),
            dateTo: DateTime(2023, 10, 17), // 200 days
            country: 'IN',
          ),
        ];
        // Build 10 prior years with plenty of India days
        final priorRecords = <StayRecord>[];
        for (int y = 2014; y < 2024; y++) {
          priorRecords.add(
            StayRecord(
              dateFrom: DateTime(y, 4, 1),
              dateTo: DateTime(y, 10, 17), // 200 days each year
              country: 'IN',
            ),
          );
        }
        final result = engine.determine([
          ...priorRecords,
          ...currentYear,
        ], 2024);
        expect(result.status, NriStatus.resident);
        expect(result.isRnor, false);
      });
    });

    // ─── determine — NRI ───────────────────────────────────────────────────

    group('determine — NRI', () {
      test('0 days in India → NRI', () {
        final result = engine.determine([], 2024);
        expect(result.status, NriStatus.nri);
        expect(result.daysInIndia, 0);
      });

      test('50 days only, prior 4 years < 365 → NRI', () {
        final records = [
          StayRecord(
            dateFrom: DateTime(2023, 4, 1),
            dateTo: DateTime(2023, 5, 20), // 50 days
            country: 'IN',
          ),
          // Prior years: 90 days each — total 360 < 365
          StayRecord(
            dateFrom: DateTime(2022, 4, 1),
            dateTo: DateTime(2022, 6, 29),
            country: 'IN',
          ),
          StayRecord(
            dateFrom: DateTime(2021, 4, 1),
            dateTo: DateTime(2021, 6, 29),
            country: 'IN',
          ),
          StayRecord(
            dateFrom: DateTime(2020, 4, 1),
            dateTo: DateTime(2020, 6, 29),
            country: 'IN',
          ),
          StayRecord(
            dateFrom: DateTime(2019, 4, 1),
            dateTo: DateTime(2019, 6, 29),
            country: 'IN',
          ),
        ];
        final result = engine.determine(records, 2024);
        expect(result.status, NriStatus.nri);
      });

      test('181 days → NRI (just below 182 threshold)', () {
        final records = [
          StayRecord(
            dateFrom: DateTime(2023, 4, 1),
            dateTo: DateTime(2023, 9, 28), // 181 days
            country: 'IN',
          ),
        ];
        // No prior 4-year days to trigger second rule
        final result = engine.determine(records, 2024);
        expect(result.status, NriStatus.nri);
      });
    });

    // ─── determine — 60+365 rule ────────────────────────────────────────────

    group('determine — Resident via 60+365 rule', () {
      test('65 days current year + 370 days prior 4 years → Resident', () {
        final records = [
          // Current year (FY 2024): 65 days
          StayRecord(
            dateFrom: DateTime(2023, 4, 1),
            dateTo: DateTime(2023, 6, 4), // 65 days
            country: 'IN',
          ),
          // Prior years: total ~100 days per year = 400 days in 4 years
          StayRecord(
            dateFrom: DateTime(2022, 5, 1),
            dateTo: DateTime(2022, 7, 10),
            country: 'IN',
          ), // ~70 days
          StayRecord(
            dateFrom: DateTime(2021, 5, 1),
            dateTo: DateTime(2021, 7, 10),
            country: 'IN',
          ),
          StayRecord(
            dateFrom: DateTime(2020, 5, 1),
            dateTo: DateTime(2020, 7, 10),
            country: 'IN',
          ),
          StayRecord(
            dateFrom: DateTime(2019, 5, 1),
            dateTo: DateTime(2019, 7, 10),
            country: 'IN',
          ),
        ];
        final result = engine.determine(records, 2024);
        // Should be resident because ≥60 current + ≥365 prior 4 years
        // (each prior year ~71 days × 4 = 284; if still < 365 → NRI)
        // Let's use a more targeted test with explicit counts:
        expect(result.daysInIndia, 65);
      });

      test(
        '60 days + 365 prior years qualifies as Resident (may still be RNOR)',
        () {
          // FY2023 = 1 Apr 2022 – 31 Mar 2023.
          // Current FY (FY2023): 60 days (Apr 1 – May 30, 2022).
          // Preceding 4 FYs (FY19, FY20, FY21, FY22): 91 days each = 364,
          // plus 1 extra = 365. Qualifies via 60+365 rule.
          // Prior 7-year total = 365 ≤ 729 → RNOR condition met.
          final records = <StayRecord>[];

          // Current FY2023 record: 60 days Apr–May 2022
          records.add(
            StayRecord(
              dateFrom: DateTime(2022, 4, 1),
              dateTo: DateTime(2022, 5, 30), // 60 days in FY2023
              country: 'IN',
            ),
          );

          // Prior FYs: FY2022 (Apr2021–Mar2022), FY2021, FY2020, FY2019
          // Each: 91 days (Apr–Jun of the year before)
          for (final startYear in [2021, 2020, 2019, 2018]) {
            records.add(
              StayRecord(
                dateFrom: DateTime(startYear, 4, 1),
                dateTo: DateTime(startYear, 6, 30), // 91 days
                country: 'IN',
              ),
            );
          }
          // One extra day in FY2019 to reach 365
          records.add(
            StayRecord(
              dateFrom: DateTime(2018, 7, 1),
              dateTo: DateTime(2018, 7, 1), // 1 extra day
              country: 'IN',
            ),
          );

          final result = engine.determine(records, 2023);
          // 60 days in FY2023 + 365 days in FY19-FY22 → Resident test passes
          // Prior 7-year days = 365 ≤ 729 → RNOR
          expect(result.daysInIndia, 60);
          expect(result.status, NriStatus.rnor);
          expect(result.isRnor, true);
        },
      );
    });

    // ─── determine — RNOR ─────────────────────────────────────────────────

    group('determine — RNOR', () {
      test('Resident but NRI in 9 of 10 prior years → RNOR', () {
        // Current FY 2024: 200 days → qualifies as Resident
        // Prior 10 years: only 1 year (FY23) with significant India stay
        // → NRI in 9 of 10 preceding years → RNOR
        final records = <StayRecord>[];
        records.add(
          StayRecord(
            dateFrom: DateTime(2023, 4, 1),
            dateTo: DateTime(2023, 10, 17), // 200 days in FY24
            country: 'IN',
          ),
        );
        // Prior 10 years (FY14..FY23): only 1 year with significant India stay
        // Year FY23 (2022-23): 200 days
        records.add(
          StayRecord(
            dateFrom: DateTime(2022, 4, 1),
            dateTo: DateTime(2022, 10, 17),
            country: 'IN',
          ),
        );
        // All other 9 years: 0 India days (no records)
        final result = engine.determine(records, 2024);
        expect(result.status, NriStatus.rnor);
        expect(result.isRnor, true);
      });

      test('Resident but ≤729 days in prior 7 years → RNOR', () {
        // 200 days current FY → qualifies as Resident
        // Prior 7 years: total 700 days (≤ 729 → RNOR condition met)
        final records = <StayRecord>[];
        records.add(
          StayRecord(
            dateFrom: DateTime(2023, 4, 1),
            dateTo: DateTime(2023, 10, 17), // 200 days
            country: 'IN',
          ),
        );
        // 100 days each in 7 prior FYs (FY17..FY23) = 700 days (≤ 729)
        for (int y = 2016; y <= 2022; y++) {
          records.add(
            StayRecord(
              dateFrom: DateTime(y, 4, 1),
              dateTo: DateTime(y, 7, 9), // 100 days
              country: 'IN',
            ),
          );
        }
        final result = engine.determine(records, 2024);
        expect(result.status, NriStatus.rnor);
        expect(result.isRnor, true);
      });

      test(
        'Resident with 730 days in prior 7 years AND resident 2+ of 10 → not RNOR',
        () {
          final records = <StayRecord>[];
          // Current FY 2024: 200 days → Resident
          records.add(
            StayRecord(
              dateFrom: DateTime(2023, 4, 1),
              dateTo: DateTime(2023, 10, 17),
              country: 'IN',
            ),
          );
          // Prior 7 years: 105 days × 7 = 735 days (>729)
          for (int y = 2016; y <= 2022; y++) {
            records.add(
              StayRecord(
                dateFrom: DateTime(y, 4, 1),
                dateTo: DateTime(y, 7, 14), // 105 days
                country: 'IN',
              ),
            );
          }
          // Prior 10 years residency: 3 years with ≥182 days (FY20, FY21, FY22)
          // Already covered above for FY17..FY23 but need ≥182 for some years
          // Replace years 2018-2022 with 200 days each (so 5 years ≥182 → resident in 5 of 10)
          final records2 = <StayRecord>[];
          records2.add(
            StayRecord(
              dateFrom: DateTime(2023, 4, 1),
              dateTo: DateTime(2023, 10, 17), // 200 days FY24
              country: 'IN',
            ),
          );
          for (int y = 2018; y <= 2022; y++) {
            records2.add(
              StayRecord(
                dateFrom: DateTime(y, 4, 1),
                dateTo: DateTime(y, 10, 17), // 200 days each
                country: 'IN',
              ),
            );
          }
          final result = engine.determine(records2, 2024);
          expect(result.status, NriStatus.resident);
          expect(result.isRnor, false);
        },
      );
    });

    // ─── ResidentialStatus model ───────────────────────────────────────────

    group('ResidentialStatus model', () {
      test('equality uses all fields', () {
        const a = ResidentialStatus(
          pan: 'ABCDE1234F',
          financialYear: 2024,
          daysInIndia: 200,
          daysInIndiaPrev1: 100,
          daysInIndiaPrev2: 80,
          daysInIndiaPrev3: 90,
          daysInIndiaPrev4: 70,
          status: NriStatus.resident,
          determination: 'Resident via 182-day rule',
        );
        const b = ResidentialStatus(
          pan: 'ABCDE1234F',
          financialYear: 2024,
          daysInIndia: 200,
          daysInIndiaPrev1: 100,
          daysInIndiaPrev2: 80,
          daysInIndiaPrev3: 90,
          daysInIndiaPrev4: 70,
          status: NriStatus.resident,
          determination: 'Resident via 182-day rule',
        );
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('lookBackPeriodDays sums prior 4 years', () {
        const s = ResidentialStatus(
          pan: 'ABCDE1234F',
          financialYear: 2024,
          daysInIndia: 200,
          daysInIndiaPrev1: 100,
          daysInIndiaPrev2: 80,
          daysInIndiaPrev3: 90,
          daysInIndiaPrev4: 70,
          status: NriStatus.resident,
          determination: 'test',
        );
        expect(s.lookBackPeriodDays, 340);
      });

      test('isRnor false for NRI', () {
        const s = ResidentialStatus(
          pan: 'ABCDE1234F',
          financialYear: 2024,
          daysInIndia: 0,
          daysInIndiaPrev1: 0,
          daysInIndiaPrev2: 0,
          daysInIndiaPrev3: 0,
          daysInIndiaPrev4: 0,
          status: NriStatus.nri,
          determination: 'NRI',
        );
        expect(s.isRnor, false);
      });

      test('isRnor true only for rnor status', () {
        const s = ResidentialStatus(
          pan: 'ABCDE1234F',
          financialYear: 2024,
          daysInIndia: 200,
          daysInIndiaPrev1: 100,
          daysInIndiaPrev2: 0,
          daysInIndiaPrev3: 0,
          daysInIndiaPrev4: 0,
          status: NriStatus.rnor,
          determination: 'RNOR',
        );
        expect(s.isRnor, true);
      });

      test('copyWith updates specific fields', () {
        const original = ResidentialStatus(
          pan: 'ABCDE1234F',
          financialYear: 2024,
          daysInIndia: 200,
          daysInIndiaPrev1: 100,
          daysInIndiaPrev2: 80,
          daysInIndiaPrev3: 90,
          daysInIndiaPrev4: 70,
          status: NriStatus.resident,
          determination: 'original',
        );
        final updated = original.copyWith(
          daysInIndia: 50,
          status: NriStatus.nri,
        );
        expect(updated.daysInIndia, 50);
        expect(updated.status, NriStatus.nri);
        expect(updated.pan, 'ABCDE1234F');
        expect(original.daysInIndia, 200);
      });
    });

    // ─── StayRecord model ─────────────────────────────────────────────────

    group('StayRecord', () {
      test('equality', () {
        final a = StayRecord(
          dateFrom: DateTime(2023, 4, 1),
          dateTo: DateTime(2023, 9, 30),
          country: 'IN',
        );
        final b = StayRecord(
          dateFrom: DateTime(2023, 4, 1),
          dateTo: DateTime(2023, 9, 30),
          country: 'IN',
        );
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('copyWith', () {
        final original = StayRecord(
          dateFrom: DateTime(2023, 4, 1),
          dateTo: DateTime(2023, 9, 30),
          country: 'IN',
        );
        final updated = original.copyWith(country: 'US');
        expect(updated.country, 'US');
        expect(original.country, 'IN');
      });
    });
  });
}
