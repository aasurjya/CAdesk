# CADesk

**Complete practice management platform for Chartered Accountants (India)**

CADesk is a Flutter application targeting iPhone, iPad, macOS, and Web. It covers the full lifecycle of a CA firm — tax filings, compliance, client management, billing, AI automation, and firm operations — in a single adaptive app.

---

## Current Status (as of 2026-03-15)

**Overall completion: ~75%**

| Metric | Value |
|---|---|
| Feature modules | **76** (all with domain + data + presentation layers) |
| Lib files (non-generated) | **1,622** (260,675 lines) |
| Test files | **318** (75,266 lines) |
| Tests passing | **5,784 / 5,784** (zero failures) |
| Code coverage | **29.9%** (target: 100%) |
| Lint issues | **0** |
| Drift tables | **39** |
| Drift DAOs | **38** |
| Supabase migrations | **18** (20 tables, RLS) |
| Repository impls | **76 / 76** (all feature-flag-gated) |
| Tested UI screens | **6** (dashboard, GST, TDS, billing, income_tax, clients) |
| UnimplementedError stubs | **10** (MCA API portal, RPA, CA GPT placeholders) |
| TODOs remaining | **27** (mostly portal HTTP wiring) |

### Layer Completion

| Layer | % | Detail |
|---|:---:|---|
| Domain (models, services, logic) | **100%** | All 76 modules — immutable models, Riverpod-ready, TDD |
| Data — Core infra | **100%** | Auth, network (Dio+interceptors), sync engine, feature flags, connectivity |
| Data — DB infrastructure | **100%** | Drift AppDatabase (schema v2, 39 tables, 38 DAOs), Supabase (18 migrations, 20 tables, RLS) |
| Data — Repositories | **100%** | All 76 modules wired (mock + real + feature-flag-gated) |
| Tests | **95%** | 5,784 passing; coverage at 29.9% — need more branch/edge-case tests |
| Presentation (UI) | **20%** | 6 modules with tested screens; 70+ modules have shell UI only |
| Portal integrations | **5%** | Domain + WebView engine built; HTTP calls still stubbed |

### What's Done
- Full domain layer: immutable models, business logic services, TDD-tested
- Full data infrastructure: Drift SQLite + Supabase cloud, sync engine, feature flags
- All 76 repositories wired with mock/real/feature-flag pattern
- Portal auto-submit engine: DSC vault, OTP relay, WebView automation
- 5,784 tests covering domain services, repositories, providers, core infra, and 5 UI screens
- UX improvement plan: competitive analysis of 8+ CA apps + 16-week roadmap

### What's Next
1. **UI screens** — Build production-quality screens for 70+ modules (currently shell UI)
2. **Test coverage** — Push from 29.9% to 100% (providers, screens, edge cases)
3. **Portal HTTP wiring** — Connect GSTN/TRACES/MCA/ITD/EPFO APIs
4. **Supabase deep wiring** — Real CRUD for remaining modules
5. **AI features** — OCR engine, CA GPT, reconciliation AI

---

## Platform & Architecture

| Concern | Choice |
|---|---|
| Platform | Flutter (Dart) — iOS, iPad, macOS, Web |
| Architecture | Clean Architecture (domain / data / presentation) |
| State Management | Riverpod (immutable state, `NotifierProvider`) |
| Navigation | GoRouter (declarative, shell routes, 60+ routes) |
| UI System | Material 3, adaptive scaffold (phone/tablet/desktop) |
| Local DB | Drift (SQLite) — 39 tables, 38 DAOs |
| Cloud Sync | Supabase — 18 migrations, 20 tables, RLS enabled |
| CI/Quality | 5,784 tests, flutter_lints, 100% coverage target |

---

## Module Map (76 modules)

### Part A — Core Tax & Compliance
| # | Module | Route | Domain | Data | UI | Tests | Overall |
|---|---|---|:---:|:---:|:---:|:---:|:---:|
| 1 | Income Tax | `/income-tax` | ✅ | ✅ | ✅ tested | ✅ | **90%** |
| 2 | GST | `/gst` | ✅ | ✅ | ✅ tested | ✅ | **90%** |
| 3 | TDS/TCS | `/tds` | ✅ | ✅ | ✅ tested | ✅ | **90%** |
| 4 | MCA/ROC | `/mca` | ✅ | ✅ | 🔶 shell | 🔶 | **70%** |
| 5 | XBRL Filing | `/xbrl` | ✅ | ✅ | 🔶 shell | ✅ | **75%** |
| 6 | Accounts & Balance Sheet | `/accounts` | ✅ | ✅ | 🔶 shell | ✅ | **75%** |
| 7 | CMA / Financial Projections | `/cma` | ✅ | ✅ | 🔶 shell | 🔶 | **70%** |
| 8 | Payroll | `/payroll` | ✅ | ✅ | 🔶 shell | 🔶 | **70%** |
| 9 | Assessment Orders | `/assessment` | ✅ | ✅ | 🔶 shell | 🔶 | **70%** |
| 10 | Filing Engine | `/filing` | ✅ | ✅ | 🔶 shell | ✅ | **75%** |

### Part B — Practice Management
| # | Module | Route | Domain | Data | UI | Tests | Overall |
|---|---|---|:---:|:---:|:---:|:---:|:---:|
| 11 | Clients / CRM | `/clients` | ✅ | ✅ | ✅ tested | ✅ | **90%** |
| 12 | Billing | `/billing` | ✅ | ✅ | ✅ tested | ✅ | **90%** |
| 13 | Dashboard | `/dashboard` | ✅ | ✅ | ✅ tested | ✅ | **90%** |
| 14 | Tasks | `/tasks` | ✅ | ✅ | 🔶 shell | ✅ | **75%** |
| 15 | Documents | `/documents` | ✅ | ✅ | 🔶 shell | 🔶 | **70%** |
| 16 | Staff Monitoring | `/staff-monitoring` | ✅ | ✅ | 🔶 shell | 🔶 | **65%** |
| 17 | Time Tracking | `/time-tracking` | ✅ | ✅ | 🔶 shell | 🔶 | **70%** |
| 18 | Firm Operations | `/firm-operations` | ✅ | ✅ | 🔶 shell | 🔶 | **65%** |
| 19 | Compliance | `/compliance` | ✅ | ✅ | 🔶 shell | ✅ | **75%** |
| 20 | AI & Automation | `/ai-automation` | ✅ | ✅ | 🔶 shell | 🔶 | **65%** |
| 21 | Client Portal | `/client-portal` | ✅ | ✅ | 🔶 shell | 🔶 | **65%** |
| 22 | Analytics / BI | `/analytics` | ✅ | ✅ | 🔶 shell | 🔶 | **65%** |
| 23 | Onboarding & KYC | `/onboarding` | ✅ | ✅ | 🔶 shell | 🔶 | **65%** |
| 24 | Practice Management | `/practice` | ✅ | ✅ | 🔶 shell | ✅ | **75%** |

### Part C — Specialized Compliance
| # | Module | Route | Domain | Data | UI | Tests | Overall |
|---|---|---|:---:|:---:|:---:|:---:|:---:|
| 25 | FEMA & RBI | `/fema` | ✅ | ✅ | 🔶 shell | ✅ | **75%** |
| 26 | SEBI | `/sebi` | ✅ | ✅ | 🔶 shell | 🔶 | **65%** |
| 27 | Transfer Pricing | `/transfer-pricing` | ✅ | ✅ | 🔶 shell | ✅ | **75%** |
| 28 | Crypto / VDA Tax | `/crypto-vda` | ✅ | ✅ | 🔶 shell | ✅ | **75%** |
| 29 | Startup Compliance | `/startup-compliance` | ✅ | ✅ | 🔶 shell | 🔶 | **65%** |
| 30 | LLP Compliance | `/llp-compliance` | ✅ | ✅ | 🔶 shell | 🔶 | **65%** |
| 31 | MSME | `/msme` | ✅ | ✅ | 🔶 shell | ✅ | **75%** |
| 32 | Advanced Audits | `/advanced-audit` | ✅ | ✅ | 🔶 shell | 🔶 | **65%** |
| 33 | Audit | `/audit` | ✅ | ✅ | 🔶 shell | 🔶 | **70%** |
| 34 | Faceless Assessment | `/faceless-assessment` | ✅ | ✅ | 🔶 shell | 🔶 | **65%** |
| 35 | Litigation | `/litigation` | ✅ | ✅ | 🔶 shell | 🔶 | **65%** |
| 36 | LLP | `/llp` | ✅ | ✅ | 🔶 shell | 🔶 | **65%** |
| 37 | E-Verification | `/e-verification` | ✅ | ✅ | 🔶 shell | 🔶 | **65%** |

### Part D — Portal & Export
| # | Module | Route | Domain | Data | UI | Tests | Overall |
|---|---|---|:---:|:---:|:---:|:---:|:---:|
| 38 | Portal Connector Hub | `/portal-connector` | ✅ | ✅ | 🔶 shell | 🔶 | **65%** |
| 39 | Portal Export (ITD XML) | `/portal-export` | ✅ | ✅ | ✅ | 🔶 | **75%** |
| 40 | Portal Parser (26AS/AIS) | `/portal-parser` | ✅ | ✅ | ✅ | 🔶 | **75%** |
| 41 | Portal Auto-Submit | `/portal-autosubmit` | ✅ | ✅ | 🔶 WebView | ✅ | **75%** |
| 42 | GSTN API | `/gstn-api` | ✅ | ✅ stub | 🔶 shell | 🔶 | **60%** |
| 43 | TRACES | `/traces` | ✅ | ✅ stub | 🔶 shell | 🔶 | **60%** |
| 44 | MCA API | `/mca-api` | ✅ | ✅ stub | 🔶 shell | 🔶 | **55%** |
| 45 | Reconciliation | `/reconciliation` | ✅ | ✅ | 🔶 shell | 🔶 | **65%** |
| 46 | Bulk Operations | `/bulk-operations` | ✅ | ✅ | 🔶 shell | 🔶 | **65%** |
| 47 | Post-Filing Tracker | `/post-filing` | ✅ | ✅ | 🔶 shell | 🔶 | **65%** |
| 48 | DSC Vault | `/dsc-vault` | ✅ | ✅ | 🔶 shell | 🔶 | **65%** |

### Part E — Advisory & Growth
| # | Module | Route | Domain | Data | UI | Tests | Overall |
|---|---|---|:---:|:---:|:---:|:---:|:---:|
| 49 | Notice Resolution | `/notice-resolution` | ✅ | ✅ | 🔶 shell | 🔶 | **65%** |
| 50 | Tax Advisory | `/tax-advisory` | ✅ | ✅ | 🔶 shell | 🔶 | **65%** |
| 51 | Lead Funnel | `/lead-funnel` | ✅ | ✅ | 🔶 shell | 🔶 | **65%** |
| 52 | NRI & Cross-Border Tax | `/nri-tax` | ✅ | ✅ | 🔶 shell | 🔶 | **65%** |
| 53 | SME CFO Retainers | `/sme-cfo` | ✅ | ✅ | 🔶 shell | 🔶 | **65%** |
| 54 | Fee Leakage | `/fee-leakage` | ✅ | ✅ | 🔶 shell | 🔶 | **65%** |
| 55 | Knowledge Engine | `/knowledge-engine` | ✅ | ✅ | 🔶 shell | 🔶 | **65%** |
| 56 | Renewal & Expiry | `/renewal-expiry` | ✅ | ✅ | 🔶 shell | 🔶 | **65%** |
| 57 | Regulatory Trust | `/regulatory-trust` | ✅ | ✅ | 🔶 shell | 🔶 | **65%** |

### Part F — Vertical & AI-First
| # | Module | Route | Domain | Data | UI | Tests | Overall |
|---|---|---|:---:|:---:|:---:|:---:|:---:|
| 58 | Industry Playbooks | `/industry-playbooks` | ✅ | ✅ | 🔶 shell | 🔶 | **65%** |
| 59 | ESG Reporting | `/esg-reporting` | ✅ | ✅ | 🔶 shell | 🔶 | **65%** |
| 60 | Virtual CFO | `/virtual-cfo` | ✅ | ✅ | 🔶 shell | 🔶 | **65%** |
| 61 | E-Invoicing Hub | `/einvoicing` | ✅ | ✅ | 🔶 shell | 🔶 | **65%** |
| 62 | IDP (Document Processing) | `/idp` | ✅ | ✅ | 🔶 shell | 🔶 | **65%** |
| 63 | OCR Engine | `/ocr` | ✅ | ✅ | 🔶 shell | 🔶 | **65%** |
| 64 | Regulatory Intelligence | `/regulatory-intelligence` | ✅ | ✅ | 🔶 shell | 🔶 | **65%** |
| 65 | Practice Benchmarking | `/practice-benchmarking` | ✅ | ✅ | 🔶 shell | 🔶 | **65%** |
| 66 | CA GPT | `/ca-gpt` | ✅ | ✅ stub | 🔶 shell | 🔶 | **55%** |
| 67 | RPA Bot Framework | `/rpa` | ✅ | ✅ stub | 🔶 shell | 🔶 | **55%** |
| 68 | Data Pipelines | `/data-pipelines` | ✅ | ✅ | 🔶 shell | 🔶 | **65%** |
| 69 | Collaboration | `/collaboration` | ✅ | ✅ | 🔶 shell | 🔶 | **65%** |
| 70 | Ecosystem | `/ecosystem` | ✅ | ✅ | 🔶 shell | 🔶 | **65%** |
| 71 | Platform Core | `/platform` | ✅ | ✅ | 🔶 shell | 🔶 | **65%** |
| 72 | Settings | `/settings` | ✅ | ✅ | 🔶 shell | 🔶 | **65%** |
| 73 | VDA | `/vda` | ✅ | ✅ | 🔶 shell | 🔶 | **65%** |
| 74 | Startup | `/startup` | ✅ | ✅ | 🔶 shell | 🔶 | **65%** |
| 75 | Today | `/today` | ✅ | ✅ | 🔶 shell | 🔶 | **65%** |
| 76 | More / Roadmap | `/more` | ✅ | ✅ | 🔶 shell | 🔶 | **65%** |

**Legend:** ✅ Done/Tested · 🔶 Partial/Shell · 🔲 Not started

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

## Build Phases & Roadmap

### Current Phase: Phase 2B — Presentation Layer Build

| Phase | Scope | Status | % |
|---|---|:---:|:---:|
| **Phase 1** — Core Engines | GST engine, TDS rate chart, Form 16/16A, filing services | ✅ Complete | **100%** |
| **Phase 2A** — Data Layer | All 76 repositories, Drift tables, Supabase, feature flags | ✅ Complete | **100%** |
| **Phase 2B** — Presentation Layer | Production UI screens for all 76 modules (6/76 done) | 🔶 **IN PROGRESS** | **8%** |
| **Phase 2C** — Test Coverage Push | Push coverage from 29.9% to 100% | 🔶 In progress | **30%** |
| **Phase 3** — Portal Integration | Wire GSTN/TRACES/MCA/ITD/EPFO HTTP APIs | 🔲 Pending | **5%** |
| **Phase 4** — AI & Advanced | Real OCR, CA GPT (RAG), RPA bots, analytics AI | 🔲 Pending | **0%** |
| **Phase 5** — Production | App Store, TestFlight, macOS notarization, Web deploy | 🔲 Pending | **0%** |

---

*CADesk — Built for Indian CA firms. Targets iPhone, iPad, macOS, and Web.*
