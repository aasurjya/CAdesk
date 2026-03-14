import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/regulatory_trust/domain/models/security_control.dart';
import 'package:ca_app/features/regulatory_trust/domain/models/vapt_scan.dart';
import 'package:ca_app/features/regulatory_trust/data/repositories/mock_regulatory_trust_repository.dart';

void main() {
  group('MockRegulatoryTrustRepository', () {
    late MockRegulatoryTrustRepository repo;

    setUp(() {
      repo = MockRegulatoryTrustRepository();
    });

    // -------------------------------------------------------------------------
    // SecurityControl
    // -------------------------------------------------------------------------

    group('SecurityControls', () {
      test('getSecurityControls returns at least 3 seed items', () async {
        final controls = await repo.getSecurityControls();
        expect(controls.length, greaterThanOrEqualTo(3));
      });

      test('getSecurityControlById returns matching control', () async {
        final all = await repo.getSecurityControls();
        final first = all.first;
        final found = await repo.getSecurityControlById(first.id);
        expect(found?.id, first.id);
      });

      test('getSecurityControlById returns null for unknown id', () async {
        final found = await repo.getSecurityControlById('no-such-id');
        expect(found, isNull);
      });

      test('getSecurityControlsByCategory filters correctly', () async {
        final controls = await repo.getSecurityControlsByCategory(
          SecurityControlCategory.soc2,
        );
        expect(
          controls.every((c) => c.category == SecurityControlCategory.soc2),
          isTrue,
        );
      });

      test('getSecurityControlsByStatus filters correctly', () async {
        final controls = await repo.getSecurityControlsByStatus(
          SecurityControlStatus.compliant,
        );
        expect(
          controls.every((c) => c.status == SecurityControlStatus.compliant),
          isTrue,
        );
      });

      test('insertSecurityControl adds control and returns id', () async {
        final control = SecurityControl(
          id: 'control-new-001',
          title: 'New Security Control',
          category: SecurityControlCategory.iso27001,
          status: SecurityControlStatus.inReview,
          severity: ControlSeverity.medium,
          lastAssessmentDate: DateTime(2026, 1, 1),
          nextDueDate: DateTime(2027, 1, 1),
          owner: 'Security Team',
        );
        final id = await repo.insertSecurityControl(control);
        expect(id, control.id);

        final all = await repo.getSecurityControls();
        expect(all.any((c) => c.id == 'control-new-001'), isTrue);
      });

      test('updateSecurityControl updates existing control', () async {
        final all = await repo.getSecurityControls();
        final first = all.first;
        final updated = SecurityControl(
          id: first.id,
          title: first.title,
          category: first.category,
          status: SecurityControlStatus.compliant,
          severity: first.severity,
          lastAssessmentDate: first.lastAssessmentDate,
          nextDueDate: first.nextDueDate,
          owner: first.owner,
          notes: first.notes,
        );
        final success = await repo.updateSecurityControl(updated);
        expect(success, isTrue);

        final found = await repo.getSecurityControlById(first.id);
        expect(found?.status, SecurityControlStatus.compliant);
      });

      test('updateSecurityControl returns false for non-existent', () async {
        final ghost = SecurityControl(
          id: 'ghost-id',
          title: 'Ghost',
          category: SecurityControlCategory.vapt,
          status: SecurityControlStatus.scheduled,
          severity: ControlSeverity.low,
          lastAssessmentDate: DateTime(2026),
          nextDueDate: DateTime(2027),
        );
        final success = await repo.updateSecurityControl(ghost);
        expect(success, isFalse);
      });

      test('deleteSecurityControl removes control', () async {
        final all = await repo.getSecurityControls();
        final first = all.first;
        final success = await repo.deleteSecurityControl(first.id);
        expect(success, isTrue);

        final found = await repo.getSecurityControlById(first.id);
        expect(found, isNull);
      });

      test('deleteSecurityControl returns false for unknown id', () async {
        final success = await repo.deleteSecurityControl('no-such-id');
        expect(success, isFalse);
      });
    });

    // -------------------------------------------------------------------------
    // VaptScan
    // -------------------------------------------------------------------------

    group('VaptScans', () {
      test('getVaptScans returns at least 3 seed items', () async {
        final scans = await repo.getVaptScans();
        expect(scans.length, greaterThanOrEqualTo(3));
      });

      test('getVaptScanById returns matching scan', () async {
        final all = await repo.getVaptScans();
        final first = all.first;
        final found = await repo.getVaptScanById(first.id);
        expect(found?.id, first.id);
      });

      test('getVaptScanById returns null for unknown id', () async {
        final found = await repo.getVaptScanById('no-such-id');
        expect(found, isNull);
      });

      test('getVaptScansByStatus filters correctly', () async {
        final scans = await repo.getVaptScansByStatus(VaptScanStatus.completed);
        expect(
          scans.every((s) => s.status == VaptScanStatus.completed),
          isTrue,
        );
      });

      test('insertVaptScan adds scan and returns id', () async {
        final scan = VaptScan(
          id: 'scan-new-001',
          title: 'Q1 2026 VAPT Scan',
          scanDate: DateTime(2026, 1, 15),
          status: VaptScanStatus.completed,
          criticalFindings: 0,
          highFindings: 2,
          mediumFindings: 5,
          lowFindings: 10,
          vendor: 'SecureTest Labs',
          scope: 'Web Application',
        );
        final id = await repo.insertVaptScan(scan);
        expect(id, scan.id);
      });

      test('updateVaptScan updates existing scan', () async {
        final all = await repo.getVaptScans();
        final first = all.first;
        final updated = VaptScan(
          id: first.id,
          title: first.title,
          scanDate: first.scanDate,
          status: VaptScanStatus.completed,
          criticalFindings: 0,
          highFindings: first.highFindings,
          mediumFindings: first.mediumFindings,
          lowFindings: first.lowFindings,
          remediationDeadline: first.remediationDeadline,
          vendor: first.vendor,
          scope: first.scope,
        );
        final success = await repo.updateVaptScan(updated);
        expect(success, isTrue);
      });

      test('updateVaptScan returns false for non-existent', () async {
        final ghost = VaptScan(
          id: 'ghost-id',
          title: 'Ghost',
          scanDate: DateTime(2026),
          status: VaptScanStatus.scheduled,
          criticalFindings: 0,
          highFindings: 0,
          mediumFindings: 0,
          lowFindings: 0,
        );
        final success = await repo.updateVaptScan(ghost);
        expect(success, isFalse);
      });

      test('deleteVaptScan removes scan', () async {
        final all = await repo.getVaptScans();
        final first = all.first;
        final success = await repo.deleteVaptScan(first.id);
        expect(success, isTrue);
      });

      test('deleteVaptScan returns false for unknown id', () async {
        final success = await repo.deleteVaptScan('no-such-id');
        expect(success, isFalse);
      });
    });
  });
}
