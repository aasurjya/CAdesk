import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/network/api_endpoints.dart';

void main() {
  group('ApiEndpoints', () {
    test('clients endpoint is correct', () {
      expect(ApiEndpoints.clients, '/rest/v1/clients');
    });

    test('itrFilings endpoint is correct', () {
      expect(ApiEndpoints.itrFilings, '/rest/v1/itr_filings');
    });

    test('gstClients endpoint is correct', () {
      expect(ApiEndpoints.gstClients, '/rest/v1/gst_clients');
    });

    test('gstReturns endpoint is correct', () {
      expect(ApiEndpoints.gstReturns, '/rest/v1/gst_returns');
    });

    test('tdsReturns endpoint is correct', () {
      expect(ApiEndpoints.tdsReturns, '/rest/v1/tds_returns');
    });

    test('invoices endpoint is correct', () {
      expect(ApiEndpoints.invoices, '/rest/v1/invoices');
    });

    test('tasks endpoint is correct', () {
      expect(ApiEndpoints.tasks, '/rest/v1/tasks');
    });

    test('documents endpoint is correct', () {
      expect(ApiEndpoints.documents, '/rest/v1/documents');
    });

    test('featureFlags endpoint is correct', () {
      expect(ApiEndpoints.featureFlags, '/rest/v1/feature_flags');
    });

    test('complianceDeadlines endpoint is correct', () {
      expect(ApiEndpoints.complianceDeadlines, '/rest/v1/compliance_deadlines');
    });

    test('all endpoints start with /rest/v1/', () {
      final allEndpoints = [
        ApiEndpoints.clients,
        ApiEndpoints.itrFilings,
        ApiEndpoints.gstClients,
        ApiEndpoints.gstReturns,
        ApiEndpoints.tdsReturns,
        ApiEndpoints.invoices,
        ApiEndpoints.tasks,
        ApiEndpoints.documents,
        ApiEndpoints.featureFlags,
        ApiEndpoints.complianceDeadlines,
      ];
      for (final ep in allEndpoints) {
        expect(
          ep,
          startsWith('/rest/v1/'),
          reason: '$ep should start with /rest/v1/',
        );
      }
    });
  });

  group('GstnEndpoints', () {
    test('gstinSearch endpoint is correct', () {
      expect(GstnEndpoints.gstinSearch, '/taxpayerapi/v2.0/search');
    });

    test('returnStatus endpoint is correct', () {
      expect(GstnEndpoints.returnStatus, '/returns/v2.0/returns/statu');
    });

    test('notices endpoint is correct', () {
      expect(GstnEndpoints.notices, '/notices/v1.0/notices');
    });
  });

  group('TracesEndpoints', () {
    test('login endpoint is correct', () {
      expect(TracesEndpoints.login, '/app/login');
    });

    test('loginCheck endpoint is correct', () {
      expect(TracesEndpoints.loginCheck, '/app/login/check');
    });

    test('form26asDownload endpoint is correct', () {
      expect(
        TracesEndpoints.form26asDownload,
        '/app/eStatement/26AS-Form-Download',
      );
    });

    test('aisDownload endpoint is correct', () {
      expect(TracesEndpoints.aisDownload, '/app/ais/downloadAIS');
    });

    test('form16Download endpoint is correct', () {
      expect(TracesEndpoints.form16Download, '/app/form16/download');
    });

    test('form16aDownload endpoint is correct', () {
      expect(TracesEndpoints.form16aDownload, '/app/form16A/download');
    });
  });

  group('McaEndpoints', () {
    test('companyMasterData endpoint is correct', () {
      expect(
        McaEndpoints.companyMasterData,
        '/MCA21/mds/efiling/getCompanyMasterDataForGovt',
      );
    });

    test('filingHistory endpoint is correct', () {
      expect(McaEndpoints.filingHistory, '/MCA21/mds/efiling/getFilingHistory');
    });

    test('dinMasterData endpoint is correct', () {
      expect(McaEndpoints.dinMasterData, '/MCA21/mds/efiling/getDINMasterData');
    });

    test('directorMasterData endpoint is correct', () {
      expect(
        McaEndpoints.directorMasterData,
        '/MCA21/mds/efiling/getDirectorMasterData',
      );
    });

    test('charges endpoint is correct', () {
      expect(McaEndpoints.charges, '/MCA21/mds/efiling/getCharges');
    });
  });
}
