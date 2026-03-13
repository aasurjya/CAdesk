import 'package:ca_app/features/ca_gpt/domain/models/knowledge_article.dart';

/// Stateless service for searching and summarising Indian tax law sections.
///
/// Contains a built-in knowledge base of key Income Tax Act provisions.
/// All methods are static — no instantiation required.
class SectionLookupService {
  SectionLookupService._();

  // ---------------------------------------------------------------------------
  // Built-in section summaries (key Income Tax Act provisions)
  // ---------------------------------------------------------------------------

  static const Map<String, String> _sectionSummaries = {
    '44AD':
        'Presumptive taxation for businesses with turnover < ₹3 crore; 8%/6% deemed profit. '
        'Digital receipts qualify for the 6% rate.',
    '80C':
        'Deduction up to ₹1.5 lakh for specified investments (PPF, ELSS, LIC, NSC, home loan principal, etc.). '
        'Available under old tax regime only.',
    '194A':
        'TDS on interest other than on securities; 10% if PAN furnished, 20% otherwise. '
        'Threshold: ₹40,000 (banks), ₹5,000 (others).',
    '139(1)':
        'Mandatory due date for filing Income Tax Return: July 31 for individuals/HUFs '
        '(non-audit), October 31 for audit cases.',
    '54':
        'Capital gains exemption on sale of a residential house if a new house is purchased '
        'within 1 year before or 2 years after, or constructed within 3 years.',
    '10(14)':
        'Special allowances exempt from tax: HRA (subject to limits), LTA (twice in 4-year block), '
        'uniform allowance, children education allowance.',
    '115BAC':
        'New optional tax regime with concessional slab rates; no deductions allowed except '
        '80CCD(2) (NPS employer contribution) and a few others.',
    '43B(h)':
        'Payments to MSME suppliers must be made within 45 days (15 days if no agreement) '
        'to be allowable as deduction; unpaid amounts disallowed until actual payment.',
    '194Q':
        'TDS on purchase of goods exceeding ₹50 lakh in a year; buyer deducts 0.1% at source. '
        'Applies when buyer\'s turnover exceeds ₹10 crore.',
    '206AB':
        'Higher TDS/TCS (twice the applicable rate or 5%, whichever is higher) for specified '
        'persons who have not filed ITR for both preceding years and aggregate TDS > ₹50,000.',
  };

  // ---------------------------------------------------------------------------
  // Related sections map
  // ---------------------------------------------------------------------------

  static const Map<String, List<String>> _relatedSections = {
    '44AD': ['44ADA', '44AE', '44AA', '44AB', '139(1)'],
    '44ADA': ['44AD', '44AA', '44AB'],
    '80C': ['80CCC', '80CCD', '80D', '80E', '115BAC'],
    '194A': ['206AB', '206AA', '194'],
    '139(1)': ['139(4)', '139(5)', '139(9)', '44AB'],
    '54': ['54B', '54EC', '54F', '45'],
    '10(14)': ['10(13A)', '10(5)', '17(2)'],
    '115BAC': ['80C', '80D', '24(b)'],
    '43B(h)': ['43B', 'MSMED Act 2006'],
    '194Q': ['206C(1H)', '194C', '194H', '194I'],
    '206AB': ['206AA', '194', '206C(1H)'],
  };

  // ---------------------------------------------------------------------------
  // Knowledge base articles
  // ---------------------------------------------------------------------------

  static final List<KnowledgeArticle> _articles = [
    KnowledgeArticle(
      articleId: 'art_44ad',
      title: 'Section 44AD — Presumptive Taxation for Business',
      category: KnowledgeCategory.incomeTax,
      content: _sectionSummaries['44AD']!,
      sections: const ['44AD'],
      lastUpdated: DateTime(2024, 4, 1),
      isLatest: true,
      keywords: const [
        'presumptive',
        'taxation',
        'business',
        'turnover',
        'deemed profit',
        '44AD',
      ],
    ),
    KnowledgeArticle(
      articleId: 'art_44ada',
      title: 'Section 44ADA — Presumptive Taxation for Professionals',
      category: KnowledgeCategory.incomeTax,
      content:
          'Presumptive taxation for specified professionals (doctors, lawyers, CAs, etc.) '
          'with gross receipts < ₹75 lakh; 50% deemed profit.',
      sections: const ['44ADA'],
      lastUpdated: DateTime(2024, 4, 1),
      isLatest: true,
      keywords: const [
        'presumptive',
        'professional',
        'receipts',
        'deemed profit',
        '44ADA',
        'CA',
        'doctor',
        'lawyer',
      ],
    ),
    KnowledgeArticle(
      articleId: 'art_80c',
      title: 'Section 80C — Deductions for Specified Investments',
      category: KnowledgeCategory.incomeTax,
      content: _sectionSummaries['80C']!,
      sections: const ['80C'],
      lastUpdated: DateTime(2024, 4, 1),
      isLatest: true,
      keywords: const [
        '80C',
        'deduction',
        'PPF',
        'ELSS',
        'LIC',
        'NSC',
        'investment',
        'tax saving',
        '1.5 lakh',
      ],
    ),
    KnowledgeArticle(
      articleId: 'art_194a',
      title: 'Section 194A — TDS on Interest (Other than Securities)',
      category: KnowledgeCategory.tds,
      content: _sectionSummaries['194A']!,
      sections: const ['194A'],
      lastUpdated: DateTime(2024, 4, 1),
      isLatest: true,
      keywords: const [
        '194A',
        'TDS',
        'interest',
        'bank',
        'FD',
        'fixed deposit',
        'deduction at source',
      ],
    ),
    KnowledgeArticle(
      articleId: 'art_139_1',
      title: 'Section 139(1) — Due Date for Filing Income Tax Return',
      category: KnowledgeCategory.incomeTax,
      content: _sectionSummaries['139(1)']!,
      sections: const ['139(1)'],
      lastUpdated: DateTime(2024, 4, 1),
      isLatest: true,
      keywords: const [
        '139(1)',
        'ITR',
        'filing',
        'due date',
        'July 31',
        'return',
        'mandatory',
      ],
    ),
    KnowledgeArticle(
      articleId: 'art_54',
      title: 'Section 54 — Capital Gains Exemption on Residential Property',
      category: KnowledgeCategory.incomeTax,
      content: _sectionSummaries['54']!,
      sections: const ['54'],
      lastUpdated: DateTime(2024, 4, 1),
      isLatest: true,
      keywords: const [
        '54',
        'capital gains',
        'exemption',
        'residential',
        'house',
        'property',
        'long-term',
        'LTCG',
      ],
    ),
    KnowledgeArticle(
      articleId: 'art_10_14',
      title: 'Section 10(14) — Exempt Special Allowances',
      category: KnowledgeCategory.incomeTax,
      content: _sectionSummaries['10(14)']!,
      sections: const ['10(14)'],
      lastUpdated: DateTime(2024, 4, 1),
      isLatest: true,
      keywords: const [
        '10(14)',
        'HRA',
        'LTA',
        'allowance',
        'exempt',
        'uniform',
        'children education',
      ],
    ),
    KnowledgeArticle(
      articleId: 'art_115bac',
      title: 'Section 115BAC — New Tax Regime',
      category: KnowledgeCategory.incomeTax,
      content: _sectionSummaries['115BAC']!,
      sections: const ['115BAC'],
      lastUpdated: DateTime(2024, 4, 1),
      isLatest: true,
      keywords: const [
        '115BAC',
        'new regime',
        'concessional',
        'slab',
        'no deductions',
        'optional',
        '80CCD(2)',
      ],
    ),
    KnowledgeArticle(
      articleId: 'art_43bh',
      title: 'Section 43B(h) — MSME Payment Deduction',
      category: KnowledgeCategory.incomeTax,
      content: _sectionSummaries['43B(h)']!,
      sections: const ['43B(h)', '43B'],
      lastUpdated: DateTime(2024, 4, 1),
      isLatest: true,
      keywords: const [
        '43B(h)',
        'MSME',
        '45 days',
        'payment',
        'supplier',
        'disallowance',
        'deduction',
      ],
    ),
    KnowledgeArticle(
      articleId: 'art_194q',
      title: 'Section 194Q — TDS on Purchase of Goods',
      category: KnowledgeCategory.tds,
      content: _sectionSummaries['194Q']!,
      sections: const ['194Q'],
      lastUpdated: DateTime(2024, 4, 1),
      isLatest: true,
      keywords: const [
        '194Q',
        'TDS',
        'purchase',
        'goods',
        '50 lakh',
        '0.1%',
        'buyer',
        'deduction at source',
      ],
    ),
    KnowledgeArticle(
      articleId: 'art_206ab',
      title: 'Section 206AB — Higher TDS for Non-Filers',
      category: KnowledgeCategory.tds,
      content: _sectionSummaries['206AB']!,
      sections: const ['206AB'],
      lastUpdated: DateTime(2024, 4, 1),
      isLatest: true,
      keywords: const [
        '206AB',
        'higher TDS',
        'non-filer',
        'ITR',
        'specified person',
        'double rate',
        '5%',
      ],
    ),
  ];

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Searches for knowledge articles by section number, keyword, or description.
  ///
  /// Matching is case-insensitive. Multi-word queries match articles that contain
  /// ANY of the individual words. Returns an empty list if no match found.
  static List<KnowledgeArticle> lookupSection(String query) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return const [];

    // Split into individual terms so "TDS interest" matches articles with "TDS" OR "interest".
    final terms = q.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();

    return _articles.where((article) {
      for (final term in terms) {
        // Match on section numbers
        if (article.sections.any((s) => s.toLowerCase().contains(term))) {
          return true;
        }
        // Match on keywords
        if (article.keywords.any((k) => k.toLowerCase().contains(term))) {
          return true;
        }
        // Match on title/content
        if (article.title.toLowerCase().contains(term)) return true;
        if (article.content.toLowerCase().contains(term)) return true;
      }
      return false;
    }).toList();
  }

  /// Returns a plain-English summary for the given [sectionNumber] and [act].
  ///
  /// Falls back to a "not found" message for unknown sections.
  static String getSectionSummary(String sectionNumber, String act) {
    final summary = _sectionSummaries[sectionNumber.trim()];
    if (summary != null) return summary;

    // Attempt case-insensitive lookup
    final key = _sectionSummaries.keys.firstWhere(
      (k) => k.toLowerCase() == sectionNumber.toLowerCase().trim(),
      orElse: () => '',
    );
    if (key.isNotEmpty) return _sectionSummaries[key]!;

    return 'Section $sectionNumber of $act not found in knowledge base. '
        'Please consult the official text or a tax advisor.';
  }

  /// Returns a list of related section numbers for the given [sectionNumber].
  ///
  /// Returns an empty list if no relations are known.
  static List<String> getRelatedSections(String sectionNumber) {
    return List<String>.unmodifiable(
      _relatedSections[sectionNumber.trim()] ?? const <String>[],
    );
  }
}
