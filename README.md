# CADesk

**Complete practice management platform for Chartered Accountants (India)**

CADesk is a Flutter application targeting iPhone, iPad, macOS, and Web. It covers the full lifecycle of a CA firm — tax filings, compliance, client management, billing, AI automation, and firm operations — in a single adaptive app.

---

## Current Status

**Overall completion: ~58%**

- 51 modules, all with full UI shells, clean architecture, Riverpod state, and navigable flows
- **16 modules** now have deep, real business logic (see Key Business Logic section below)
- AI & Automation has a live investor-pitch simulation (OCR, reconciliation, anomaly detection) via "Live AI Demo" FAB
- Zero modules have real API integration or automated tests yet

---

## Platform & Architecture

| Concern | Choice |
|---|---|
| Platform | Flutter (Dart) — iOS, iPad, macOS, Web |
| Architecture | Clean Architecture (domain / data / presentation) |
| State Management | Riverpod (immutable state, `NotifierProvider`) |
| Navigation | GoRouter (declarative, shell routes) |
| UI System | Material 3, adaptive scaffold, Authoritative Navy brand palette |
| Local DB | Drift (SQLite) — planned |
| Cloud Sync | Supabase / Firebase — planned |

---

## Module Map (51 modules)

### Part A — Core Tax & Compliance
| # | Module | Route | Status |
|---|---|---|---|
| 1 | Income Tax | `/income-tax` | 55% — tax regime computation, advance tax schedule, filing form |
| 2 | GST | `/gst` | 55% — ITC reconciliation, late fee calculator, client detail sheet |
| 3 | TDS/TCS | `/tds` | 55% — challan tracking, section summaries, 234 interest calculator |
| 4 | TDS.AI | `/roadmap/4` | 0% — roadmap |
| 5 | MCA/ROC | `/mca` | 40% |
| 6 | XBRL Filing | `/xbrl` | 35% |
| 7 | Accounts & Balance Sheet | `/accounts` | 58% — 11 financial ratios, WDV depreciation, ratio benchmarks |
| 8 | CMA / Financial Projections | `/cma` | 58% — EMI/NPV/IRR/MPBF/DSCR calculators, amortization schedule |
| 9 | Payroll | `/payroll` | 60% — PF/ESI/PT/TDS computation, payslip detail, CTC breakdown |
| 10 | Assessment Orders | `/assessment` | 58% — 234A/B/C/244A interest, demand vs refund, intimation detail |

### Part B — Practice Management
| # | Module | Route | Status |
|---|---|---|---|
| 11 | Documents | `/documents` | 40% |
| 12 | Staff Monitoring | `/staff-monitoring` | 35% |
| 13 | Cloud & Remote Access | `/roadmap/13` | 0% — roadmap |
| 14 | Billing | `/billing` | 55% — GST calculator, payment tracking, aging summary |
| 15 | Practice Management / Tasks | `/tasks` | 50% |
| 16 | CRM / Clients | `/clients` | 58% — compliance health score, edit sheet, real quick actions |
| 17 | AI & Automation | `/ai-automation` | 44% — live demo simulation |
| 18 | Client Portal | `/client-portal` | 50% |
| 19 | Analytics / BI | `/analytics` | 38% |
| 20 | Time Tracking | `/time-tracking` | 62% — live timer, realization calculator, invoice from entries |
| 21 | Firm Operations | `/firm-operations` | 45% |
| 22 | Client Onboarding & KYC | `/onboarding` | 45% |

### Part C — Specialized Compliance
| # | Module | Route | Status |
|---|---|---|---|
| 23 | FEMA & RBI | `/fema` | 40% |
| 24 | SEBI | `/sebi` | 38% |
| 25 | Transfer Pricing | `/transfer-pricing` | 38% |
| 26 | Crypto / VDA Tax | `/crypto-vda` | 40% |
| 27 | Startup Compliance | `/startup-compliance` | 40% |
| 28 | LLP Compliance | `/llp-compliance` | 38% |
| 29 | MSME | `/msme` | 42% |
| 30 | Advanced Audits | `/advanced-audit` | 42% |
| 31 | Faceless Assessment | `/faceless-assessment` | 42% |
| 32 | Regulatory Trust & Security | `/regulatory-trust` | 40% |
| 33 | Data Pipelines & Broker | `/data-pipelines` | 40% |
| 34 | Collaboration & Mobility | `/collaboration` | 40% |
| 35 | Ecosystem Integrations | `/ecosystem` | 40% |

### Part D — Advisory & Growth (Modules 36–44)
| # | Module | Route | Status |
|---|---|---|---|
| 36 | Notice Resolution Center | `/notice-resolution` | 40% |
| 37 | DSC & Credential Vault | `/dsc-vault` | 40% |
| 38 | Renewal & Expiry Control | `/renewal-expiry` | 40% |
| 39 | Fee Leakage & Scope Control | `/fee-leakage` | 40% |
| 40 | Knowledge Engine | `/knowledge-engine` | 40% |
| 41 | Tax Advisory Opportunities | `/tax-advisory` | 40% |
| 42 | Lead Funnel & Campaigns | `/lead-funnel` | 40% |
| 43 | NRI & Cross-Border Tax | `/nri-tax` | 40% |
| 44 | SME CFO Retainers | `/sme-cfo` | 40% |

### Part E — Vertical & AI-First (Modules 45–51)
| # | Module | Route | Status |
|---|---|---|---|
| 45 | Industry Vertical Playbooks | `/industry-playbooks` | 40% |
| 46 | ESG Reporting | `/esg-reporting` | 40% |
| 47 | Virtual CFO Platform | `/virtual-cfo` | 40% |
| 48 | E-Invoicing Compliance Hub | `/einvoicing` | 40% |
| 49 | Intelligent Document Processing | `/idp` | 40% |
| 50 | Regulatory Intelligence | `/regulatory-intelligence` | 40% |
| 51 | Practice Benchmarking | `/practice-benchmarking` | 40% |

---

## Key Business Logic Implemented

### Tax Computation (Income Tax)
- New regime FY 2025-26 slabs: 0–4L nil, 4–8L 5%, 8–12L 10%, 12–16L 15%, 16–20L 20%, 20–24L 25%, >24L 30%
- Old regime with ₹3.75L assumed deductions (80C + 80D + HRA + standard)
- 4% health & education cess on both regimes
- Regime recommendation with savings callout
- Advance tax schedule (15 Jun 15%, 15 Sep 45%, 15 Dec 75%, 15 Mar 100%)

### GST Business Logic
- `LateFeesCalculator`: ₹50/day (nil returns ₹20/day), capped at ₹10,000/₹500
- 18% p.a. interest on late tax payment
- ITC reconciliation (GSTR-2A vs books): matched / mismatched / missing breakdown
- Compliance score ring per client

### TDS Logic
- `TdsInterestCalculator`: 1% p.m. late deduction, 1.5% p.m. late deposit
- Due date: 7th of next month (March → 30 April)
- Section-wise compliance tracking (192, 194A, 194C, 194H, 194J, 195, 194Q, 194N)

### GST Invoice Calculator (Billing)
- Intra-state: CGST + SGST (half each)
- Inter-state: full IGST
- Reverse-compute taxable from GST-inclusive amount
- 18% p.a. late payment interest
- Live preview as user types (rate chips: 5%, 12%, 18%, 28%)

### Dashboard Cross-Module KPIs
- `dashboardKpiProvider` aggregates: ITR pending count, GST returns pending, TDS challans due, total tax collected, upcoming deadline count
- Compliance deadline widget: 6 deadlines with days-remaining color coding
- Activity feed: 8 recent cross-module actions

### Payroll Computation
- Employee PF: 12% of basic salary, capped at ₹15,000 basic
- Employer PF: 12% of basic (capped), excluded from net pay
- Employee ESI: 0.75% of gross (only if gross ≤ ₹21,000)
- Employer ESI: 3.25% of gross (only if gross ≤ ₹21,000)
- Professional Tax: Maharashtra slabs — Nil / ₹175 / ₹200 (Feb: ₹300)
- TDS Section 192: New regime slabs with ₹75,000 standard deduction, 4% cess, amortized monthly
- `NetPayResult`: Gross → all deductions → Net Pay → CTC

### Financial Ratios (Accounts)
- **Liquidity**: Current Ratio, Quick Ratio
- **Profitability**: Gross Margin%, Net Margin%, EBITDA Margin%, ROE, ROA
- **Leverage**: Debt/Equity, Interest Coverage Ratio
- **Activity**: Debtor Days, Creditor Days, Inventory Days
- WDV depreciation: IT Act asset block rates, half-year convention (additions after Oct 3)
- All ratios color-coded against benchmarks (green/orange/red)

### Assessment Interest (Sections 234A/234B/234C)
- **234A**: 1% per month on net tax due for months late from ITR due date
- **234B**: 1% per month on advance tax shortfall (triggered if paid < 90% of assessed tax), Apr 1 to filing
- **234C**: 1% × 3 months on shortfall at each installment (15 Jun 15%, 15 Sep 45%, 15 Dec 75%)
- **244A**: 0.5% per month on refund amount (interest on excess payments)
- Detail sheet shows demand vs refund with full computation breakdown

### Client Compliance Health
- `ClientHealthScore` per client: ITR status, GST status, TDS status, pending actions list
- Grade: Healthy (≥80), Attention (60-79), Critical (<60)
- Score circle visualization, pending action chips
- Edit client form with Indian states dropdown, email/PAN validation

### Time Tracking (Live Timer)
- `ActiveTimerNotifier`: `Timer.periodic` backing, real-time HH:MM:SS, start/pause/resume/stop
- Live billable amount updating every second: `elapsedSeconds / 3600 * billingRate`
- `RealizationCalculator`: utilization %, effective hourly rate, realization ratio
- Invoice generation from time entries with GST rate selection

---

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run on macOS
flutter run -d macos

# Run on iOS simulator
flutter run -d ios

# Run tests
flutter test

# Analyze
flutter analyze
```

---

## Project Structure

```
lib/
  app.dart                    # App entry, theme, ProviderScope
  main.dart                   # main()
  core/
    constants/                # App-wide constants
    extensions/               # Dart extensions
    routing/                  # GoRouter configuration (app_router.dart)
    theme/                    # AppColors, AppTheme
    utils/                    # Shared utilities
    widgets/                  # AdaptiveScaffold, shared widgets
  features/
    <feature>/
      domain/models/          # Immutable data models
      data/providers/         # Riverpod providers + mock data
      presentation/
        <feature>_screen.dart # Main screen widget
        widgets/              # Feature-specific widgets
```

---

## Code Standards

- **Immutable models** — `const` constructors, `copyWith`, no mutation
- **Riverpod 3.x** — `NotifierProvider` for mutable state, `Provider` for derived state
- **No `dynamic` types** — strict Dart throughout
- **AppColors only** — no hardcoded hex values in widgets
- **`withAlpha(int)`** — not `withOpacity(double)` (deprecated)
- **File size** — 400 lines typical, 800 max
- **Curly braces** in all control flow

---

## Roadmap

1. **API Integration** — ITD portal, GSTN, TRACES, MCA21, RBI, SEBI APIs
2. **Authentication** — Supabase Auth with MFA
3. **Offline-first** — Drift SQLite with cloud sync
4. **Automated Tests** — unit + integration + E2E (80% coverage target)
5. **Real AI** — OCR engine, TDS.AI extraction, CA GPT
6. **E-filing** — ITR upload, GST filing, TRACES integration
7. **Production** — App Store, Play Store, macOS, Web deployment

---

*CADesk — Built for Indian CA firms. Targets iPhone, iPad, macOS, and Web.*
