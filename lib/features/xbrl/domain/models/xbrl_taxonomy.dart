import 'package:ca_app/features/xbrl/domain/models/xbrl_taxonomy_element.dart';

/// Immutable representation of the in-gaap XBRL taxonomy used for MCA filings.
///
/// Holds the element dictionary and label linkbase for the taxonomy version
/// (e.g. `in-gaap-2014-03-31`).
class XbrlTaxonomy {
  XbrlTaxonomy({
    required this.taxonomyName,
    required this.version,
    required this.elements,
    required this.labelLinkbase,
  });

  /// Taxonomy identifier, e.g. `in-gaap-2014-03-31`.
  final String taxonomyName;

  /// Version string matching the taxonomy release date.
  final String version;

  /// Map from local element name to its [XbrlTaxonomyElement] descriptor.
  final Map<String, XbrlTaxonomyElement> elements;

  /// Label linkbase: maps local element name to a human-readable label.
  final Map<String, String> labelLinkbase;

  /// Returns the [XbrlTaxonomyElement] for [localName], or null if not found.
  XbrlTaxonomyElement? lookupElement(String localName) => elements[localName];

  /// Returns the human-readable label for [localName], falling back to
  /// [localName] itself when no label is defined.
  String labelFor(String localName) => labelLinkbase[localName] ?? localName;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! XbrlTaxonomy) return false;
    if (other.taxonomyName != taxonomyName) return false;
    if (other.version != version) return false;
    if (other.elements.length != elements.length) return false;
    if (other.labelLinkbase.length != labelLinkbase.length) return false;
    for (final key in elements.keys) {
      if (other.elements[key] != elements[key]) return false;
    }
    for (final key in labelLinkbase.keys) {
      if (other.labelLinkbase[key] != labelLinkbase[key]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    taxonomyName,
    version,
    Object.hashAll(elements.entries.map((e) => Object.hash(e.key, e.value))),
    Object.hashAll(
      labelLinkbase.entries.map((e) => Object.hash(e.key, e.value)),
    ),
  );

  @override
  String toString() =>
      'XbrlTaxonomy($taxonomyName, ${elements.length} elements)';
}
