---
title: "Phase 2A: Data Layer Repositories (All 76 Modules)"
status: completed
created: 2026-03-13
completed: 2026-03-15
scope: "all 76 feature modules — expanded from original 9 to full codebase"
---

# Phase 2A: Wire Data Layer Repositories

## Objective
Complete the data layer (Drift DAOs + mappers + repository implementations + feature flags) for all modules.

## Final Status (2026-03-15)
- ✅ Domain layer: 100% (all models, services, business logic)
- ✅ Supabase schema: 100% (18 migrations, 20 tables, RLS)
- ✅ Drift DB: 100% (39 tables, 38 DAOs)
- ✅ Data layer: 100% (all 76 modules wired — mock + real + feature-flag-gated)
- ✅ Tests: 5,784 passing
- 🔶 Presentation: 20% (6 modules with tested screens, 70 with shell UI)

## Scope

**In scope (9 modules):**
1. documents
2. compliance
3. dashboard (aggregated views)
4. firm_operations
5. payroll
6. audit
7. mca (Company Law filings)
8. portal_connector (integration hub)
9. reconciliation (3-way matching engines)

**Out of scope (Phase 3+):**
- Remaining 61 modules
- Presentation layer (UI screens)
- Portal API integrations
- Advanced features (RPA, AI, analytics)

## Work Breakdown (9 Work Units — 1 per module)

Each WU follows the pattern:

```
WU-N: [Module Name]
├─ Files: Drift DAO + local/remote sources + mapper + repository impl
├─ Dependencies: Check if depends on other modules
├─ Effort: ~45 min per module (DAO + mapper + impl + tests)
├─ DoD:
│  ✅ Drift DAO with CRUD operations
│  ✅ Local source (SQLite via Drift)
│  ✅ Remote source (Supabase RPC or REST)
│  ✅ Mapper (domain ↔ data models)
│  ✅ Repository impl (with fallback to mock on error)
│  ✅ Feature flag integration
│  ✅ 100% test coverage
│  ✅ No lint warnings
│  ✅ Immutable models with copyWith
│  ✅ Integration with sync engine
```

---

## WU1: Documents Repository

**Scope:** Store and retrieve client documents (tax forms, certificates, invoices, etc.)

**New files (9 total):**
```
lib/features/documents/
├─ domain/repositories/document_repository.dart
├─ data/daos/documents_dao.dart
├─ data/datasources/documents_local_source.dart
├─ data/datasources/documents_remote_source.dart
├─ data/mappers/document_mapper.dart
├─ data/providers/document_repository_providers.dart
├─ data/repositories/document_repository_impl.dart
├─ data/repositories/mock_document_repository.dart
test/features/documents/data/
├─ documents_dao_test.dart
```

**Domain model already exists:** `DocumentMetadata` (name, type, clientId, uploadedDate, fileSize, mimeType, tags)

**DAO operations:**
- `insertDocument(DocumentMetadata)` → id
- `getDocumentsByClient(clientId)` → List<DocumentMetadata>
- `getDocumentsByType(documentType)` → List<DocumentMetadata>
- `updateDocument(DocumentMetadata)` → success
- `deleteDocument(documentId)` → success
- `searchDocuments(query)` → List<DocumentMetadata> (name/tags)

**Dependencies:** clients (foreign key: clientId)

**Feature flag:** `documents_real_repo`

---

## WU2: Compliance Repository

**Scope:** Track compliance deadlines, filing status, regulatory calendar (ITR, GST, TDS, MCA, audit, payroll)

**New files (9 total):**
```
lib/features/compliance/
├─ domain/repositories/compliance_repository.dart
├─ data/daos/compliance_dao.dart
├─ data/datasources/compliance_local_source.dart
├─ data/datasources/compliance_remote_source.dart
├─ data/mappers/compliance_mapper.dart
├─ data/providers/compliance_repository_providers.dart
├─ data/repositories/compliance_repository_impl.dart
├─ data/repositories/mock_compliance_repository.dart
test/features/compliance/data/
├─ compliance_dao_test.dart
```

**Domain models already exist:**
- `ComplianceEvent` (clientId, type, description, dueDate, filedDate, status, penalty)
- `enum ComplianceEventType` → itr, gst, tds, mca, audit, payroll, other

**DAO operations:**
- `insertEvent(ComplianceEvent)` → id
- `getEventsByClient(clientId)` → List<ComplianceEvent>
- `getUpcomingEvents(daysAhead)` → List<ComplianceEvent> (for dashboard)
- `getOverdueEvents()` → List<ComplianceEvent>
- `updateEventStatus(eventId, status)` → success
- `getEventsByType(type)` → List<ComplianceEvent>

**Dependencies:** clients (foreign key: clientId)

**Feature flag:** `compliance_real_repo`

---

## WU3: Dashboard Repository

**Scope:** Aggregated KPI data (summary stats, recent filings, pending tasks, top clients)

**New files (9 total):**
```
lib/features/dashboard/
├─ domain/repositories/dashboard_repository.dart
├─ data/daos/dashboard_dao.dart (aggregation queries)
├─ data/datasources/dashboard_local_source.dart
├─ data/datasources/dashboard_remote_source.dart
├─ data/mappers/dashboard_mapper.dart
├─ data/providers/dashboard_repository_providers.dart
├─ data/repositories/dashboard_repository_impl.dart
├─ data/repositories/mock_dashboard_repository.dart
test/features/dashboard/data/
├─ dashboard_dao_test.dart
```

**Domain models already exist:**
- `DashboardSummary` (totalClients, filedReturns, pendingReturns, overdueTasks, upcomingDeadlines, totalBilling)
- `RecentFiling` (clientName, filingType, status, date)
- `TopClient` (clientName, filingCount, billingAmount)

**DAO operations (aggregation queries):**
- `getTotalClients()` → int
- `getFiledReturnsCount(period)` → int
- `getPendingReturnsCount()` → int
- `getOverdueTasksCount()` → int
- `getUpcomingDeadlines(daysAhead)` → List<ComplianceEvent>
- `getRecentFilings(limit)` → List<RecentFiling>
- `getTopClients(limit)` → List<TopClient>

**Dependencies:** clients, gst, tds, income_tax, compliance, tasks

**Feature flag:** `dashboard_real_repo`

**Note:** This module aggregates across multiple tables; use database views or complex queries.

---

## WU4: Firm Operations Repository

**Scope:** Manage CA firm info (address, bank account, PAN, TAN, DSC), team members, client assignments, firm settings

**New files (9 total):**
```
lib/features/firm_operations/
├─ domain/repositories/firm_operations_repository.dart
├─ data/daos/firm_operations_dao.dart
├─ data/datasources/firm_operations_local_source.dart
├─ data/datasources/firm_operations_remote_source.dart
├─ data/mappers/firm_operations_mapper.dart
├─ data/providers/firm_operations_repository_providers.dart
├─ data/repositories/firm_operations_repository_impl.dart
├─ data/repositories/mock_firm_operations_repository.dart
test/features/firm_operations/data/
├─ firm_operations_dao_test.dart
```

**Domain models already exist:**
- `FirmInfo` (name, address, panNumber, tanNumber, dscCertificate, bankAccount, registrationDate, partners)
- `TeamMember` (name, pan, role, email, phone, permissions)
- `ClientAssignment` (clientId, assignedToId, startDate, endDate, role)

**DAO operations:**
- `getFirmInfo()` → FirmInfo
- `updateFirmInfo(FirmInfo)` → success
- `insertTeamMember(TeamMember)` → id
- `getTeamMembers()` → List<TeamMember>
- `updateTeamMember(TeamMember)` → success
- `deleteTeamMember(memberId)` → success
- `assignClient(ClientAssignment)` → id
- `getClientsAssignedTo(memberId)` → List<Client>

**Dependencies:** clients (via ClientAssignment)

**Feature flag:** `firm_operations_real_repo`

---

## WU5: Payroll Repository

**Scope:** Track employee payroll, salary components, statutory deductions (PF, ESI, PT, TDS), payslips

**New files (9 total):**
```
lib/features/payroll/
├─ domain/repositories/payroll_repository.dart
├─ data/daos/payroll_dao.dart
├─ data/datasources/payroll_local_source.dart
├─ data/datasources/payroll_remote_source.dart
├─ data/mappers/payroll_mapper.dart
├─ data/providers/payroll_repository_providers.dart
├─ data/repositories/payroll_repository_impl.dart
├─ data/repositories/mock_payroll_repository.dart
test/features/payroll/data/
├─ payroll_dao_test.dart
```

**Domain models already exist:**
- `PayrollEntry` (clientId, employeeId, month, year, basicSalary, allowances, deductions, tdsDeducted, pfDeducted, esiDeducted, netSalary, status)
- `PayslipTemplate` (clientId, logoUrl, companyAddress, bankDetails, payslipFormat)

**DAO operations:**
- `insertPayrollEntry(PayrollEntry)` → id
- `getPayrollByClient(clientId, year)` → List<PayrollEntry>
- `getPayrollByEmployee(employeeId, year)` → List<PayrollEntry>
- `updatePayrollEntry(PayrollEntry)` → success
- `deletePayrollEntry(payrollId)` → success
- `getPayrollByMonth(clientId, month, year)` → List<PayrollEntry>

**Dependencies:** clients (foreign key: clientId)

**Feature flag:** `payroll_real_repo`

---

## WU6: Audit Repository

**Scope:** Track audit assignments, audit schedules, SA Report (3CD), auditor notes, audit status

**New files (9 total):**
```
lib/features/audit/
├─ domain/repositories/audit_repository.dart
├─ data/daos/audit_dao.dart
├─ data/datasources/audit_local_source.dart
├─ data/datasources/audit_remote_source.dart
├─ data/mappers/audit_mapper.dart
├─ data/providers/audit_repository_providers.dart
├─ data/repositories/audit_repository_impl.dart
├─ data/repositories/mock_audit_repository.dart
test/features/audit/data/
├─ audit_dao_test.dart
```

**Domain models already exist:**
- `AuditAssignment` (clientId, auditorId, financialYear, startDate, endDate, status, fee)
- `AuditReport` (clientId, year, saReportNumber, reportDate, reportedBy, auditFindings)

**DAO operations:**
- `insertAuditAssignment(AuditAssignment)` → id
- `getAuditsByClient(clientId)` → List<AuditAssignment>
- `getAuditsByAuditor(auditorId)` → List<AuditAssignment>
- `updateAuditStatus(auditId, status)` → success
- `insertAuditReport(AuditReport)` → id
- `getAuditReportByClient(clientId, year)` → AuditReport?

**Dependencies:** clients (foreign key: clientId), firm_operations (auditorId → TeamMember)

**Feature flag:** `audit_real_repo`

---

## WU7: MCA Repository

**Scope:** Manage Company Law filings (MCA e-Forms: DIR-3, INC-22A, AOC-4, DPT-3, MBP-1, etc.), ROC filings, compliance calendar

**New files (9 total):**
```
lib/features/mca/
├─ domain/repositories/mca_repository.dart
├─ data/daos/mca_dao.dart
├─ data/datasources/mca_local_source.dart
├─ data/datasources/mca_remote_source.dart
├─ data/mappers/mca_mapper.dart
├─ data/providers/mca_repository_providers.dart
├─ data/repositories/mca_repository_impl.dart
├─ data/repositories/mock_mca_repository.dart
test/features/mca/data/
├─ mca_dao_test.dart
```

**Domain models already exist:**
- `MCAFiling` (clientId, formType, financialYear, dueDate, filedDate, status, filingNumber, remarks)
- `enum MCAFormType` → dir3, inc22a, aoc4, dpt3, mbp1, form32, form33, other

**DAO operations:**
- `insertMCAFiling(MCAFiling)` → id
- `getMCAFilingsByClient(clientId)` → List<MCAFiling>
- `getMCAFilingsByYear(clientId, year)` → List<MCAFiling>
- `updateMCAFiling(MCAFiling)` → success
- `getMCAFilingsByStatus(status)` → List<MCAFiling>
- `getDueMCAFilings(daysAhead)` → List<MCAFiling>

**Dependencies:** clients (foreign key: clientId)

**Feature flag:** `mca_real_repo`

---

## WU8: Portal Connector Repository

**Scope:** Store OAuth tokens, API credentials, sync status for external portals (ITD, GSTN, TRACES, MCA, EPFO)

**New files (9 total):**
```
lib/features/portal_connector/
├─ domain/repositories/portal_connector_repository.dart
├─ data/daos/portal_connector_dao.dart
├─ data/datasources/portal_connector_local_source.dart
├─ data/datasources/portal_connector_remote_source.dart
├─ data/mappers/portal_connector_mapper.dart
├─ data/providers/portal_connector_repository_providers.dart
├─ data/repositories/portal_connector_repository_impl.dart
├─ data/repositories/mock_portal_connector_repository.dart
test/features/portal_connector/data/
├─ portal_connector_dao_test.dart
```

**Domain models already exist:**
- `PortalCredential` (portalType, username, encryptedPassword, grantToken, refreshToken, expiresAt, lastSyncDate, status)
- `enum PortalType` → itd, gstn, traces, mca, epfo

**DAO operations:**
- `storeCredential(PortalCredential)` → id
- `getCredential(portalType)` → PortalCredential?
- `updateCredential(PortalCredential)` → success
- `deleteCredential(portalType)` → success
- `getSyncStatus(portalType)` → SyncStatus?
- `updateSyncStatus(portalType, status)` → success

**Security Note:** Passwords stored with encryption; use secure storage (Flutter Secure Storage integration).

**Dependencies:** None

**Feature flag:** `portal_connector_real_repo`

---

## WU9: Reconciliation Repository

**Scope:** Store reconciliation results (26AS/AIS 3-way match, GSTR-2B matching, bank reconciliation), discrepancies, action items

**New files (9 total):**
```
lib/features/reconciliation/
├─ domain/repositories/reconciliation_repository.dart
├─ data/daos/reconciliation_dao.dart
├─ data/datasources/reconciliation_local_source.dart
├─ data/datasources/reconciliation_remote_source.dart
├─ data/mappers/reconciliation_mapper.dart
├─ data/providers/reconciliation_repository_providers.dart
├─ data/repositories/reconciliation_repository_impl.dart
├─ data/repositories/mock_reconciliation_repository.dart
test/features/reconciliation/data/
├─ reconciliation_dao_test.dart
```

**Domain models already exist:**
- `ReconciliationResult` (clientId, reconciliationType, period, totalMatched, totalUnmatched, discrepancies, status, reviewedBy, reviewedDate)
- `enum ReconciliationType` → tds26as, gstr2b, bankRecon, pan3way

**DAO operations:**
- `insertReconciliationResult(ReconciliationResult)` → id
- `getReconciliationsByClient(clientId)` → List<ReconciliationResult>
- `getReconciliationByType(type, clientId)` → List<ReconciliationResult>
- `getUnreconciledItems(clientId)` → List<Discrepancy>
- `updateReconciliationStatus(resultId, status)` → success
- `markDiscrepancyResolved(discrepancyId)` → success

**Dependencies:** clients, gst (for GSTR-2B matching), tds (for 26AS reconciliation), income_tax (for PAN 3-way)

**Feature flag:** `reconciliation_real_repo`

---

## Execution Order

**Parallel execution (no dependencies):**
- WU1: documents
- WU2: compliance
- WU4: firm_operations
- WU5: payroll
- WU6: audit
- WU7: mca
- WU8: portal_connector

**Sequential (depends on others):**
- WU3: dashboard (depends on clients, gst, tds, income_tax, compliance, tasks — all completed)
- WU9: reconciliation (depends on clients, gst, tds, income_tax — all completed)

**Recommended batching:**
1. **Batch A (parallel):** WU1, WU2, WU4, WU5, WU6, WU7, WU8 (7 modules)
2. **Batch B (sequential):** WU3, WU9 (2 modules — depends on Batch A)

---

## Quality Gates

- ✅ TDD: Write DAO tests first, watch them fail, implement DAO, tests pass
- ✅ Mapper tests: Test domain ↔ data model conversion
- ✅ Repository tests: Test impl with mock sources
- ✅ 100% coverage enforced via `.coverage-thresholds.json`
- ✅ No lint warnings (`flutter analyze`)
- ✅ All models immutable with `copyWith`
- ✅ Integration with sync engine (where applicable)
- ✅ Feature flag gating (each module)
- ✅ Adversarial review per work unit

---

## Estimated Effort

- **Per module:** 45 min (DAO + mapper + impl + tests)
- **9 modules parallel:** ~45 min wall-clock (with agent parallelization)
- **Total files:** ~9 modules × 9 files = 81 files

---

## Success Criteria (Definition of Done)

### For each work unit:
- [ ] Drift DAO fully implemented (CRUD + domain-specific queries)
- [ ] Local source implemented (SQLite via Drift)
- [ ] Remote source implemented (Supabase REST/RPC)
- [ ] Mapper implemented (bi-directional conversion)
- [ ] Repository impl completed (with error handling + feature flag)
- [ ] All tests passing (DAO, mapper, repository)
- [ ] 100% test coverage for the module
- [ ] No lint warnings
- [ ] All models immutable (copyWith working)
- [ ] Integration with sync engine verified
- [ ] Feature flag added to `feature_flag_provider.dart`
- [ ] Adversarial review APPROVED
- [ ] Commit created with comprehensive message

### For Phase 2:
- [ ] All 9 modules wired and tested
- [ ] 0 lint warnings across all new files
- [ ] Coverage thresholds met
- [ ] Data layer completion raised from 8% to 60% (9 of 15 core modules)
- [ ] `/self-reflect` run to extract learnings
- [ ] PR created with all knowledge base updates
