import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/documents/presentation/document_viewer_screen.dart';

import '../../../helpers/widget_test_helpers.dart';

// Known mock document IDs (from documents_providers.dart mock data)
const _pdfDocId = 'd1'; // ITR-6 AY 2024-25 — PDF
const _imageDocId = 'd7'; // Aadhaar & PAN Copy — image
const _excelDocId = 'd9'; // GSTR-3B Apr 2025 — excel
const _unknownDocId = 'doc-not-found';

void main() {
  group('DocumentViewerScreen — PDF document', () {
    testWidgets('renders without throwing', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const DocumentViewerScreen(documentId: _pdfDocId),
      );
    });

    testWidgets('shows document title in app bar', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const DocumentViewerScreen(documentId: _pdfDocId),
      );

      // d1 title: 'ITR-6 AY 2024-25'
      expect(find.text('ITR-6 AY 2024-25'), findsOneWidget);
    });

    testWidgets('shows client name under title', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const DocumentViewerScreen(documentId: _pdfDocId),
      );

      expect(find.text('ABC Infra Pvt Ltd'), findsWidgets);
    });

    testWidgets('shows Download icon button', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const DocumentViewerScreen(documentId: _pdfDocId),
      );

      expect(find.byIcon(Icons.download_rounded), findsOneWidget);
    });

    testWidgets('shows Share icon button', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const DocumentViewerScreen(documentId: _pdfDocId),
      );

      expect(find.byIcon(Icons.share_rounded), findsOneWidget);
    });

    testWidgets('shows PDF viewer placeholder for PDF files', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const DocumentViewerScreen(documentId: _pdfDocId),
      );

      expect(find.text('PDF Viewer'), findsOneWidget);
    });

    testWidgets('shows page navigation controls for PDF', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const DocumentViewerScreen(documentId: _pdfDocId),
      );

      // Bottom controls include page number display
      expect(find.textContaining('1 / 5'), findsOneWidget);
    });

    testWidgets('shows OCR Extract FAB', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const DocumentViewerScreen(documentId: _pdfDocId),
      );

      expect(find.byIcon(Icons.document_scanner_rounded), findsOneWidget);
    });

    testWidgets('shows document metadata section', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const DocumentViewerScreen(documentId: _pdfDocId),
      );

      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(find.text('Details'), findsOneWidget);
    });

    testWidgets('shows More options popup menu', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const DocumentViewerScreen(documentId: _pdfDocId),
      );

      expect(find.byIcon(Icons.more_vert_rounded), findsOneWidget);
    });
  });

  group('DocumentViewerScreen — image document', () {
    testWidgets('renders without throwing', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const DocumentViewerScreen(documentId: _imageDocId),
      );
    });

    testWidgets('shows image preview for image files', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const DocumentViewerScreen(documentId: _imageDocId),
      );

      expect(find.text('Image Preview'), findsOneWidget);
    });

    testWidgets('shows zoom controls for image', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const DocumentViewerScreen(documentId: _imageDocId),
      );

      expect(find.byIcon(Icons.zoom_in_rounded), findsWidgets);
      expect(find.byIcon(Icons.zoom_out_rounded), findsWidgets);
    });
  });

  group('DocumentViewerScreen — Excel document', () {
    testWidgets('renders office document placeholder for excel', (
      tester,
    ) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const DocumentViewerScreen(documentId: _excelDocId),
      );

      // d9 is GSTR-3B Apr 2025, excel
      expect(find.text('GSTR-3B Apr 2025'), findsWidgets);
    });

    testWidgets('shows Open in... button for Excel file', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const DocumentViewerScreen(documentId: _excelDocId),
      );

      expect(find.text('Open in...'), findsOneWidget);
    });
  });

  group('DocumentViewerScreen — unknown document', () {
    testWidgets('renders without throwing when document not found', (
      tester,
    ) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const DocumentViewerScreen(documentId: _unknownDocId),
      );
    });

    testWidgets('shows "Document not found" when document is missing', (
      tester,
    ) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const DocumentViewerScreen(documentId: _unknownDocId),
      );

      expect(find.text('Document not found'), findsOneWidget);
    });
  });
}
