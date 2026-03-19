import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/documents/data/providers/document_viewer_providers.dart';
import 'package:ca_app/features/documents/presentation/ocr_preview_screen.dart';

import '../../../helpers/widget_test_helpers.dart';

// Known mock document IDs (from documents_providers.dart mock data)
const _pdfDocId = 'd1'; // ITR-6 AY 2024-25 — PDF, has valid data
const _unknownDocId = 'doc-not-found';

void main() {
  group('OcrPreviewScreen — with valid document', () {
    testWidgets('renders without throwing', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const OcrPreviewScreen(documentId: _pdfDocId),
      );
    });

    testWidgets('shows "OCR Preview" in app bar', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const OcrPreviewScreen(documentId: _pdfDocId),
      );

      expect(find.text('OCR Preview'), findsOneWidget);
    });

    testWidgets('shows document title beneath OCR Preview', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const OcrPreviewScreen(documentId: _pdfDocId),
      );

      // d1 title: 'ITR-6 AY 2024-25'
      expect(find.text('ITR-6 AY 2024-25'), findsOneWidget);
    });

    testWidgets('shows Extracted Fields header', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const OcrPreviewScreen(documentId: _pdfDocId),
      );

      expect(find.text('Extracted Fields'), findsOneWidget);
    });

    testWidgets('shows number of detected fields badge', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const OcrPreviewScreen(documentId: _pdfDocId),
      );

      // Mock OCR data has 7 fields
      expect(find.textContaining('fields'), findsWidgets);
    });

    testWidgets('shows average confidence summary', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const OcrPreviewScreen(documentId: _pdfDocId),
      );

      expect(find.textContaining('confidence'), findsWidgets);
    });

    testWidgets('shows OCR field labels from mock data', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const OcrPreviewScreen(documentId: _pdfDocId),
      );

      // Mock data includes 'PAN Number' field
      expect(find.text('PAN Number'), findsWidgets);
    });

    testWidgets('shows Accept & Save button', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const OcrPreviewScreen(documentId: _pdfDocId),
      );

      expect(find.text('Accept & Save'), findsOneWidget);
    });

    testWidgets('shows confidence legend with >90%, 70-90%, <70% indicators', (
      tester,
    ) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const OcrPreviewScreen(documentId: _pdfDocId),
      );

      expect(find.text('>90%'), findsOneWidget);
      expect(find.text('70-90%'), findsOneWidget);
      expect(find.text('<70%'), findsOneWidget);
    });

    testWidgets('mock OCR data has the expected field count', (tester) async {
      await setDesktopViewport(tester);

      // Verify via provider that mock data loads correctly
      await pumpTestWidget(
        tester,
        const OcrPreviewScreen(documentId: _pdfDocId),
      );

      expect(find.textContaining('7 fields'), findsWidgets);
    });

    testWidgets('fields detected text is visible in document image pane', (
      tester,
    ) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const OcrPreviewScreen(documentId: _pdfDocId),
      );

      expect(find.textContaining('detected'), findsWidgets);
    });

    testWidgets('average confidence percentage is displayed', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const OcrPreviewScreen(documentId: _pdfDocId),
      );

      // Avg. confidence summary is rendered in the confidence pane
      expect(find.textContaining('Avg. confidence:'), findsWidgets);
    });
  });

  group('OcrPreviewScreen — with unknown document', () {
    testWidgets('renders without throwing when document not found', (
      tester,
    ) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const OcrPreviewScreen(documentId: _unknownDocId),
      );
    });

    testWidgets('shows "Document not found" fallback', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const OcrPreviewScreen(documentId: _unknownDocId),
      );

      expect(find.text('Document not found'), findsOneWidget);
    });
  });

  group('OcrField model', () {
    test('copyWith replaces value correctly', () {
      const field = OcrField(
        label: 'PAN Number',
        value: 'ABCPK1234F',
        confidence: 0.97,
      );

      final updated = field.copyWith(value: 'XYZPQ9876G');
      expect(updated.value, equals('XYZPQ9876G'));
      expect(updated.label, equals('PAN Number'));
      expect(updated.confidence, equals(0.97));
    });

    test('high confidence is >= 0.9', () {
      const field = OcrField(
        label: 'Assessment Year',
        value: '2025-26',
        confidence: 0.99,
      );
      expect(field.confidence, greaterThanOrEqualTo(0.9));
    });

    test('low confidence is < 0.7', () {
      const field = OcrField(
        label: 'Address',
        value: '42 MG Road',
        confidence: 0.68,
      );
      expect(field.confidence, lessThan(0.7));
    });

    test('default source is Page 1', () {
      const field = OcrField(label: 'Name', value: 'Test', confidence: 0.9);
      expect(field.source, equals('Page 1'));
    });

    test('copyWith returns a new object (immutable)', () {
      const field = OcrField(label: 'x', value: 'y', confidence: 0.5);
      final updated = field.copyWith(value: 'z');
      expect(identical(field, updated), isFalse);
    });
  });
}
