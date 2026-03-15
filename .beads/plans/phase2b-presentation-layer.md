---
title: "Phase 2B: Presentation Layer Build"
status: in-progress
created: 2026-03-15
scope: "Production UI screens for 19 modules across 3 batches"
---

# Phase 2B: Presentation Layer Build

## Objective
Build production-quality Flutter screens with widget tests for all priority modules. Domain models, services, providers, and repositories already exist — this phase wires up the UI.

## Already Complete (6 modules)
- ✅ Dashboard — KPI cards, deadline widget, activity feed (26 widget tests)
- ✅ GST — Returns list, filing wizard, ITC reconciliation (24 widget tests)
- ✅ TDS — Returns list, Form 16 generation, rate lookup (18 widget tests)
- ✅ Billing — Invoice list, filters, payment tracking (20 widget tests)
- ✅ Income Tax — ITR list, tax computation comparison (21 widget tests)
- ✅ Clients — List/detail, compliance health, edit form (existing)

## Batch 1: Core Tax & Finance (6 modules)

| # | Module | Key Screens | Domain Models Available |
|---|--------|-------------|----------------------|
| 1 | Accounts & Balance Sheet | Trial balance, P&L, balance sheet, ratio dashboard, depreciation schedule | FinancialStatement, BalanceSheet, FinancialRatio, DepreciationEntry |
| 2 | Payroll | Employee list, payslip detail, PF/ESI/PT summary, CTC breakdown | PayrollEntry, PayslipTemplate, NetPayResult |
| 3 | Assessment Orders | Assessment list, 234A/B/C interest calculator, demand vs refund detail | AssessmentOrder, InterestCalculation |
| 4 | CMA / Financial Projections | CMA form, EMI/NPV/IRR calculators, projection charts | CmaProjection, LoanAmortization |
| 5 | MCA/ROC | Filing list, e-Form wizard, compliance calendar | MCAFiling, MCAFormType |
| 6 | XBRL Filing | Tag mapping, validation screen, filing status | XbrlDocument, XbrlTagMapping |

**Per module deliverables:**
- Main list/dashboard screen
- Detail/form screen
- Feature-specific widgets (extracted into widgets/)
- Widget tests (15-25 tests per module)
- Adaptive layout (phone/tablet/desktop)

## Batch 2: Practice Management (6 modules)

| # | Module | Key Screens | Domain Models Available |
|---|--------|-------------|----------------------|
| 1 | Tasks | Task board (Kanban), task detail, assignment, filters | Task, TaskStatus, TaskPriority |
| 2 | Documents | Document list, upload flow, OCR status, linked returns | DocumentMetadata, DocumentType |
| 3 | Staff Monitoring | Staff list, workload chart, performance metrics | StaffMember, WorkloadMetric |
| 4 | Time Tracking | Timer screen, entry list, realization report, invoice from entries | TimeEntry, ActiveTimer, RealizationResult |
| 5 | Firm Operations | Firm profile, team management, client assignments | FirmInfo, TeamMember, ClientAssignment |
| 6 | Compliance | Compliance calendar, deadline list, filing status by client | ComplianceDeadline, ComplianceStatus |

## Batch 3: Specialized Compliance (7 modules)

| # | Module | Key Screens | Domain Models Available |
|---|--------|-------------|----------------------|
| 1 | FEMA & RBI | Transaction list, FC-GPR form, compliance checklist | FemaTransaction, FcGprReport |
| 2 | SEBI | Filing list, disclosure form, insider trading tracker | SebiDisclosure, InsiderTrade |
| 3 | Transfer Pricing | TP study, benchmarking analysis, Form 3CEB | TransferPricingStudy, BenchmarkResult |
| 4 | Crypto / VDA Tax | Transaction list, tax computation, Schedule VDA | VdaTransaction, VdaTaxResult |
| 5 | Startup Compliance | Compliance checklist, DPIIT registration, angel tax | StartupCompliance, DpiitRegistration |
| 6 | LLP Compliance | LLP form list, annual return, partner changes | LlpFiling, LlpPartner |
| 7 | MSME | Vendor verification, MSME registration, payment tracker | MsmeRegistration, VendorVerification |

## Implementation Rules

- Follow Material 3 design language
- Adaptive layouts: NavigationBar (phone), NavigationRail (tablet/desktop)
- Keep files under 400 lines — extract widgets into separate files
- Use Riverpod `ref.watch()` for reactive state
- Handle loading/error/empty states with consistent patterns
- All text user-friendly (no developer jargon)
- Widget tests: 15-25 per module, testing rendering + interactions
- Run `flutter analyze` after each module — zero warnings

## Quality Gates

- [ ] Each screen renders without errors
- [ ] Widget tests pass for all screens
- [ ] `flutter analyze` shows zero issues
- [ ] All existing 5,784 tests still pass
- [ ] Adaptive layout works at 3 breakpoints (phone/tablet/desktop)
- [ ] Loading, error, and empty states handled
- [ ] No hardcoded strings (use domain model values)

## Success Criteria

- 19 new modules with production UI + widget tests
- 25/76 total modules with tested screens (up from 6)
- ~350+ new widget tests
- Zero lint warnings
- All existing tests still passing
