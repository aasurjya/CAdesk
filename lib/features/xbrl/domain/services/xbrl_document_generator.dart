import 'package:ca_app/features/xbrl/domain/models/xbrl_context.dart';
import 'package:ca_app/features/xbrl/domain/models/xbrl_document.dart';
import 'package:ca_app/features/xbrl/domain/models/xbrl_unit.dart';
import 'package:ca_app/features/xbrl/domain/services/xbrl_tag_mapping_service.dart';

/// Stateless singleton that assembles a complete [XbrlDocument] from a
/// [XbrlTagMappingInput] and serialises it to an XBRL instance document XML
/// string.
///
/// The generated XML targets the MCA in-gaap taxonomy and is suitable for
/// AOC-4 XBRL submissions to the MCA portal.
class XbrlDocumentGenerator {
  XbrlDocumentGenerator._();

  static final XbrlDocumentGenerator instance = XbrlDocumentGenerator._();

  // MCA taxonomy constants
  static const String _inGaapNamespace =
      'http://www.mca.gov.in/xbrl/taxonomy/in-gaap/2014-03-31';
  static const String _schemaRef =
      'https://www.mca.gov.in/xbrl/taxonomy/in-gaap-2014-03-31.xsd';
  static const String _mcaScheme = 'http://www.mca.gov.in';

  // ---------------------------------------------------------------------------
  // Date helpers
  // ---------------------------------------------------------------------------

  static String _formatDate(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}'
      '-${dt.month.toString().padLeft(2, '0')}'
      '-${dt.day.toString().padLeft(2, '0')}';

  // ---------------------------------------------------------------------------
  // generate
  // ---------------------------------------------------------------------------

  /// Assembles an [XbrlDocument] from [input].
  ///
  /// Two contexts are always created:
  /// - Instant context (`I-<year>`) for balance sheet dates.
  /// - Duration context (`D-<year>`) for the full reporting period.
  XbrlDocument generate(XbrlTagMappingInput input) {
    final endDate = _formatDate(input.reportingPeriodEnd);
    final startDate = _formatDate(input.reportingPeriodStart);
    final year = input.reportingPeriodEnd.year.toString();

    final instantContextId = 'I-$year';
    final durationContextId = 'D-$year';

    final contexts = [
      XbrlContext(
        contextId: instantContextId,
        entity: input.cin,
        scheme: _mcaScheme,
        periodType: XbrlPeriodType.instant,
        periodEnd: endDate,
      ),
      XbrlContext(
        contextId: durationContextId,
        entity: input.cin,
        scheme: _mcaScheme,
        periodType: XbrlPeriodType.duration,
        periodStart: startDate,
        periodEnd: endDate,
      ),
    ];

    const units = [XbrlUnit(unitId: 'INR', measure: 'iso4217:INR')];

    final mappingService = XbrlTagMappingService.instance;

    final bsFacts = mappingService.mapBalanceSheetToXbrl(
      input.balanceSheet,
      contextId: instantContextId,
    );
    final pnlFacts = mappingService.mapPnlToXbrl(
      input.pnl,
      contextId: durationContextId,
    );
    final cfFacts = mappingService.mapCashFlowToXbrl(
      input.cashFlow,
      contextId: durationContextId,
    );

    final facts = [...bsFacts, ...pnlFacts, ...cfFacts];

    return XbrlDocument(
      instanceDocumentId: input.instanceDocumentId,
      companyName: input.companyName,
      cin: input.cin,
      reportingPeriodStart: input.reportingPeriodStart,
      reportingPeriodEnd: input.reportingPeriodEnd,
      contexts: contexts,
      units: units,
      facts: facts,
      schemaRef: _schemaRef,
    );
  }

  // ---------------------------------------------------------------------------
  // generateXml
  // ---------------------------------------------------------------------------

  /// Serialises [doc] to a valid XBRL instance document XML string.
  ///
  /// The output conforms to XBRL 2.1 and references the MCA in-gaap taxonomy.
  /// Monetary facts carry `unitRef="INR"` and `decimals="0"`.
  String generateXml(XbrlDocument doc) {
    final buf = StringBuffer();

    // XML declaration
    buf.writeln('<?xml version="1.0" encoding="UTF-8"?>');

    // Root element with namespace declarations
    buf.writeln(
      '<xbrl xmlns="http://www.xbrl.org/2003/instance"'
      '\n  xmlns:xbrli="http://www.xbrl.org/2003/instance"'
      '\n  xmlns:link="http://www.xbrl.org/2003/linkbase"'
      '\n  xmlns:xlink="http://www.w3.org/1999/xlink"'
      '\n  xmlns:iso4217="http://www.xbrl.org/2003/iso4217"'
      '\n  xmlns:in-gaap="$_inGaapNamespace">',
    );

    // schemaRef
    buf.writeln(
      '  <schemaRef'
      ' xlink:type="simple"'
      ' xlink:href="${doc.schemaRef}"/>',
    );

    // Contexts
    for (final ctx in doc.contexts) {
      buf.writeln('  <context id="${ctx.contextId}">');
      buf.writeln('    <entity>');
      buf.writeln(
        '      <identifier scheme="${ctx.scheme}">${ctx.entity}</identifier>',
      );
      buf.writeln('    </entity>');
      buf.writeln('    <period>');
      if (ctx.periodType == XbrlPeriodType.instant) {
        buf.writeln('      <instant>${ctx.periodEnd}</instant>');
      } else {
        buf.writeln('      <startDate>${ctx.periodStart}</startDate>');
        buf.writeln('      <endDate>${ctx.periodEnd}</endDate>');
      }
      buf.writeln('    </period>');
      buf.writeln('  </context>');
    }

    // Units
    for (final unit in doc.units) {
      buf.writeln('  <unit id="${unit.unitId}">');
      buf.writeln('    <measure>${unit.measure}</measure>');
      buf.writeln('  </unit>');
    }

    // Facts
    for (final fact in doc.facts) {
      final unitAttr =
          fact.unitRef != null ? ' unitRef="${fact.unitRef}"' : '';
      buf.writeln(
        '  <${fact.elementName}'
        ' contextRef="${fact.contextRef}"'
        '$unitAttr'
        ' decimals="${fact.decimals}">'
        '${fact.value}'
        '</${fact.elementName}>',
      );
    }

    buf.write('</xbrl>');
    return buf.toString();
  }
}
