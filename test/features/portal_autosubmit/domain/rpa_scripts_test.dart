import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/rpa_scripts.dart';
import 'package:ca_app/features/portal_autosubmit/domain/services/rpa_script_executor.dart';

void main() {
  group('RpaScripts', () {
    // -------------------------------------------------------------------------
    // tracesForm16Download
    // -------------------------------------------------------------------------

    group('tracesForm16Download', () {
      test('returns a non-null AutomationScript', () {
        expect(RpaScripts.tracesForm16Download, isNotNull);
      });

      test('has id "traces_form16_download"', () {
        expect(
          RpaScripts.tracesForm16Download.id,
          equals('traces_form16_download'),
        );
      });

      test('has a non-empty name', () {
        expect(RpaScripts.tracesForm16Download.name, isNotEmpty);
      });

      test('targets TRACES portal', () {
        expect(
          RpaScripts.tracesForm16Download.portal,
          equals(RpaPortal.traces),
        );
      });

      test('has at least 3 steps', () {
        expect(
          RpaScripts.tracesForm16Download.steps.length,
          greaterThanOrEqualTo(3),
        );
      });

      test('first step is a navigate action', () {
        expect(
          RpaScripts.tracesForm16Download.steps.first.action,
          equals(RpaAction.navigate),
        );
      });

      test('includes at least one download or click step', () {
        final script = RpaScripts.tracesForm16Download;
        final hasDownloadOrClick = script.steps.any(
          (s) => s.action == RpaAction.download || s.action == RpaAction.click,
        );
        expect(hasDownloadOrClick, isTrue);
      });

      test('includes screenshot step for audit trail', () {
        final hasScreenshot = RpaScripts.tracesForm16Download.steps.any(
          (s) => s.action == RpaAction.screenshot,
        );
        expect(hasScreenshot, isTrue);
      });

      test('every step has a non-empty description', () {
        for (final step in RpaScripts.tracesForm16Download.steps) {
          expect(step.description, isNotEmpty);
        }
      });
    });

    // -------------------------------------------------------------------------
    // gstFilingStatus
    // -------------------------------------------------------------------------

    group('gstFilingStatus', () {
      test('returns a non-null AutomationScript', () {
        expect(RpaScripts.gstFilingStatus, isNotNull);
      });

      test('has id "gstn_filing_status_check"', () {
        expect(
          RpaScripts.gstFilingStatus.id,
          equals('gstn_filing_status_check'),
        );
      });

      test('has a non-empty name', () {
        expect(RpaScripts.gstFilingStatus.name, isNotEmpty);
      });

      test('targets GSTN portal', () {
        expect(RpaScripts.gstFilingStatus.portal, equals(RpaPortal.gstn));
      });

      test('has at least 3 steps', () {
        expect(
          RpaScripts.gstFilingStatus.steps.length,
          greaterThanOrEqualTo(3),
        );
      });

      test('first step navigates to GSTN services URL', () {
        final first = RpaScripts.gstFilingStatus.steps.first;
        expect(first.action, equals(RpaAction.navigate));
        expect(first.value, contains('gst.gov.in'));
      });

      test('includes extract steps to retrieve filing status', () {
        final hasExtract = RpaScripts.gstFilingStatus.steps.any(
          (s) => s.action == RpaAction.extract,
        );
        expect(hasExtract, isTrue);
      });

      test('every step has a non-empty description', () {
        for (final step in RpaScripts.gstFilingStatus.steps) {
          expect(step.description, isNotEmpty);
        }
      });
    });

    // -------------------------------------------------------------------------
    // mcaPrefill
    // -------------------------------------------------------------------------

    group('mcaPrefill', () {
      test('returns a non-null AutomationScript', () {
        expect(RpaScripts.mcaPrefill, isNotNull);
      });

      test('has id "mca_company_prefill"', () {
        expect(RpaScripts.mcaPrefill.id, equals('mca_company_prefill'));
      });

      test('has a non-empty name', () {
        expect(RpaScripts.mcaPrefill.name, isNotEmpty);
      });

      test('targets MCA portal', () {
        expect(RpaScripts.mcaPrefill.portal, equals(RpaPortal.mca));
      });

      test('has at least 3 steps', () {
        expect(RpaScripts.mcaPrefill.steps.length, greaterThanOrEqualTo(3));
      });

      test('first step navigates to MCA portal URL', () {
        final first = RpaScripts.mcaPrefill.steps.first;
        expect(first.action, equals(RpaAction.navigate));
        expect(first.value, contains('mca.gov.in'));
      });

      test('includes fill step for CIN number', () {
        final hasCinFill = RpaScripts.mcaPrefill.steps.any(
          (s) =>
              s.action == RpaAction.fill &&
              (s.selector?.contains('cin') ?? false),
        );
        expect(hasCinFill, isTrue);
      });

      test('every step has a non-empty description', () {
        for (final step in RpaScripts.mcaPrefill.steps) {
          expect(step.description, isNotEmpty);
        }
      });
    });

    // -------------------------------------------------------------------------
    // epfoEcrUpload
    // -------------------------------------------------------------------------

    group('epfoEcrUpload', () {
      test('returns a non-null AutomationScript', () {
        expect(RpaScripts.epfoEcrUpload, isNotNull);
      });

      test('has id "epfo_ecr_upload"', () {
        expect(RpaScripts.epfoEcrUpload.id, equals('epfo_ecr_upload'));
      });

      test('has a non-empty name', () {
        expect(RpaScripts.epfoEcrUpload.name, isNotEmpty);
      });

      test('targets EPFO portal', () {
        expect(RpaScripts.epfoEcrUpload.portal, equals(RpaPortal.epfo));
      });

      test('has at least 3 steps', () {
        expect(RpaScripts.epfoEcrUpload.steps.length, greaterThanOrEqualTo(3));
      });

      test('first step navigates to EPFO portal URL', () {
        final first = RpaScripts.epfoEcrUpload.steps.first;
        expect(first.action, equals(RpaAction.navigate));
        expect(first.value, contains('epfindia.gov.in'));
      });

      test('includes upload step for ECR file', () {
        final hasUpload = RpaScripts.epfoEcrUpload.steps.any(
          (s) => s.action == RpaAction.upload,
        );
        expect(hasUpload, isTrue);
      });

      test('includes extract step to capture acknowledgement number', () {
        final hasExtract = RpaScripts.epfoEcrUpload.steps.any(
          (s) => s.action == RpaAction.extract,
        );
        expect(hasExtract, isTrue);
      });

      test('every step has a non-empty description', () {
        for (final step in RpaScripts.epfoEcrUpload.steps) {
          expect(step.description, isNotEmpty);
        }
      });
    });

    // -------------------------------------------------------------------------
    // Uniqueness across all scripts
    // -------------------------------------------------------------------------

    group('script uniqueness', () {
      test('all scripts have unique IDs', () {
        final ids = [
          RpaScripts.tracesForm16Download.id,
          RpaScripts.gstFilingStatus.id,
          RpaScripts.mcaPrefill.id,
          RpaScripts.epfoEcrUpload.id,
        ];

        final uniqueIds = ids.toSet();
        expect(uniqueIds.length, equals(ids.length));
      });

      test('all scripts have unique names', () {
        final names = [
          RpaScripts.tracesForm16Download.name,
          RpaScripts.gstFilingStatus.name,
          RpaScripts.mcaPrefill.name,
          RpaScripts.epfoEcrUpload.name,
        ];

        final uniqueNames = names.toSet();
        expect(uniqueNames.length, equals(names.length));
      });

      test('each script targets a different portal', () {
        final portals = [
          RpaScripts.tracesForm16Download.portal,
          RpaScripts.gstFilingStatus.portal,
          RpaScripts.mcaPrefill.portal,
          RpaScripts.epfoEcrUpload.portal,
        ];

        final uniquePortals = portals.toSet();
        expect(uniquePortals.length, equals(portals.length));
      });
    });

    // -------------------------------------------------------------------------
    // RpaPortal enum
    // -------------------------------------------------------------------------

    group('RpaPortal enum', () {
      test('has traces value with correct label', () {
        expect(RpaPortal.traces.label, equals('TRACES'));
      });

      test('has gstn value with correct label', () {
        expect(RpaPortal.gstn.label, equals('GSTN'));
      });

      test('has mca value with correct label', () {
        expect(RpaPortal.mca.label, equals('MCA'));
      });

      test('has epfo value with correct label', () {
        expect(RpaPortal.epfo.label, equals('EPFO'));
      });

      test('has itd value with correct label', () {
        expect(RpaPortal.itd.label, equals('ITD e-Filing'));
      });
    });

    // -------------------------------------------------------------------------
    // RpaAction enum
    // -------------------------------------------------------------------------

    group('RpaAction enum', () {
      test(
        'has navigate, fill, click, extract, upload, download, assert_, wait, screenshot',
        () {
          const actions = RpaAction.values;
          expect(actions, contains(RpaAction.navigate));
          expect(actions, contains(RpaAction.fill));
          expect(actions, contains(RpaAction.click));
          expect(actions, contains(RpaAction.extract));
          expect(actions, contains(RpaAction.upload));
          expect(actions, contains(RpaAction.download));
          expect(actions, contains(RpaAction.assert_));
          expect(actions, contains(RpaAction.wait));
          expect(actions, contains(RpaAction.screenshot));
        },
      );
    });
  });
}
