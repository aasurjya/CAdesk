import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Category constants
// ---------------------------------------------------------------------------

const kCategoryQuickAccess = 'Quick Access';
const kCategoryCoreFiling = 'Core Filing';
const kCategoryModules = 'Modules';
const kCategoryModernPractice = 'Modern Practice';
const kCategorySpecializedCompliance = 'Specialized Compliance';
const kCategoryComplianceManagement = 'Compliance Management';
const kCategoryAiFutureReady = 'AI & Future-Ready';
const kCategoryGeneral = 'General';

/// Canonical ordering for section display.
const kCategoryOrder = <String>[
  kCategoryQuickAccess,
  kCategoryCoreFiling,
  kCategoryModules,
  kCategoryModernPractice,
  kCategorySpecializedCompliance,
  kCategoryComplianceManagement,
  kCategoryAiFutureReady,
  kCategoryGeneral,
];

// ---------------------------------------------------------------------------
// MenuItem — immutable data class
// ---------------------------------------------------------------------------

class MoreMenuItem {
  const MoreMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.category,
    this.route,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String category;
  final String? route;
}

// ---------------------------------------------------------------------------
// CategoryGroup — immutable grouping data class
// ---------------------------------------------------------------------------

class MoreCategoryGroup {
  const MoreCategoryGroup({required this.name, required this.items});

  final String name;
  final List<MoreMenuItem> items;
}

// ---------------------------------------------------------------------------
// All menu items
// ---------------------------------------------------------------------------

const kMoreMenuItems = <MoreMenuItem>[
  // Quick Access
  MoreMenuItem(
    icon: Icons.dashboard_outlined,
    title: 'Dashboard',
    subtitle: 'Overview & KPIs',
    route: '/',
    category: kCategoryQuickAccess,
  ),
  MoreMenuItem(
    icon: Icons.task_alt_outlined,
    title: 'Tasks',
    subtitle: 'Task management',
    route: '/tasks',
    category: kCategoryQuickAccess,
  ),
  MoreMenuItem(
    icon: Icons.verified_user_outlined,
    title: 'Compliance Calendar',
    subtitle: 'Statutory deadlines & calendar',
    route: '/compliance',
    category: kCategoryQuickAccess,
  ),
  // Core Filing
  MoreMenuItem(
    icon: Icons.account_balance_outlined,
    title: 'Income Tax',
    subtitle: 'ITR filing & tracking',
    route: '/income-tax',
    category: kCategoryCoreFiling,
  ),
  MoreMenuItem(
    icon: Icons.receipt_outlined,
    title: 'GST',
    subtitle: 'Returns & compliance',
    route: '/gst',
    category: kCategoryCoreFiling,
  ),
  MoreMenuItem(
    icon: Icons.percent_outlined,
    title: 'TDS/TCS',
    subtitle: 'Deduction & collection',
    route: '/tds',
    category: kCategoryCoreFiling,
  ),
  MoreMenuItem(
    icon: Icons.auto_awesome_outlined,
    title: 'TDS.AI',
    subtitle: 'AI-assisted extraction, sectioning & return prep',
    route: '/roadmap/4',
    category: kCategoryCoreFiling,
  ),
  MoreMenuItem(
    icon: Icons.corporate_fare_outlined,
    title: 'MCA / ROC Compliance',
    subtitle: 'Company filings, Directors Act 2013',
    route: '/mca',
    category: kCategoryCoreFiling,
  ),
  MoreMenuItem(
    icon: Icons.qr_code_scanner_outlined,
    title: 'E-Invoicing',
    subtitle: 'IRP API, 30-day/3-day window & bulk generation',
    route: '/einvoicing',
    category: kCategoryCoreFiling,
  ),
  // Modules
  MoreMenuItem(
    icon: Icons.data_object_outlined,
    title: 'XBRL Filing',
    subtitle: 'XBRL tagging & MCA submission',
    route: '/xbrl',
    category: kCategoryModules,
  ),
  MoreMenuItem(
    icon: Icons.balance_outlined,
    title: 'Accounts & Balance Sheet',
    subtitle: 'Financials, P&L, depreciation',
    route: '/accounts',
    category: kCategoryModules,
  ),
  MoreMenuItem(
    icon: Icons.show_chart_outlined,
    title: 'CMA / Financial Projections',
    subtitle: 'CMA data, loan calc, EMI & DSCR',
    route: '/cma',
    category: kCategoryModules,
  ),
  MoreMenuItem(
    icon: Icons.people_outline,
    title: 'Payroll',
    subtitle: 'Salary, PF/ESI challans & TDS',
    route: '/payroll',
    category: kCategoryModules,
  ),
  MoreMenuItem(
    icon: Icons.policy_outlined,
    title: 'Assessment Orders',
    subtitle: 'Verify 143(1)/143(3), interest checks',
    route: '/assessment',
    category: kCategoryModules,
  ),
  MoreMenuItem(
    icon: Icons.folder_copy_outlined,
    title: 'Documents',
    subtitle: 'Client documents, cloud access & sharing',
    route: '/documents',
    category: kCategoryModules,
  ),
  MoreMenuItem(
    icon: Icons.cloud_outlined,
    title: 'Cloud & Remote Access',
    subtitle: 'Cloud app, backup health & remote controls',
    route: '/roadmap/13',
    category: kCategoryModules,
  ),
  MoreMenuItem(
    icon: Icons.receipt_long_outlined,
    title: 'Billing',
    subtitle: 'GST invoicing, payments & receivables',
    route: '/billing',
    category: kCategoryModules,
  ),
  // Modern Practice
  MoreMenuItem(
    icon: Icons.language_outlined,
    title: 'Client Portal',
    subtitle: 'Messages, documents & queries',
    route: '/client-portal',
    category: kCategoryModernPractice,
  ),
  MoreMenuItem(
    icon: Icons.smart_toy_outlined,
    title: 'AI & Automation',
    subtitle: 'OCR, reconciliation & anomalies',
    route: '/ai-automation',
    category: kCategoryModernPractice,
  ),
  MoreMenuItem(
    icon: Icons.insights_outlined,
    title: 'Analytics',
    subtitle: 'KPIs, revenue & receivables',
    route: '/analytics',
    category: kCategoryModernPractice,
  ),
  MoreMenuItem(
    icon: Icons.timer_outlined,
    title: 'Time Tracking',
    subtitle: 'Billable hours & billing',
    route: '/time-tracking',
    category: kCategoryModernPractice,
  ),
  MoreMenuItem(
    icon: Icons.business_outlined,
    title: 'Firm Operations',
    subtitle: 'Staff, KPIs & knowledge base',
    route: '/firm-operations',
    category: kCategoryModernPractice,
  ),
  MoreMenuItem(
    icon: Icons.person_add_outlined,
    title: 'Onboarding & KYC',
    subtitle: 'Client verification & checklists',
    route: '/onboarding',
    category: kCategoryModernPractice,
  ),
  // Specialized Compliance
  MoreMenuItem(
    icon: Icons.currency_exchange_outlined,
    title: 'FEMA & RBI',
    subtitle: 'Foreign exchange compliance',
    route: '/fema',
    category: kCategorySpecializedCompliance,
  ),
  MoreMenuItem(
    icon: Icons.trending_up_outlined,
    title: 'SEBI',
    subtitle: 'Capital market disclosures',
    route: '/sebi',
    category: kCategorySpecializedCompliance,
  ),
  MoreMenuItem(
    icon: Icons.swap_horiz_outlined,
    title: 'Transfer Pricing',
    subtitle: 'TP studies & Form 3CEB',
    route: '/transfer-pricing',
    category: kCategorySpecializedCompliance,
  ),
  MoreMenuItem(
    icon: Icons.currency_bitcoin_outlined,
    title: 'Crypto / VDA',
    subtitle: 'Virtual digital asset tax',
    route: '/crypto-vda',
    category: kCategorySpecializedCompliance,
  ),
  MoreMenuItem(
    icon: Icons.rocket_launch_outlined,
    title: 'Startups',
    subtitle: 'DPIIT, 80-IAC & compliance',
    route: '/startup-compliance',
    category: kCategorySpecializedCompliance,
  ),
  MoreMenuItem(
    icon: Icons.handshake_outlined,
    title: 'LLP Compliance',
    subtitle: 'Form 11, Form 8 & penalties',
    route: '/llp-compliance',
    category: kCategorySpecializedCompliance,
  ),
  MoreMenuItem(
    icon: Icons.factory_outlined,
    title: 'MSME',
    subtitle: '45-day payments & 43B(h)',
    route: '/msme',
    category: kCategorySpecializedCompliance,
  ),
  // Compliance Management
  MoreMenuItem(
    icon: Icons.verified_user_outlined,
    title: 'Advanced Audits',
    subtitle: 'Statutory, internal & forensic',
    route: '/advanced-audit',
    category: kCategoryComplianceManagement,
  ),
  MoreMenuItem(
    icon: Icons.gavel_outlined,
    title: 'Faceless Assessment',
    subtitle: 'E-proceedings & ITR-U',
    route: '/faceless-assessment',
    category: kCategoryComplianceManagement,
  ),
  MoreMenuItem(
    icon: Icons.balance_outlined,
    title: 'Notice Resolution Center',
    subtitle: 'Notice triage, replies & appeals',
    route: '/notice-resolution',
    category: kCategoryComplianceManagement,
  ),
  MoreMenuItem(
    icon: Icons.key_outlined,
    title: 'DSC & Credential Vault',
    subtitle: 'DSC expiry, masked access & consent',
    route: '/dsc-vault',
    category: kCategoryComplianceManagement,
  ),
  MoreMenuItem(
    icon: Icons.event_repeat_outlined,
    title: 'Renewal & Expiry Control',
    subtitle: 'Renewals, retainers & SLA countdowns',
    route: '/renewal-expiry',
    category: kCategoryComplianceManagement,
  ),
  MoreMenuItem(
    icon: Icons.currency_rupee_outlined,
    title: 'Fee Leakage & Scope Control',
    subtitle: 'Scope creep, disputes & recovery',
    route: '/fee-leakage',
    category: kCategoryComplianceManagement,
  ),
  MoreMenuItem(
    icon: Icons.menu_book_outlined,
    title: 'Knowledge Engine',
    subtitle: 'Precedents, drafting memory & SOPs',
    route: '/knowledge-engine',
    category: kCategoryComplianceManagement,
  ),
  MoreMenuItem(
    icon: Icons.lightbulb_outline,
    title: 'Tax Advisory Opportunities',
    subtitle: 'Upsell signals, scoring & proposals',
    route: '/tax-advisory',
    category: kCategoryComplianceManagement,
  ),
  MoreMenuItem(
    icon: Icons.campaign_outlined,
    title: 'Lead Funnel & Campaigns',
    subtitle: 'Lead intake, campaigns & ROI',
    route: '/lead-funnel',
    category: kCategoryComplianceManagement,
  ),
  MoreMenuItem(
    icon: Icons.public_outlined,
    title: 'NRI & Cross-Border Tax Desk',
    subtitle: 'DTAA, FTC & foreign asset workflows',
    route: '/nri-tax',
    category: kCategoryComplianceManagement,
  ),
  MoreMenuItem(
    icon: Icons.business_center_outlined,
    title: 'SME Tax CFO Retainers',
    subtitle: 'Forecasting, board packs & advisory',
    route: '/sme-cfo',
    category: kCategoryComplianceManagement,
  ),
  MoreMenuItem(
    icon: Icons.domain_add_outlined,
    title: 'Industry Vertical Playbooks',
    subtitle: 'Sector playbooks & bundled services',
    route: '/industry-playbooks',
    category: kCategoryComplianceManagement,
  ),
  // AI & Future-Ready
  MoreMenuItem(
    icon: Icons.eco_outlined,
    title: 'ESG Reporting',
    subtitle: 'BRSR, carbon tax & SEBI sustainability',
    route: '/esg-reporting',
    category: kCategoryAiFutureReady,
  ),
  MoreMenuItem(
    icon: Icons.account_balance_wallet_outlined,
    title: 'Virtual CFO Platform',
    subtitle: 'MIS dashboards, scenario planning & board packs',
    route: '/virtual-cfo',
    category: kCategoryAiFutureReady,
  ),
  MoreMenuItem(
    icon: Icons.document_scanner_outlined,
    title: 'Intelligent Document Processing',
    subtitle: 'AI OCR for Form 16, 26AS & bank statements',
    route: '/idp',
    category: kCategoryAiFutureReady,
  ),
  MoreMenuItem(
    icon: Icons.notifications_active_outlined,
    title: 'Regulatory Intelligence',
    subtitle: 'Daily circular digest & client-impact analysis',
    route: '/regulatory-intelligence',
    category: kCategoryAiFutureReady,
  ),
  MoreMenuItem(
    icon: Icons.leaderboard_outlined,
    title: 'Practice Benchmarking',
    subtitle: 'Peer comparison, pricing & growth scoring',
    route: '/practice-benchmarking',
    category: kCategoryAiFutureReady,
  ),
  // General
  MoreMenuItem(
    icon: Icons.monitor_heart_outlined,
    title: 'Staff Monitoring',
    subtitle: 'Activity logs, restrictions & alerts',
    route: '/staff-monitoring',
    category: kCategoryGeneral,
  ),
  MoreMenuItem(
    icon: Icons.settings_outlined,
    title: 'Settings',
    subtitle: 'App preferences and account',
    route: '/settings',
    category: kCategoryGeneral,
  ),
];

// ---------------------------------------------------------------------------
// Helper: group items by category preserving canonical order
// ---------------------------------------------------------------------------

List<MoreCategoryGroup> groupMenuItemsByCategory(List<MoreMenuItem> items) {
  final map = <String, List<MoreMenuItem>>{};
  for (final item in items) {
    (map[item.category] ??= []).add(item);
  }
  return kCategoryOrder
      .where(map.containsKey)
      .map((cat) => MoreCategoryGroup(name: cat, items: map[cat]!))
      .toList();
}

/// Filter menu items by search query (matches title or subtitle).
List<MoreMenuItem> filterMenuItems(
  List<MoreMenuItem> items,
  String query,
) {
  if (query.isEmpty) return items;
  final lower = query.toLowerCase();
  return items
      .where(
        (item) =>
            item.title.toLowerCase().contains(lower) ||
            item.subtitle.toLowerCase().contains(lower),
      )
      .toList();
}
