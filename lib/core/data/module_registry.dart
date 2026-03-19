import 'package:flutter/material.dart';

/// Immutable model representing a navigable module in CADesk.
///
/// Used by both the More screen grid/list and the global search overlay
/// so module data is defined once and shared everywhere.
class ModuleItem {
  const ModuleItem({
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

/// Canonical list of all 48 modules available in CADesk.
///
/// Categories: Quick Access, Core Filing, Practice Management,
/// Specialized Compliance, AI-First & Future-Ready, General.
const List<ModuleItem> allModules = [
  // ── Quick Access ──
  ModuleItem(
    icon: Icons.dashboard_outlined,
    title: 'Dashboard',
    subtitle: 'Overview & KPIs',
    category: 'Quick Access',
    route: '/dashboard',
  ),
  ModuleItem(
    icon: Icons.task_alt_outlined,
    title: 'Tasks',
    subtitle: 'Task management',
    category: 'Quick Access',
    route: '/tasks',
  ),
  ModuleItem(
    icon: Icons.verified_user_outlined,
    title: 'Compliance Calendar',
    subtitle: 'Statutory deadlines & calendar',
    category: 'Quick Access',
    route: '/compliance',
  ),

  // ── Core Filing Modules ──
  ModuleItem(
    icon: Icons.account_balance_outlined,
    title: 'Income Tax',
    subtitle: 'ITR filing & tracking',
    category: 'Core Filing',
    route: '/income-tax',
  ),
  ModuleItem(
    icon: Icons.receipt_outlined,
    title: 'GST',
    subtitle: 'Returns & compliance',
    category: 'Core Filing',
    route: '/gst',
  ),
  ModuleItem(
    icon: Icons.percent_outlined,
    title: 'TDS/TCS',
    subtitle: 'Deduction & collection',
    category: 'Core Filing',
    route: '/tds',
  ),
  ModuleItem(
    icon: Icons.auto_awesome_outlined,
    title: 'TDS.AI',
    subtitle: 'AI-assisted extraction, sectioning & return prep',
    category: 'Core Filing',
    route: '/roadmap/4',
  ),
  ModuleItem(
    icon: Icons.corporate_fare_outlined,
    title: 'MCA / ROC Compliance',
    subtitle: 'Company filings, Directors Act 2013',
    category: 'Core Filing',
    route: '/mca',
  ),
  ModuleItem(
    icon: Icons.qr_code_scanner_outlined,
    title: 'E-Invoicing',
    subtitle: 'IRP API, 30-day/3-day window & bulk generation',
    category: 'Core Filing',
    route: '/einvoicing',
  ),
  ModuleItem(
    icon: Icons.data_object_outlined,
    title: 'XBRL Filing',
    subtitle: 'XBRL tagging & MCA submission',
    category: 'Core Filing',
    route: '/xbrl',
  ),
  ModuleItem(
    icon: Icons.balance_outlined,
    title: 'Accounts & Balance Sheet',
    subtitle: 'Financials, P&L, depreciation',
    category: 'Core Filing',
    route: '/accounts',
  ),
  ModuleItem(
    icon: Icons.show_chart_outlined,
    title: 'CMA / Financial Projections',
    subtitle: 'CMA data, loan calc, EMI & DSCR',
    category: 'Core Filing',
    route: '/cma',
  ),
  ModuleItem(
    icon: Icons.people_outline,
    title: 'Payroll',
    subtitle: 'Salary, PF/ESI challans & TDS',
    category: 'Core Filing',
    route: '/payroll',
  ),
  ModuleItem(
    icon: Icons.policy_outlined,
    title: 'Assessment Orders',
    subtitle: 'Verify 143(1)/143(3), interest checks',
    category: 'Core Filing',
    route: '/assessment',
  ),

  // ── Practice Management ──
  ModuleItem(
    icon: Icons.folder_copy_outlined,
    title: 'Documents',
    subtitle: 'Client documents, cloud access & sharing',
    category: 'Practice Management',
    route: '/documents',
  ),
  ModuleItem(
    icon: Icons.cloud_outlined,
    title: 'Cloud & Remote Access',
    subtitle: 'Cloud app, backup health & remote controls',
    category: 'Practice Management',
    route: '/roadmap/13',
  ),
  ModuleItem(
    icon: Icons.receipt_long_outlined,
    title: 'Billing',
    subtitle: 'GST invoicing, payments & receivables',
    category: 'Practice Management',
    route: '/billing',
  ),
  ModuleItem(
    icon: Icons.language_outlined,
    title: 'Client Portal',
    subtitle: 'Messages, documents & queries',
    category: 'Practice Management',
    route: '/client-portal',
  ),
  ModuleItem(
    icon: Icons.smart_toy_outlined,
    title: 'AI & Automation',
    subtitle: 'OCR, reconciliation & anomalies',
    category: 'Practice Management',
    route: '/ai-automation',
  ),
  ModuleItem(
    icon: Icons.insights_outlined,
    title: 'Analytics',
    subtitle: 'KPIs, revenue & receivables',
    category: 'Practice Management',
    route: '/analytics',
  ),
  ModuleItem(
    icon: Icons.timer_outlined,
    title: 'Time Tracking',
    subtitle: 'Billable hours & billing',
    category: 'Practice Management',
    route: '/time-tracking',
  ),
  ModuleItem(
    icon: Icons.business_outlined,
    title: 'Firm Operations',
    subtitle: 'Staff, KPIs & knowledge base',
    category: 'Practice Management',
    route: '/firm-operations',
  ),
  ModuleItem(
    icon: Icons.person_add_outlined,
    title: 'Onboarding & KYC',
    subtitle: 'Client verification & checklists',
    category: 'Practice Management',
    route: '/onboarding',
  ),

  // ── Specialized Compliance ──
  ModuleItem(
    icon: Icons.currency_exchange_outlined,
    title: 'FEMA & RBI',
    subtitle: 'Foreign exchange compliance',
    category: 'Specialized Compliance',
    route: '/fema',
  ),
  ModuleItem(
    icon: Icons.trending_up_outlined,
    title: 'SEBI',
    subtitle: 'Capital market disclosures',
    category: 'Specialized Compliance',
    route: '/sebi',
  ),
  ModuleItem(
    icon: Icons.swap_horiz_outlined,
    title: 'Transfer Pricing',
    subtitle: 'TP studies & Form 3CEB',
    category: 'Specialized Compliance',
    route: '/transfer-pricing',
  ),
  ModuleItem(
    icon: Icons.currency_bitcoin_outlined,
    title: 'Crypto / VDA',
    subtitle: 'Virtual digital asset tax',
    category: 'Specialized Compliance',
    route: '/crypto-vda',
  ),
  ModuleItem(
    icon: Icons.rocket_launch_outlined,
    title: 'Startups',
    subtitle: 'DPIIT, 80-IAC & compliance',
    category: 'Specialized Compliance',
    route: '/startup-compliance',
  ),
  ModuleItem(
    icon: Icons.handshake_outlined,
    title: 'LLP Compliance',
    subtitle: 'Form 11, Form 8 & penalties',
    category: 'Specialized Compliance',
    route: '/llp-compliance',
  ),
  ModuleItem(
    icon: Icons.factory_outlined,
    title: 'MSME',
    subtitle: '45-day payments & 43B(h)',
    category: 'Specialized Compliance',
    route: '/msme',
  ),
  ModuleItem(
    icon: Icons.verified_user_outlined,
    title: 'Advanced Audits',
    subtitle: 'Statutory, internal & forensic',
    category: 'Specialized Compliance',
    route: '/advanced-audit',
  ),
  ModuleItem(
    icon: Icons.gavel_outlined,
    title: 'Faceless Assessment',
    subtitle: 'E-proceedings & ITR-U',
    category: 'Specialized Compliance',
    route: '/faceless-assessment',
  ),
  ModuleItem(
    icon: Icons.balance_outlined,
    title: 'Notice Resolution Center',
    subtitle: 'Notice triage, replies & appeals',
    category: 'Specialized Compliance',
    route: '/notice-resolution',
  ),
  ModuleItem(
    icon: Icons.key_outlined,
    title: 'DSC & Credential Vault',
    subtitle: 'DSC expiry, masked access & consent',
    category: 'Specialized Compliance',
    route: '/dsc-vault',
  ),
  ModuleItem(
    icon: Icons.event_repeat_outlined,
    title: 'Renewal & Expiry Control',
    subtitle: 'Renewals, retainers & SLA countdowns',
    category: 'Specialized Compliance',
    route: '/renewal-expiry',
  ),
  ModuleItem(
    icon: Icons.currency_rupee_outlined,
    title: 'Fee Leakage & Scope Control',
    subtitle: 'Scope creep, disputes & recovery',
    category: 'Specialized Compliance',
    route: '/fee-leakage',
  ),
  ModuleItem(
    icon: Icons.menu_book_outlined,
    title: 'Knowledge Engine',
    subtitle: 'Precedents, drafting memory & SOPs',
    category: 'Specialized Compliance',
    route: '/knowledge-engine',
  ),
  ModuleItem(
    icon: Icons.lightbulb_outline,
    title: 'Tax Advisory Opportunities',
    subtitle: 'Upsell signals, scoring & proposals',
    category: 'Specialized Compliance',
    route: '/tax-advisory',
  ),
  ModuleItem(
    icon: Icons.campaign_outlined,
    title: 'Lead Funnel & Campaigns',
    subtitle: 'Lead intake, campaigns & ROI',
    category: 'Specialized Compliance',
    route: '/lead-funnel',
  ),
  ModuleItem(
    icon: Icons.public_outlined,
    title: 'NRI & Cross-Border Tax Desk',
    subtitle: 'DTAA, FTC & foreign asset workflows',
    category: 'Specialized Compliance',
    route: '/nri-tax',
  ),
  ModuleItem(
    icon: Icons.business_center_outlined,
    title: 'SME Tax CFO Retainers',
    subtitle: 'Forecasting, board packs & advisory',
    category: 'Specialized Compliance',
    route: '/sme-cfo',
  ),
  ModuleItem(
    icon: Icons.domain_add_outlined,
    title: 'Industry Vertical Playbooks',
    subtitle: 'Sector playbooks & bundled services',
    category: 'Specialized Compliance',
    route: '/industry-playbooks',
  ),

  // ── AI-First & Future-Ready ──
  ModuleItem(
    icon: Icons.eco_outlined,
    title: 'ESG Reporting',
    subtitle: 'BRSR, carbon tax & SEBI sustainability',
    category: 'AI-First & Future-Ready',
    route: '/esg-reporting',
  ),
  ModuleItem(
    icon: Icons.account_balance_wallet_outlined,
    title: 'Virtual CFO Platform',
    subtitle: 'MIS dashboards, scenario planning & board packs',
    category: 'AI-First & Future-Ready',
    route: '/virtual-cfo',
  ),
  ModuleItem(
    icon: Icons.document_scanner_outlined,
    title: 'Intelligent Document Processing',
    subtitle: 'AI OCR for Form 16, 26AS & bank statements',
    category: 'AI-First & Future-Ready',
    route: '/idp',
  ),
  ModuleItem(
    icon: Icons.notifications_active_outlined,
    title: 'Regulatory Intelligence',
    subtitle: 'Daily circular digest & client-impact analysis',
    category: 'AI-First & Future-Ready',
    route: '/regulatory-intelligence',
  ),
  ModuleItem(
    icon: Icons.leaderboard_outlined,
    title: 'Practice Benchmarking',
    subtitle: 'Peer comparison, pricing & growth scoring',
    category: 'AI-First & Future-Ready',
    route: '/practice-benchmarking',
  ),

  // ── General ──
  ModuleItem(
    icon: Icons.monitor_heart_outlined,
    title: 'Staff Monitoring',
    subtitle: 'Activity logs, restrictions & alerts',
    category: 'General',
    route: '/staff-monitoring',
  ),
  ModuleItem(
    icon: Icons.settings_outlined,
    title: 'Settings',
    subtitle: 'App preferences and account',
    category: 'General',
    route: '/settings',
  ),
];
