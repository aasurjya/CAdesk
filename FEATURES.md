# CADesk — Complete Features & Modules

> Comprehensive CA practice management platform — 62 modules covering tax, compliance, audit, firm operations, AI automation, client engagement & **core filing engine with portal integration**
>
> Delivery standard: Every module below should be considered complete only at **100% functional completion** with **production-ready quality**, including validations, approvals, audit trail, security, analytics, integrations, and mobile/web usability.
>
> **Overall codebase completion: ~28%** — 62 modules all have UI shells with clean architecture, Riverpod state, mock data, and navigable flows. 16 modules have deep business logic: ITR-1 filing engine with 7-step wizard (tax regime computation, 234A/B/C interest, ITD JSON export), ITC reconciliation, challan tracking, GST invoice calculator, salary computation (PF/ESI/PT/TDS), financial ratio analysis (11 ratios, WDV depreciation), real running timer (start/pause/stop), client compliance health scores, cross-module KPI aggregation, EMI/NPV/IRR calculators, VDA tax (30% flat Section 115BBH, TDS 194S, loss disallowance), MSME 43B(h) 45-day rule with 18.75% delayed payment interest, analytics KPI grid + revenue chart + health distribution, LLP ₹100/day penalty calculator with strike-off risk, and Startup 80-IAC / DPIIT / angel tax computations. Module 52 (ITR Filing Engine) has production-quality tax computation for both regimes with surcharge, cess, rebate 87A, and comprehensive new filing intake form. Zero modules have real API integration or automated tests.

---

## Platform Core

- Single dashboard for all modules
- Unified client database (search by Name, PAN, Code)
- Role-based user access & permissions
- Auto software updates
- E-payment of tax challans
- Email & SMS to clients
- Client-wise password protection
- Birthday reminders
- Return filing status (filed / pending)
- Digital Signature Certificate (DSC) support
- Mobile-first native apps (iOS / Android)
- Offline-first with cloud sync
- Open APIs for third-party integrations
- Banking API integration (real-time feeds)
- Multi-currency support
- End-to-end encryption & MFA
- Audit trail for all user actions

---

# PART A — Core Tax & Compliance Modules

---

## 1. Income Tax

### Filing
- Computation of income, tax, deductions, set-off & carry-forward of losses
- Online e-return filing (all ITR forms)
- Advance tax calculation
- Relief under Section 89(1) — Form 10E
- Return filing for legal heirs
- Old vs New tax regime comparison calculator
- ITR-U (Updated Return) support with 4-year window
- **AIS/TIS Reconciliation Engine:** Auto-matches declared income against AIS/TIS data and flags discrepancies before filing

### Portal Integration
- DSC registration at ITD portal
- Auto ITR-V download
- Bulk refund status tracking
- Import data from Form 26AS
- ITR rectification uploads
- Aadhaar-PAN linking & EVC generation
- E-verification via Aadhaar OTP / EVC
- Auto-collect ITD communications & intimations
- UDIN auto-generation for audit reports

### Advanced
- Error detection with same-screen correction
- Multi-year master data auto-transfer
- Partner remuneration → individual ITR
- Side-by-side current vs prior year comparison
- Capital gains indexing & ready reckoner

---

## 2. GST

### Returns & Filing
- Prepare, validate & file GST returns (GSTR-1, 3B, 9, 9C, etc.)
- Offline return preparation
- Bulk return filing
- DSC / e-sign authentication
- Return status tracking

### Invoice Management
- Issue GST-compliant invoices
- Auto-prepare GSTR-1 from invoice data
- Auto invoice transfer between periods
- E-invoicing (mandatory ≥ ₹5 crore; ≥ ₹2 crore from Oct 2025)
- Invoice Management System (IMS)
- B2C e-invoicing pilot support
- **30-day / 3-day e-invoice reporting window enforcement** — Auto-blocks late uploads per threshold
- **2FA enforcement for e-invoice & e-way bill** (mandatory April 2025)
- **Enhanced QR code** with delivery place, payment status, and faster verification
- **₹25,000/invoice penalty tracker** — Flags non-compliant invoices before filing deadline

### Data Input
- Import from GST portal, Tally, Excel
- Smart comparison for multiple imports
- Master data setup (items, recipients, suppliers)
- MFA for GST portal (mandatory April 2025)

### ITC & Tax Liability
- Tax liability calculations
- ITC calculation & management
- TDS/TCS adjustments & reversals
- Credit & cash ledger management
- Input Service Distributor (ISD) tracking

### Reconciliation
- AI-powered invoice matching & mismatch detection
- Auto fetch GSTR data for validation
- Auto accept/reject counterparty filings
- Mismatch reports & ITC credit reports
- Email notifications to suppliers

---

## 3. TDS / TCS

### Forms Supported
- Form 24Q — Salary TDS
- Form 26Q — Non-salary TDS
- Form 27Q — Non-resident TDS
- Form 27EQ — TCS
- Form 16 / 16A — TDS certificates
- Form 15G / 15H
- Form 26QB — TDS on property

### Filing & Compliance
- Automated TDS calculation
- Pre-scrutiny before FVU generation
- Original & correction return filing
- Direct upload to ITD portal
- Late filing fee calculations
- Challan linking via TRACES
- Quarterly interest calculation reports
- Form 16/16A digital generation & email distribution
- Section 194T — TDS on partner remuneration (10%)

### Data Management
- Import challan from OLTAS
- Import from Tally, Excel, bank records
- Bulk PAN verification at TRACES
- Duplicate detection (PAN, names)

---

## 4. TDS.AI
- AI-powered TDS return preparation from accounting software
- Automated TDS extraction & form generation
- Smart section detection & rate application

---

## 5. Balance Sheet & Audit

### Company Financials
- Balance Sheet per Schedule III
- Depreciation chart per Schedule II
- Automated Cash Flow Statement (indirect method)
- Individual asset depreciation calculator
- Auto notes generation per Schedule III

### Non-Company Financials
- Horizontal & vertical balance sheet formats
- Depreciation per IT Act
- Income & Expenditure, Receipt & Payment accounts
- Previous year comparison

### Tax Audit & Filing
- Form 3CD, Form 29B, Form 10CCC preparation & filing
- CA registration & status tracking at portal
- DSC auto-signing for attachments
- PDF conversion of financial statements
- **Clause-by-Clause AI Validation:** Cross-checks Form 3CD clauses against ledger data to prevent reporting mismatches

### Integration
- Tally & Excel imports
- Transfer balance sheet data → ITR forms
- Multiple business statements merging

### Reports & Templates
- Independent Auditor's Report (Companies Act 2013)
- Board Director Report templates
- Account notes templates

---

## 6. Assessment Order Checker

- Verify calculations: Section 143(1), 143(3), 147, 153A, 154, Appeal Effects
- Interest checks: Section 234B/C/D, 220(2), 244A
- Import order data from IT module or prior orders
- Customizable report generation

---

## 7. MCA / ROC Compliance

- Single-click MCA portal login
- Import company master info via CIN
- Import director info via DIN
- Download filed form acknowledgements via SRN
- Preparation: Resolutions, notices, meeting minutes
- Annual return preparation (MGT-7, MGT-9)
- E-Forms per Companies Act 2013
- Compliance certificate generation
- DSC registration without MCA login

---

## 8. XBRL Filing

- Color-coded input types (numeric, text, date, text block)
- Hide inapplicable sheets for consolidated/standalone
- Copy-paste from Word/Excel with formatting
- Auto-populate company/director details via CIN
- Auto-generate compulsory tags when no value
- Standard item lists for data entry

---

## 9. CMA / Financial Projections

- CMA data auto-preparation from % increase in sales
- Comparative statement, MPBF, Fund Flow
- Closing stock auto-calculation on turnover period
- EMI calculation, comparative EMI, loan calculator
- IRR, NPV, interest rate determination
- Broken period functionality
- Year-over-year comparative analysis

---

## 10. Payroll

### Core
- Customizable salary packages, heads, leaves, holidays
- Excel import for employee master, packages, attendance
- Multiple attendance input methods
- Loans, arrears, increments, overtime, bonus
- Auto-update leave register from attendance
- PF & ESI challan & statutory returns
- Single-click full & final settlement
- Bank salary transfer report
- ECR & challan download from EPFO Portal
- Tax computation under Section 115BAC (new slab)
- No cap on employees or companies
- Built-in TDS (no extra cost)

### Biometric Integration
- Time machine & attendance device sync
- Late arrival, early departure reports

### Employee Self-Service Portal
- Leave, loan, resignation requests online
- Claim management (medical, LTA, travel)
- Access pay slips, Form 16, ITR documents

---

## 11. Document Management

- All client documents at one place
- View, print, email in single click
- Custom categories & document organization
- Cloud access anytime, anywhere
- Client portal to view, print & download
- Mobile app for document access

---

## 12. Staff Monitoring

- Remote access to any computer screen
- View unlimited screens simultaneously
- Website access restrictions
- Auto screen/webcam recording
- Internet browsing history logs
- Real-time security alerts
- File transfers & instant messaging
- Multi-branch & multi-location support

---

## 13. Cloud & Remote Access

- **Cloud App** — Access all modules from browser/cloud anywhere
- **Cloud Backup** — Secure offsite backup of all data

---

## 14. Billing

- GST-compliant invoicing
- Complete billing management
- Invoice generation & tracking

---

# PART B — Modern Practice Management Modules

---

## 15. Practice Management & Workflow

- Task tracking with deadlines, priorities, assignees
- 70+ pre-built workflow templates (reconciliation, tax prep, audit)
- Kanban board for visual task progression
- Cascading deadline updates across related tasks
- Task dependency management
- Compliance calendar with 30/15/7-day alerts
- Bottleneck identification & escalation alerts
- Recurring task auto-creation (monthly, quarterly, annual)
- Return filing dashboard (filed / pending / overdue)
- **AI Workload Balancer:** Auto-assigns tasks based on staff skill matrix and current bandwidth
- **Smart Dependency Triggers:** e.g., Auto-creates MCA filing tasks the moment a company audit is marked 'Complete'

---

## 16. Client Relationship Management (CRM)

- Unified client database with full interaction history
- Client profitability analysis (revenue vs cost per client)
- Client risk assessment & quality scoring
- Service assignment & fee structure tracking
- Engagement letter templates with e-signature
- Fee proposal generation & approval workflow
- Client segmentation (individual, HUF, firm, company, trust)
- Referral tracking & source attribution

---

## 17. AI & Automation

- OCR document scanning (99%+ accuracy)
- Auto-categorization of documents & transactions
- AI-powered bank reconciliation (80-90% auto-match)
- Predictive analytics & cash flow forecasting
- Anomaly detection for unusual transactions
- Natural language search across all data
- Agentic AI for task orchestration across modules
- Smart form auto-fill from scanned documents
- AI-powered error detection before filing
- Auto-extraction of data from Form 16, 26AS, bank statements
- **AI Notice Analyzer:** Scans ITD/GST notices, identifies section & severity, calculates exact deadline, and drafts a preliminary response
- **Agentic OTP & Login Manager:** Securely auto-fetches OTPs from client emails/SMS (with consent) to bypass portal login bottlenecks
- **Missing Data Identifier:** AI scans uploaded documents and flags missing months/pages before assigning to human staff
- **100% Transaction Analysis (not sampling):** MindBridge-style AI scans every entry for anomalies, duplicates, and unusual patterns — replaces traditional audit sampling
- **Continuous Transaction Controls (CTC):** Real-time invoice validation at creation time via GSTN/IRP API — errors caught before filing, not after
- **AI Meeting Transcription:** Auto-transcribes client calls (Zoom/Teams/Meet), extracts action items, and creates follow-up tasks in workflow
- **CA GPT / Legal Research Engine:** RAG-based assistant trained on Income Tax Act, GST Act, Companies Act, RBI/FEMA circulars, ICAI standards — answers with source citations
- **Predictive 143(1) Mismatch Detector:** Compares declared income against AIS/TIS in real-time, detects omissions and inconsistencies before submission to prevent intimations/demands
- **RPA Bot Framework:** Configurable bots for repetitive portal tasks — bulk challan downloads, TRACES requests, MCA form prefill — without manual click-through

---

## 18. Client Portal & Communication

- Secure branded client portal (web + mobile)
- Document upload, sharing & e-signatures
- Integrated messaging & threaded conversations
- WhatsApp Business API integration
- Automated reminders (email, SMS, WhatsApp)
- Payment collection through portal
- Client satisfaction surveys & NPS tracking
- Task status visibility for clients
- Query management with response tracking
- **WhatsApp AI Follow-up Bot:** Conversational bot that automatically chases clients for pending documents, challan payments, and signatures without human intervention
- **Magic Links:** Passwordless, OTP-secured links for clients to instantly upload specific requested files straight into the correct folder
- **Bulk Due Date Reminders:** Automated WhatsApp/SMS/email reminders for upcoming GST, TDS, ITR deadlines across all clients in one click
- **Invoice & Receipt Auto-Delivery:** Auto-send invoice copies and payment receipts via WhatsApp on generation
- **Client Self-Service Tax Q&A Bot:** AI chatbot on portal answers common taxpayer queries (refund status, TDS certificate, ITR status) without staff intervention

---

## 19. Analytics & Business Intelligence

- Real-time KPI dashboards (firm, engagement, compliance, staff)
- Staff utilization & realization metrics
- Revenue trend analysis by service / client
- WIP (Work-in-Progress) tracking
- Aging receivables & collection forecasting
- Custom report builder (drag-and-drop)
- Peer benchmarking comparisons
- Exception alerts & threshold-based notifications
- **Partner Profitability Dashboard:** Visualizes cost-to-serve vs. fixed-fee agreements to flag unprofitable clients/engagements
- **Churn Risk Predictor:** AI flags clients at risk of leaving based on communication drops or missed deadlines
- **ESG Compliance Metrics:** Track carbon taxes, green incentives, and sustainability tax contributions per SEBI 2026 norms
- **Seasonal Load Forecaster:** Predicts staff demand spikes (ITR season, GST annual, TDS quarters) and suggests hiring/outsourcing windows
- **Revenue per Hour Heatmap:** Identifies which services, clients, and staff yield highest/lowest revenue per billable hour

---

## 20. Time Tracking & Billing Analytics

- Real-time task timer integration
- Billable vs non-billable hour tracking
- Auto-link completed tasks → invoices
- Recurring invoice automation
- Budget vs actual hours per engagement
- Revenue recognition (time-based & project-based)
- Cost-to-serve analysis per client
- Realization rate tracking
- Billing capacity & utilization optimization

---

## 21. CA Firm Operations

- Staff KPI tracking (billable hours, completion rates, quality metrics)
- CPE compliance tracking (required vs completed hours)
- Skill matrix mapping per staff member
- Capacity planning & resource allocation
- Knowledge base & SOP management
- Workpaper management & audit program templates
- Assignment scheduling with milestone tracking
- Performance reviews & ratings
- Multi-branch office management
- **Articled Assistant Training Tracker:** CPE hours, rotation schedule, mentor assignments, competency assessments per ICAI norms
- **Outsourced Team Management:** SLA tracking, quality checks, and access controls for freelance/outsourced tax preparers

---

## 22. Client Onboarding & KYC

- KYC automation with document verification workflow
- Central KYC (CKYC) integration with 14-digit KIN
- Aadhaar / PAN real-time verification
- Engagement letter management with e-sign
- Document checklist by service type
- Expiry tracking (GST cert, insurance, licenses)
- Digital vault for secure document storage
- Data classification (confidential, sensitive, public)

---

# PART C — Specialized Compliance Modules (India-Specific)

---

## 23. FEMA & RBI Compliance

- FEMA form filing (FC-GPR, FC-TRS, APR, FLA)
- FDI tracking & foreign currency account management
- Authorized Dealer bank integration
- Export-import compliance modules
- Penalty management (₹2 lakh cap tracking)
- RBI regulation amendment tracking

---

## 24. SEBI & Capital Market Compliance

- Quarterly governance & financial disclosures
- Related party transaction reporting
- Material events logging (tax litigation, penalties, acquisitions)
- BSE / NSE portal integration
- 45/60-day filing deadline tracking
- Secretarial auditor restriction monitoring

---

## 25. Transfer Pricing

- TP documentation (Master file, Local file, TP study)
- Form 3CEB electronic filing
- ALP (Arm's Length Price) benchmarking tools
- Safe harbour rules tracking (₹3B threshold)
- APA management (Unilateral, Bilateral, Multilateral)
- MAP (Mutual Agreement Procedure) documentation
- DTAA treaty benefits monitoring

---

## 26. Crypto / Virtual Digital Asset (VDA) Taxation

- VDA Schedule auto-population in ITR
- Buy / sell / transfer / mining transaction logging
- 30% flat tax computation on gains
- TDS u/s 194S tracking (1% on transfers > ₹50K / ₹10K)
- NFT & token type support
- Loss restriction validation (no set-off against other income)
- Exchange-wise TDS reconciliation

---

## 27. Startup Compliance

- DPIIT startup recognition tracking
- Section 80-IAC (3-year tax holiday) management
- Angel tax documentation (historical records)
- Cap table management with investment history
- Startup compliance calendar (board meetings, filings)
- ₹100 crore turnover ceiling monitoring

---

## 28. LLP Compliance

- Form 11 filing (annual return — due May 30)
- Form 8 filing (accounts & solvency — due October 30)
- MCA portal integration for direct filing
- Audit threshold monitoring (₹40L turnover / ₹25L capital)
- ITR-5 filing management
- Late filing penalty calculations (₹100/day, max ₹1L)
- Designated partner tracking

---

## 29. MSME Compliance

- MSME vendor classification & payment tracking
- 45-day payment deadline alerts
- Form MSME-1 auto-generation for delays
- Section 43B(h) deduction forfeit alerts
- Payment aging reports
- MSME registration verification

---

## 30. Advanced Audit Types

### Statutory Audit
- Bank audit (NPA review, RBI returns, LFAR)
- Concurrent audit report coordination
- Branch-wise audit planning
- Audit appointment eligibility (RBI guidelines)

### Internal Audit
- Risk assessment tools (inherent vs control risk)
- Compliance testing checklists
- Internal control testing documentation
- Findings & recommendations report generation

### Stock / Inventory Audit
- Physical verification observation logs
- Test count documentation & sampling
- Valuation testing (FIFO, LIFO, weighted average)
- Stock statement & inventory certificate generation
- Bank mandate frequency tracking

### Cost Audit
- Cost record analysis & verification
- Manufacturing overhead allocation testing
- Cost accounting standards compliance
- Cost audit report generation

### Forensic Audit
- Fraud detection analytics & pattern recognition
- Digital evidence preservation & analysis
- Investigation documentation & case file management
- Employee misconduct investigation templates
- **AI-powered Benford's Law analysis** on large transaction sets to detect fabricated entries
- **Shell company / fake ITC detection** using GST analytics (aligned with govt RegTech enforcement)
- **Duplicate vendor payment scanner** with fuzzy name/account matching

---

## 31. Faceless Assessment & E-Proceedings

- NFAC communication tracking & response management
- Digital notice upload & submission
- Virtual hearing scheduling & video conferencing
- Updated Return (ITR-U) with 4-year window
- Penalty calculation for delayed ITR-U (25% / 50% / 60% / 70%)
- Physical verification documentation tracking
- E-assessment portal integration

---

# PART E — Trusted Infrastructure & Integrations

---

## 32. Regulatory Trust & Security

- GSP / ASP certification workflow with automated readiness checklist
- e-Return Intermediary (eRI) compliance artifacts & renewal reminders
- SOC 2 Type II, ISO 27001, and RBI cyber-security control tracking
- Quarterly VAPT scheduling with remediation task automation
- 128-bit+ TLS enforcement, hardware-backed key management, field-level encryption
- Data residency controls (India / multi-region) with audit logs
- Privacy impact assessments and consent registry per client engagement

---

## 33. Data Pipelines & Broker Integrations

- Bulk JSON client ingestion with schema validation & rollback
- Form 16 / 16A, Form 26AS, AIS & TIS auto-import with delta detection
- Direct connectors for broker / RTA feeds (Zerodha, CAMS, KFintech, Karvy, Groww, Angel One)
- Capital gains normalization (equity, F&O, crypto) with rule-based tagging
- Automated mapping from Tally, Zoho Books, QuickBooks, SAP, Oracle Fusion
- Background isolate ingestion for massive files with progress reporting
- Webhooks & APIs for third-party onboarding portals to push artifacts

---

## 34. Collaboration & Mobility Enhancements

- Unlimited concurrent logins with activity indicators & presence
- Field-level locking and conflict resolution for shared returns / workpapers
- Offline-first mobile companion with bilingual UI (9 Indian languages + English)
- In-app approvals, reminders, and push notifications synced across devices
- Role-aware workspaces for partners, seniors, and outsourced teams
- Secure guest links for auditors, bankers, investors with expiry policies
- Auto-translated client summaries & alerts for vernacular preferences

---

## 35. Ecosystem Integrations & Marketplace

- GSTN, MCA, TRACES, RBI and NSE/BSE API integrations exposed via unified connector hub
- Plug-and-play widgets for payment gateways, e-sign, video KYC, WhatsApp Business
- Marketplace SDK for third-party apps (valuation, legal, payroll) with revenue share controls
- Event bus & webhook subscriptions for external automation (Zapier, Make, n8n)
- GraphQL + REST APIs with fine-grained token scopes and per-client throttling
- Integration health dashboard with heartbeat monitoring & auto-retry policies
- Sandbox environment for partners to test against mock compliance data

---

# PART F — High-Impact CA Growth & Control Modules

---

## 36. Notice Resolution & Litigation Command Center

- Central inbox for Income Tax, GST, MCA, EPFO, ESIC, and local authority notices
- AI notice triage by section, urgency, risk, and probable business impact
- Response playbooks for common notices with checklist-driven drafting workflow
- Hearing preparation packs with chronology, facts, evidence bundle, and argument notes
- Appeal ladder tracking (reply → rectification → CIT(A) → ITAT) with stage-wise deadlines
- Counsel / client / internal assignment matrix with responsibility lock-in
- Adjournment, submission, and order outcome register with reusable precedent tagging

---

## 37. DSC, Portal Credentials & Consent Vault

- DSC inventory for clients, partners, directors, and authorized signatories
- Expiry reminders for DSC, DIN KYC, PAN-Aadhaar, GST credentials, MSME, IEC, and licenses
- Portal credential vault with role-based masked access and approval logs
- Consent-based OTP capture workflows for ITD, GST, MCA, TRACES, EPFO, and bank portals
- Device-to-client mapping for token-based signatures and USB DSC troubleshooting tracker
- Failed login / captcha / lockout incident board with escalation workflow
- Authorized signatory change history with downstream compliance impact alerts

---

## 38. Renewal, Retainer & Compliance Expiry Control

- Master expiry calendar for GST LUT, FSSAI, IEC, trade licenses, professional tax, PF/ESI registrations, and contracts
- Renewal pipelines with document checklist, owner assignment, and SLA countdown
- Auto-generate monthly / quarterly / annual retainer work orders from signed engagements
- Fixed-fee retainer tracking with scope consumed vs scope remaining
- “At-risk renewal” alerts based on pending work, delayed responses, or unresolved complaints
- Client-wise annual compliance heatmap to spot neglected entities early
- Bulk renewal campaign engine over email, SMS, WhatsApp, and in-app alerts

---

## 39. Fee Leakage, Scope Control & Recovery

- Scope creep tracker comparing promised deliverables vs extra requests actually serviced
- Out-of-scope work capture from messages, calls, and task logs with billing recommendations
- Partner approval flow for discounts, write-offs, credit notes, and urgent filing premiums
- Recovery prioritization by aging, client importance, and probability of collection
- Engagement margin tracker (fees billed vs team cost vs realization)
- Auto-suggest revised retainers for chronically underpriced clients
- Billing dispute workspace with document proof, engagement terms, and approval trail

---

## 40. Knowledge Engine & CA Precedent Library

- Searchable library of prior replies, submissions, notices, and hearing outcomes
- Clause / section-based knowledge retrieval for Income Tax, GST, TDS, FEMA, MCA, and audit matters
- AI drafting assistant grounded on your own firm’s approved templates and prior submissions
- Query-to-precedent linking so juniors can reuse similar solved cases safely
- Internal review notes, partner comments, and “why this worked” knowledge capture
- Topic-wise update digest for law changes, circulars, notifications, and portal changes
- Training mode that converts completed cases into SOPs and article-assistant learning packs

---

# PART G — Tax Practice Growth Modules

---

## 41. Tax Advisory Opportunity Engine

- AI scans ITR, GST, TDS, payroll, and audit data to identify advisory upsell opportunities
- Missed deduction / refund / regime-switch / advance-tax optimization alerts
- Capital gains harvesting, salary restructuring, and entity-level tax-saving suggestions
- Opportunity scoring by urgency, estimated fee potential, and likelihood of conversion
- Auto-generate advisory tasks, partner review notes, and client proposal drafts
- Client-wise tax health score with quarterly / annual advisory review cycles
- Compliance-to-advisory conversion dashboard by client, team, and service line

---

## 42. Lead Funnel & Seasonal Tax Campaigns

- Lead capture from website forms, WhatsApp, referral links, webinars, and walk-ins
- Seasonal campaign templates for ITR filing, advance tax, GST annual return, TDS correction, and ITR-U
- AI lead qualification based on case complexity, urgency, ticket size, and required specialization
- Auto-book consultation slots with reminder workflows and pre-consultation document requests
- Dormant client reactivation campaigns for missed filings, pending notices, and updated return opportunities
- Source-wise ROI tracking for referrals, ads, content, and partner channels
- Conversion funnel from enquiry → consultation → proposal → engagement → recurring retainer

---

## 43. NRI, Expat & Cross-Border Tax Desk

- Residential status determination engine with year-wise stay tracking
- DTAA relief workflows, foreign tax credit computation, and treaty position notes
- Foreign asset / foreign income schedule builder with country-wise mapping
- ESOP / RSU / foreign payroll / overseas secondment tax treatment workflows
- NRI property sale, lower TDS certificate, repatriation, and remittance checklists
- FEMA-linked tax impact prompts for high-value remittances and overseas investments
- Premium-case routing to cross-border specialists with turnaround SLAs and pricing bands

---

## 44. SME Tax CFO & Planning Retainers

- Monthly / quarterly tax review packs for SME founders, CFOs, and controllers
- Tax cash-flow forecasting with advance-tax, GST outflow, and TDS liability projections
- Board-ready tax memos, CFO dashboards, and variance explanations
- Entity-structure comparison (proprietorship / LLP / company) for tax efficiency planning
- Budget, Finance Act, and circular impact simulations for each client business
- Retainer packaging for monthly advisory subscriptions with scope, SLA, and escalation bands
- “Upcoming tax risk” alerts that trigger paid advisory conversations before deadlines hit
- Tax provisioning, deferred tax impact, and year-end closing advisory support for management teams
- Working-capital vs tax-outflow visibility to help SMEs plan cash usage more intelligently
- Group-entity and promoter-level tax view for businesses with multiple related entities

### Delivery Tasks & Completion Target

- **Completion Target:** 100%
- **Definition of Done:** Fully functional and production-ready, not demo-only
- End-to-end flow from lead / proposal → advisory workflow → document collection → partner review → client delivery → billing → renewal
- Partner approval matrix, maker-checker review, and audit trail for pricing, tax advice, and final deliverables
- Integration with CRM, Client Portal, Time Tracking, Billing, Document Management, and Analytics modules
- Standardized templates, calculators, board-pack outputs, and industry presets for fast rollout
- SLA tracking, escalation rules, renewal automation, and mobile notifications for every retainer client
- Production checklist coverage: access control, logging, monitoring, exports, backups, QA, and rollback readiness

---

## 45. Industry Vertical Tax Playbooks & Productized Services

- Ready-made tax playbooks for e-commerce, exporters, doctors, real estate, SaaS, creators, manufacturing, and hospitality
- Industry-specific onboarding checklists, data request templates, and compliance calendars
- Productized service bundles with fixed inclusions, turnaround SLAs, and pricing guardrails
- Benchmark ratios and typical risk libraries by industry to speed reviews and recommendations
- Vertical-wise win-rate, margin, and retention analytics to identify the best growth niches
- Cloneable proposal decks, engagement letters, and marketing one-pagers for each vertical
- Cross-sell triggers to move clients from filing-only to advisory, litigation, payroll, or CFO retainers

---

# PART H — AI-First & Future-Ready Modules

> Based on 2026 industry research: EY AI Tax Hub, Deloitte Tech Trends, ClearTax CTC, ICAI AI roadmap, Karbon State of AI Report

---

## 46. ESG Reporting & Sustainability Compliance

> **Pain point:** SEBI tightened ESG disclosure norms in 2026; CAs now play critical role in ESG-compliant reporting

- BRSR (Business Responsibility & Sustainability Reporting) preparation per SEBI format
- Carbon tax tracking & green incentive computation per Finance Act provisions
- ESG KPI dashboard (emissions, energy, water, waste, social metrics)
- Scope 1/2/3 emissions data collection workflow for listed company clients
- ESG audit workpaper templates with evidence linkage
- Sustainability tax contribution report for annual report disclosures
- Regulatory change tracker for SEBI ESG, EU CSRD (for multinationals), and India carbon credit markets

---

## 47. Virtual CFO Advisory Platform

> **Pain point:** 62%+ Indian CAs now offer advisory services beyond compliance; need technology platform to scale

- Monthly/quarterly financial health check templates with automated data pull
- CFO dashboard builder — real-time MIS, cash flow, working capital, receivables
- Board meeting pack generator with variance analysis and management commentary
- Scenario planning engine — what-if models for pricing, hiring, capex, tax regime changes
- Startup-to-SME advisory ladder with milestone-based deliverables
- Advisory retainer billing integration with time tracking and scope controls
- Client-facing financial literacy portal with simplified dashboards
- Tax cash-flow forecasting with advance tax, GST outflow, and TDS liability projections

---

## 48. AI-Powered E-Invoicing Compliance Hub

> **Pain point:** ₹2 crore threshold from Oct 2025, 30-day then 3-day reporting windows, ₹25K/invoice penalty, 2FA mandatory

- Real-time e-invoice generation via IRP API with instant IRN
- Pre-validation engine: GSTIN, HSN codes, invoice values checked before IRP submission
- 30-day / 3-day countdown tracker per invoice with escalation alerts
- Bulk e-invoice generation for high-volume clients (10,000+ invoices)
- Auto-retry on IRP rejection with error categorization and fix suggestions
- E-way bill auto-generation linked to e-invoice data
- 2FA token management for e-invoice portal access
- Credit/debit note e-invoice correlation and amendment tracking
- QR code verification tool for physical invoice audits
- Client-wise e-invoice readiness assessment (turnover threshold monitoring)

---

## 49. Intelligent Document Processing (IDP) Hub

> **Pain point:** 99%+ OCR accuracy now possible; CAs spend hours on manual data entry from Form 16, bank statements, invoices

- AI OCR extraction from Form 16/16A PDFs → structured data with field-level confidence scores
- Form 26AS / AIS / TIS auto-import with delta detection and mismatch highlighting
- Bank statement parser (all major Indian banks) → categorized transactions with GST/TDS tagging
- Invoice digitization with vendor name, amount, GST details, HSN extraction
- Rent agreement, property document, and capital gains deed OCR
- Batch processing: Drop folder of 500+ documents → auto-categorized, extracted, and routed
- Human-in-the-loop review queue for low-confidence extractions
- Integration with Dext, Nanonets, or custom vision models for India-specific document formats
- Client document upload via WhatsApp photo → auto-processed and filed

---

## 50. Regulatory Intelligence & Circular Tracker

> **Pain point:** CAs must track changes across IT Act, GST, Companies Act, RBI, SEBI, FEMA — circulars, notifications, press notes arrive daily

- Daily automated digest of circulars, notifications, and press notes from CBDT, CBIC, MCA, RBI, SEBI
- AI-powered impact analysis: "This circular affects 23 of your clients" with client list
- Section-wise amendment history with diff view (old text vs new text)
- Client-specific regulatory alert: "New 194T TDS rule impacts 8 of your partnership clients"
- Searchable knowledge base of all circulars since 2000 with semantic search
- Comparison tool: Show all changes to a specific section across Finance Acts
- Auto-update compliance calendar when new due dates are notified
- Integration with ICAI CA GPT and VIDUR AI for research augmentation

---

## 51. Practice Benchmarking & Growth Intelligence

> **Pain point:** CA firms lack data on how they compare to peers; no industry benchmarks for pricing, utilization, or growth

- Anonymous peer benchmarking: Compare your firm's billing rate, utilization, realization vs similar-sized firms
- Service-mix optimization: Which services generate highest margins, lowest churn?
- Pricing intelligence: Suggested fee ranges by service type, city tier, and client segment
- Growth score: Composite metric of client acquisition, retention, revenue growth, and NPS
- Staff productivity benchmarks: Billable hours, tasks completed, error rates vs industry median
- Client concentration risk alert: Flag when >20% revenue comes from single client
- Quarterly firm health report card with actionable recommendations

---

# PART I — Where AI Is Helping (2026 Industry Map)

> Sources: EY AI Tax Hub, Deloitte Tech Trends 2026, Karbon State of AI Report, ClearTax, ICAI AI Roadmap

| Area | AI Capability | Impact | Module |
|---|---|---|---|
| **GST Reconciliation** | AI matches 10,000+ invoices/min against GSTR-2B, flags mismatches | 70% reduction in manual reconciliation time | 2, 48 |
| **Document Processing** | OCR + NLP extracts Form 16, 26AS, bank statements at 99%+ accuracy | Eliminates manual data entry for 80% of documents | 49, 33 |
| **Fraud Detection** | 100% transaction analysis replaces sampling; Benford's Law, pattern recognition | Catches anomalies traditional audits miss entirely | 30, 17 |
| **AIS/TIS Mismatch** | Compares declared income vs AIS in real-time before filing | Prevents 143(1) intimations, demands, and scrutiny | 1, 17 |
| **Tax Advisory** | Scans client data for missed deductions, regime optimization, capital gains harvesting | Creates revenue from advisory that didn't exist before | 41, 44 |
| **Compliance Calendar** | Predicts deadline risks, auto-cascades related tasks, suggests resource allocation | Zero missed deadlines, staff overload prevention | 15, 38 |
| **Client Communication** | WhatsApp bots chase documents, send reminders, answer queries 24/7 | 50% reduction in staff time on follow-ups | 18, 42 |
| **Notice Management** | AI triages notices by section, urgency, risk; drafts preliminary responses | 3-5x faster response turnaround | 36, 31 |
| **Meeting Intelligence** | Auto-transcribes calls, extracts action items, creates tasks | No more lost follow-ups after client meetings | 17 |
| **Regulatory Tracking** | Daily circular digest with client-specific impact analysis | CAs always current; no more "missed that notification" | 50 |
| **Audit Analytics** | Complete journal entry testing, unusual amount/timing pattern detection | Evidence-based audit vs gut-feel sampling | 30, 5 |
| **RPA for Portals** | Bots handle bulk TRACES downloads, MCA prefills, challan fetches | Reclaim 2-3 hours/day lost to portal clicking | 17 |

---

# PART D — Criticisms Addressed

> Based on market research of CompuTax, ClearTax, TallyPrime, Saral, and CA community feedback

| Problem in Existing Tools | Our Solution |
|---|---|
| IE-only / browser compatibility issues | Modern web app, works on all browsers |
| Poor or no mobile support | Mobile-first native apps (iOS / Android) |
| Heavy manual data entry | AI / OCR automation, auto-fill |
| No client portal | Branded client portal with messaging |
| Fragmented communication (WhatsApp + email + calls) | Unified messaging (email + SMS + WhatsApp) |
| No workflow or deadline tracking | Full practice management with compliance calendar |
| Desktop-dependent / no cloud | Cloud-native architecture |
| No time tracking or billable hours | Integrated time tracking linked to billing |
| Poor analytics / no dashboards | Real-time BI dashboards & custom reports |
| No API or third-party integrations | Open API + banking + govt portal integrations |
| No UDIN auto-generation | Built-in UDIN for all audit reports |
| Slow support during peak season | AI-powered self-help + priority support |
| Steep learning curve | Modern UI, contextual help, guided workflows |
| No multi-currency support | Full multi-currency for international clients |
| ClearTax: HSN rate bugs, JSON upload errors, unstable matching | Validated offline preparation with pre-submission checks |
| CompuTax: IE-dependent, slow, no customized reports | Modern Flutter UI, instant rendering, custom report builder |
| TallyPrime: Desktop-only, no real-time collaboration | Cloud-native with unlimited concurrent logins and presence |
| No advisory/upsell — compliance-only mindset | AI-powered advisory opportunity engine (Module 41) |
| Peak-season staff overload, no capacity visibility | AI workload balancer + seasonal load forecaster |
| Fragmented tool switching (10+ portals per day) | Unified portal connector hub with single sign-on |
| No fraud/anomaly detection in audits | AI 100% transaction analysis, Benford's Law, shell company detection |
| No ESG/sustainability reporting | ESG compliance metrics aligned with SEBI 2026 norms |
| Manual OTP/login for every govt portal | Agentic OTP manager with consent-based auto-capture |

---

# Summary Table

> **Completion analysis basis:** These percentages are **implementation coverage estimates from a full codebase audit (2026-03-11)**, not business-goal completion.
> - **60-70%**: Production-quality business logic (tax engines, calculators) + complete UI + mock data
> - **40-50%**: Full UI shells with Riverpod state, mock data, multiple tabs/widgets, but minimal business logic
> - **20-39%**: Dedicated screens + models exist, but missing computation engines and integrations
> - **10-19%**: Skeleton UI only — screens + basic models, no business logic
> - **0-9%**: Roadmap-only or infrastructure hints only

| # | Module | Purpose | Done | What Exists | What's Missing for 100% |
|---|---|---|---|---|---|
| Core | Platform Core | Dashboard, client base, navigation shell | **20%** | Adaptive scaffold, GoRouter, 5-tab nav, theme system, cross-module KPI aggregation, compliance deadline widget, activity feed, real derived stats from ITR/GST/TDS providers | Auth, RBAC, MFA, audit trail, offline sync, push notifications, unified client DB, e-payment, email/SMS, banking API, encryption |
| 1 | Income Tax | ITR filing, e-returns, 26AS, advance tax, ITR-U | **15%** | Screen, 3 models (ItrClient/ItrType/FilingStatus), 10 mock clients, filing detail sheet, AY filter, ITR type filter chips, search, new filing sheet, summary cards (Total/Filed/Pending/Overdue) | Tax computation (lives in filing module), ITD portal API, Form 26AS import, AIS reconciliation, e-filing upload, advance tax calc, Section 89(1), ITR-U, UDIN |
| 2 | GST | GSTR-1/3B/9, ITC, reconciliation, e-invoicing | **20%** | Screen (503 lines), tabbed GSTR interface, **ITC reconciliation model** (GSTR-2A vs books matching), 8 recon records, client detail sheet with Returns + ITC Recon tabs, compliance score ring | GSTR-1/3B/9 return generation, GSTN API, e-invoice IRP integration, late fee calc, interest computation, ITC eligibility engine, Tally import |
| 3 | TDS/TCS | 24Q/26Q/27Q/27EQ, Form 16/16A/15G/26QB | **18%** | Screen, **TdsChallan model** (12 records, sections 192/194A/194C/194J/195), **TdsSectionSummary** (6 sections with compliance %), deductor detail sheet with Challans + Sections + Returns tabs | TDS calculation engine, FVU generation, Form 16/16A, TRACES API, bulk PAN verification, late filing fees, Section 194T |
| 4 | TDS.AI | AI-assisted TDS from accounting software | **0%** | No code exists | Entire module: AI extraction, section detection, rate application, form generation |
| 5 | Balance Sheet & Audit | Financials, Form 3CD/29B, cash flow | **35%** | Screen (705 lines), 5 models, **`FinancialRatioCalculator`** (11 ratios: CR, QR, gross/net/EBITDA margin, ROE, ROA, D/E, interest coverage, debtor/creditor/inventory days), **`DepreciationCalculator`** (WDV, IT Act rates, half-year convention), `FinancialRatioSnapshot` model (8 clients), Ratios tab with color-coded benchmarks, `DepreciationScheduleWidget` | Schedule III engine, cash flow generator, Tally import, Form 3CD/29B filing, audit report templates, Clause-by-Clause AI Validation |
| 6 | Assessment Checker | Verify IT order calculations & interest | **25%** | Screen, 2 models, interest calculation model (234B/C/D, 220(2), 244A) with variance tracking, detail sheet with demand vs refund card + tax computation breakdown + interest rows | Automated order verification (143(1)/143(3)/147), order data import, e-assessment portal API, customizable reports |
| 7 | MCA/ROC | Company filings, Companies Act 2013 | **20%** | Screen, 2 models (Company, McaFiling with 9 form types), company + filing tiles, overdue tracking, deadline banner | MCA portal API, e-form generation, DSC registration, resolution templates, CIN/DIN import |
| 8 | XBRL | XBRL tagging & MCA filing | **10%** | Screen, 2 models (XbrlFiling, XbrlElement), element + filing tiles | Color-coded input builder, CIN auto-populate, tag generator, XBRL file generation, MCA filing API |
| 9 | CMA | Financial projections, bank loan data | **30%** | Screen, 2 models (CmaReport, LoanCalculator with AmortizationEntry), **loan calculator** (EMI, amortization schedule), NPV/IRR sheet UI, report list | CMA data auto-preparation, comparative statement, MPBF calculation, Fund Flow, broken period |
| 10 | Payroll | Salary, PF/ESI, Form 16, 115BAC | **40%** | Screen (628 lines), 3 models, **`SalaryCalculator`** (PF 12% capped ₹15K, ESI 0.75%/3.25% ≤₹21K, PT Maharashtra slabs, TDS Section 192 new regime), `PayslipDetailSheet` (Earnings/Deductions/Net Pay/CTC), `PayrollSummaryWidget` | Salary package customization, Excel import, attendance, leave register, PF/ESI challan, EPFO API, Form 16, full & final settlement |
| 11 | Document Mgmt | Client document storage & cloud access | **15%** | Screen, 2 models (Document, DocumentFolder), folder + document tiles | Cloud storage backend, file upload/download/share, print/email, client portal access, search, mobile access |
| 12 | Staff Monitor | Remote monitoring, screen recording | **12%** | Screen, 3 models (SecurityAlert, ActivityLog, AccessRestriction), 3 widgets, mock data | Screen capture, website restrictions, recording, browsing logs, real-time alerts, multi-branch |
| 13 | Cloud/Remote | Browser-based access, cloud backup | **0%** | No code exists | Cloud infrastructure, backup system, remote access, session management |
| 14 | Billing | GST invoicing & billing | **35%** | Screen, 3 models (Invoice, PaymentReceipt, PaymentRecord), invoice detail sheet, new invoice form, payment tracking, aging summary (0-30/31-60/61-90/90+), search | GST-compliant invoicing (GSTIN/HSN fields), recurring invoices, payment collection API, time-tracking link |
| **15** | **Practice Mgmt** | **Workflow, tasks, deadlines, compliance calendar** | **35%** | Screen + Kanban, 3 models (Task/Status/Priority), filtered providers, swipe-to-complete, task detail modal, isOverdue/daysRemaining computed | 70+ templates, task dependencies, cascading deadlines, AI Workload Balancer, Smart Dependency Triggers, recurring auto-creation |
| **16** | **CRM** | **Client relationships, profitability, engagement** | **40%** | Screen, 10 files (2,947 lines), **`ClientHealthScore`** model (15 clients, Healthy/Attention/Critical grades), `ClientHealthCard` with score circle, `EditClientSheet` (Indian states dropdown, validation), real Quick Actions (mailto/tel), client detail wired to edit | Profitability analysis, engagement letters, fee proposals, referral tracking, risk assessment |
| **17** | **AI & Automation** | **OCR, reconciliation, anomaly detection, CA GPT** | **15%** | Screen, 12 files (4,586 lines), 3 models (Scan/Reconciliation/Anomaly), **live investor demo** (OCR step-by-step, recon counter 0→1247, anomaly typewriter), simulation providers | Real OCR/ML engine, bank reconciliation API, AI meeting transcription, RPA bots, CA GPT, 100% transaction analysis, CTC, Notice Analyzer |
| **18** | **Client Portal** | **Secure portal, messaging, WhatsApp, e-sign** | **40%** | Screen, 13 files (2,969 lines), 4 models, 4 tabs (Messages/Docs/Queries/Notifications), message bubbles, query tracking, document sharing | WhatsApp API, e-signature, payment collection, NPS surveys, AI chatbot, Magic Links, bulk reminders |
| **19** | **Analytics / BI** | **Dashboards, KPIs, custom reports, ESG** | **50%** | Screen, 11 files (3,087 lines), **12 firm-level KPIs with trends**, period filtering (month/quarter/year), revenue by service, receivables aging, growth opportunities, client health visualization | Custom report builder, peer benchmarking, churn prediction, ESG metrics, Seasonal Load Forecaster, Revenue per Hour Heatmap |
| **20** | **Time Tracking** | **Billable hours, task-to-invoice, realization** | **50%** | Screen, 10 files (2,945 lines), **`ActiveTimerNotifier`** (real `Timer.periodic` start/pause/resume/stop, HH:MM:SS, live ₹ billable amount), `RealizationCalculator` (utilization %, effective rate), `TimeEntryToInvoiceSheet` (grouped by client, GST ChoiceChip), `StartTimerSheet` | Budget vs actual, recurring invoices, revenue recognition, cost-to-serve, billing capacity |
| **21** | **Firm Operations** | **Staff KPIs, CPE, SOPs, capacity planning** | **25%** | Screen, 8 files (1,888 lines), 3 models (StaffMember/StaffKpi/KnowledgeArticle), staff cards with metrics, KPI summary tiles | CPE tracking, skill matrix, capacity planner, workpaper management, performance reviews, multi-branch, Articled Assistant Tracker |
| **22** | **Client Onboarding** | **KYC automation, CKYC, engagement letters** | **30%** | Screen, 8 files (1,976 lines), 3 models (KycRecord/DocumentExpiry/OnboardingChecklist), expiry alerts, KYC status cards, checklist progress bar | CKYC API, Aadhaar/PAN verification, e-sign, digital vault, data classification |
| **23** | **FEMA / RBI** | **FEMA forms, FDI tracking, RBI compliance** | **20%** | Screen, 6 files (1,345 lines), 2 models (FemaFiling/FdiTransaction), filing + transaction tiles | RBI API, AD bank integration, FEMA form filing (FC-GPR/FC-TRS/APR/FLA), penalty calc, export-import |
| **24** | **SEBI** | **Capital market disclosures, BSE/NSE filing** | **25%** | Screen, 6 files (1,428 lines), 2 models (SebiDisclosure/MaterialEvent), disclosure + event tiles | BSE/NSE API, 45/60-day deadline engine, related party transactions, secretarial auditor monitoring |
| **25** | **Transfer Pricing** | **TP docs, Form 3CEB, ALP benchmarking, APA** | **20%** | Screen, 6 files (1,478 lines), 2 models (TpFiling/TpStudy), filing + study tiles | Form 3CEB filing, ALP benchmarking tools, safe harbour (₹3B), APA/MAP management, DTAA monitoring |
| **26** | **Crypto / VDA Tax** | **VDA schedule, 30% tax, TDS 194S, NFT** | **70%** | Screen, 13 files (3,164 lines), **`VdaTaxCalculator`** (30% flat tax Section 115BBH + 4% cess, TDS 194S 1% on >₹50K/₹10K, per-transaction gain computation, loss disallowance validation, Schedule VDA aggregation), `VdaScheduleSheet`, `Tds194sWidget`, 15 mock transactions across 5 clients | VDA Schedule auto-population in ITR, exchange-wise TDS reconciliation, multi-currency |
| **27** | **Startup Compliance** | **DPIIT, 80-IAC, cap table, angel tax** | **65%** | Screen, 8 files (2,833 lines), **`StartupCalculator`** (DPIIT eligibility ≤₹100Cr/≤10yrs, Section 80-IAC 100% deduction 3/10 years, angel tax exemption Sec 56(2)(viib), carry-forward loss relaxed Sec 79), `StartupProfile` with cap table fields, startup detail sheet | Cap table management UI, compliance calendar, ₹100Cr monitoring alerts, DPIIT API |
| **28** | **LLP Compliance** | **Form 11/8, audit threshold, ITR-5** | **60%** | Screen, 8 files (2,973 lines), **`LlpPenaltyCalculator`** (Form 11/8 late filing ₹100/day, audit threshold ₹40L turnover/₹25L capital, ITR-5 due dates, strike-off risk 3+ years, designated partner penalty ₹10K-₹100K), `LlpFilingRecord` with computed penalties | MCA API, Form 11/8 filing integration, designated partner tracking UI |
| **29** | **MSME Compliance** | **45-day payment, Form MSME-1, 43B(h)** | **60%** | Screen, 9 files (3,028 lines), **`MsmePayment`** (45-day deadline tracking, penalty interest 18.75%, within-45-days flag), Section 43B(h) deduction forfeit alerts, payment aging visualization, vendor tiles, summary card | Form MSME-1 auto-generation, MSME registration verification, automated 45-day alert engine |
| **30** | **Advanced Audits** | **Statutory, internal, stock, cost, forensic + AI** | **20%** | Screen, 8 files (2,010 lines), 3 models (AuditEngagement/AuditChecklist/AuditFinding), engagement cards, finding tiles with severity, checklist items | Audit-type workflows (statutory/internal/stock/cost/forensic), risk assessment, Benford's Law, shell company detection, fraud analytics |
| **31** | **Faceless Assessment** | **NFAC, virtual hearings, ITR-U, e-proceedings** | **25%** | Screen, 8 files (2,032 lines), 3 models (HearingSchedule/ItrUFiling/EProceeding), hearing + ITR-U + e-proceeding tiles, penalty reference (25%/50%/60%/70%) | E-assessment portal API, video conferencing, ITR-U 4-year window calc, penalty automation, digital notice workflow |
| **32** | **Regulatory Trust & Security** | **GSP/eRI readiness, SOC2/ISO, VAPT, privacy** | **15%** | Screen, 6 files (1,069 lines), 2 models (VaptScan/SecurityControl), 8 mock controls, 4 VAPT scans | Real compliance tracking, GSP/ASP/eRI workflow, SOC2/ISO tracking, VAPT scheduling, encryption enforcement, privacy registry |
| **33** | **Data Pipelines & Broker** | **Bulk JSON, Form 16/26AS, broker feeds** | **10%** | Screen, 6 files (1,127 lines), 2 models (DataPipeline/BrokerFeed), pipeline + feed tiles | Real API connectors (Zerodha/CAMS/KFintech), file ingestion engine, delta detection, Tally/Zoho/SAP mapping, webhooks |
| **34** | **Collaboration & Mobility** | **Concurrent logins, bilingual mobile, guest access** | **15%** | Screen, 6 files (1,068 lines), 2 models (UserSession/GuestLink), session + guest link tiles | Real presence system, field locking, conflict resolution, offline sync, i18n (9 languages), push notifications |
| **35** | **Ecosystem Integrations** | **Marketplace, GSTN/MCA APIs, webhooks** | **15%** | Screen, 6 files (1,030 lines), 2 models (IntegrationConnector/MarketplaceApp), connector + app tiles, health status | Real API integrations (GSTN/MCA/TRACES/RBI), GraphQL/REST layer, webhook system, marketplace SDK, sandbox |
| **36** | **Notice Resolution Center** | **Notice triage, hearings, appeals, precedent reuse** | **40%** | Full screen at `/notice-resolution`: 7 notice types, 5 severity levels, 8 mock notices (Reliance/TCS/Infosys/Bajaj), severity filter chips, Active/Resolved tabs, summary cards, `NoticeCase`+`NoticeReply` models, days-left calculation | Real e-notice API, AI response drafting, appeal tracker, hearing scheduler, precedent DB |
| **37** | **DSC & Credential Vault** | **DSC expiry, masked credentials, consent OTP** | **40%** | Full screen at `/dsc-vault`: 8 mock DSC certs (eMudhra/Sify/NSDL), 6 portal credentials (IT/GST/MCA21/TRACES), status filter chips, 4 summary cards, masked userID, `isExpiringSoon` 30-day window | Real token detection, consent OTP flow, auto-renewal alerts, credential encryption at rest |
| **38** | **Renewal & Expiry Control** | **Retainers, renewals, compliance expiry heatmaps** | **40%** | Full screen at `/renewal-expiry`: 10 mock items (DSC/GST reg/trademark/shop act/ISO), 6 retainer contracts, days-to-expiry badges, Renewals + Retainers tabs | Automated reminders engine, heatmap calendar, SLA countdown alerts, auto-renewal workflows |
| **39** | **Fee Leakage & Scope Control** | **Scope creep, margins, recovery, revised retainers** | **40%** | Full screen at `/fee-leakage`: 8 engagements, leakage % calculation (Agreed-Billed)/Agreed, utilization bar, over-scope detection, Engagements + Scope Items tabs | Real billing API, scope diff engine, margin tracking, automated recovery workflow |
| **40** | **Knowledge Engine** | **Precedents, drafting, law updates, SOP generation** | **40%** | Full screen at `/knowledge-engine`: 8 articles (CBDT circulars, GST rulings, ITAT precedents), 5 SOPs with step previews, category filter chips, Articles + SOPs tabs | Semantic search, AI drafting assist, law update scraper, precedent DB |
| **41** | **Tax Advisory Opportunity Engine** | **Upsell detection, tax health scoring, proposals** | **40%** | Full screen at `/tax-advisory`: 10 opportunity types, 8 opportunities (HRA ₹12L, regime switch ₹85K, capital gains ₹3.2L, NRI, Sec 80-IAC), 5 proposals, pipeline summary | ML scoring engine, real client data signals, proposal PDF generator, CRM integration |
| **42** | **Lead Funnel & Campaigns** | **Lead capture, reactivation, consultation conversion** | **40%** | Full screen at `/lead-funnel`: 7 stages, 10 leads (Indian clients), 5 campaigns (ITR Drive/GST Compliance/NRI), pipeline value, stage filter, Leads + Campaigns tabs | WhatsApp API, consultation booking, ROI analytics, dormant reactivation |
| **43** | **NRI & Cross-Border Tax** | **DTAA, FTC, foreign assets, NRI workflows** | **40%** | Full screen at `/nri-tax`: 8 NRI clients (USA/UK/UAE/Canada/Singapore/Australia/Germany), 10 foreign assets, flag emoji, DTAA badge, Schedule FA indicator, NRI Clients + Foreign Assets tabs | DTAA treaty engine, FTC computation, residential status calculator, Form 67 generator |
| **44** | **SME Tax CFO Retainers** | **Forecasting, board memos, advisory subscriptions** | **40%** | Full screen at `/sme-cfo`: 8 retainers (₹8K-₹35K/month), 10 deliverables, custom health ring `CustomPaint`, retainer value card, `CfoRetainer`+`CfoDeliverable` models | Real CFO dashboard, scenario planner, retainer billing, board pack generator |
| **45** | **Industry Vertical Playbooks** | **Sector playbooks, productized services, niche growth** | **40%** | Full screen at `/industry-playbooks`: 10 verticals (e-commerce, exporters, doctors, real estate, SaaS, creators, manufacturing, hospitality), 8 service bundles, `PlaybookCard` with margin bar, `ServiceBundleTile` | Vertical templates, bundle pricing engine, win-rate analytics, proposal deck generator |
| **46** | **ESG Reporting** | **BRSR, carbon tax, sustainability metrics per SEBI 2026** | **40%** | Full screen at `/esg-reporting`: 8 disclosures (TCS/Infosys/Reliance/HDFC), 10 carbon metrics (Scope 1/2/3), E/S/G score bars, SEBI category badges, Disclosures + Carbon Metrics tabs | BRSR builder, SEBI filing engine, real carbon calculator, amendment diff viewer |
| **47** | **Virtual CFO Platform** | **MIS dashboards, scenario planning, board packs** | **40%** | Full screen at `/virtual-cfo`: 8 MIS reports (P&L/Cash Flow/Balance Sheet), 10 scenarios (Best/Base/Worst/Expansion/Cost), EBITDA progress bars, MIS Reports + Scenarios tabs | Real-time MIS engine, board pack generator, scenario engine, retainer billing |
| **48** | **E-Invoicing Compliance Hub** | **IRP API, 30-day/3-day window, bulk generation** | **40%** | Full screen at `/einvoicing`: 12 e-invoices (3 overdue, ₹75K penalty), 6 IRN batches, 30-day/3-day window badges, countdown coloring, E-Invoices + Batches tabs | IRP API integration, countdown timer, bulk IRN generator, QR code engine |
| **49** | **Intelligent Document Processing** | **AI OCR for Form 16/26AS/bank statements, 99%+ accuracy** | **40%** | Full screen at `/idp`: 12 document jobs (Form 16/26AS/Bank Statement/AIS/P&L), 15 extracted fields, confidence indicator, needs-review chips, Document Jobs + Extracted Fields tabs | Real OCR engine, batch processor, human-in-loop review queue, field correction workflow |
| **50** | **Regulatory Intelligence** | **Daily circular digest, client-impact analysis, section tracker** | **40%** | Full screen at `/regulatory-intelligence`: 12 circulars (CBDT/GSTN/MCA/RBI/SEBI/ICAI/EPFO), 12 client impact alerts, category filter (7 bodies), Circulars + Client Alerts tabs | Circular scraper, AI impact tagger, amendment diff viewer, auto-notify workflow |
| **51** | **Practice Benchmarking** | **Peer comparison, pricing intelligence, growth score** | **40%** | Full screen at `/practice-benchmarking`: 15 metrics (Financial/Operational/Client/Technology/Team), 6 growth scores (A+ to D), `CustomPainter` score ring, peer median comparison, `BenchmarkCard`+`GrowthScoreTile` | Anonymous peer DB, pricing engine, real growth score calculator, export reports |

---

## Filing Engine & Portal Integration (Modules 52–62)

> **The core CA workflow** — this is what CAs actually do every day: collect documents, fill forms, compute tax, file to government portals, track status, and notify clients. Without these modules, CADesk is a dashboard without a filing engine.

| # | Module | Purpose | Done | What Exists | What's Missing for 100% |
|---|---|---|---|---|---|
| **52** | **ITR Filing Engine** | **End-to-end Income Tax Return preparation & e-filing** | **30%** | **`TaxComputationEngine`** (FY 2025-26: new regime 115BAC 7 slabs + old regime 4 slabs, surcharge tiers, 4% cess, rebate 87A both regimes, ₹75K/₹50K standard deduction), **`InterestComputationService`** (234A late filing 1%/mo, 234B advance tax shortfall, 234C installment deferment), **`Itr1JsonExportService`** (ITD-compliant JSON: CreationInfo, PartA_GEN1, ScheduleS/HP/OS/VIA, PartBTI/BTTI, Verification), 7-step ITR-1 wizard (PersonalInfo→Salary→HouseProperty→OtherSources→Deductions→TaxComputation→ReviewExport), 6 immutable ITR-1 models with copyWith, **ChapterViaDeductions** (80C/80CCD1B/80D/80E/80G/80TTA/80TTB with statutory caps), `FilingJob` model (18 fields incl. filingType/residentialStatus/taxRegime/priority/dueDate/fees), comprehensive new filing bottom sheet (3 sections: Client Info with PAN validation, Filing Details with regime/type/AY, Assignment with staff/priority/due date/fee), `liveTaxComputationProvider` (recomputes as user types), Filing Hub (urgent/in-progress/recent by AY), 4 mock jobs | ITR-2 through ITR-7 form engines, ITD e-filing portal API, Form 26AS/AIS import & reconciliation, e-verification flow (Aadhaar OTP/DSC/EVC), bulk filing queue, filing status tracker (143(1) polling), ITR-U updated return workflow, advance tax calendar |
| **53** | **GST Return Filing Engine** | **GSTR-1/3B/9/9C preparation, computation & filing** | **25%** | `GstReturn` model (11 fields: GSTIN, returnType 5 enum, period, taxableValue, IGST/CGST/SGST/cess, itcClaimed, totalTax getter), **`ItcReconciliation`** model (GSTR-2A vs books: matched/mismatched/missingInBooks/missingIn2A, differencePercent, status), GST screen with tabbed GSTR interface, client detail sheet with Returns + ITC Recon tabs, 8 mock returns | GSTR-1/3B/9/9C return builders, ITC eligibility engine (Section 17(5)), reverse charge handler, late fee calculator (₹50/day), interest computation (18% p.a.), GSTN API, e-invoice to GSTR-1 mapping, nil return quick-file, JSON/CSV export |
| **54** | **TDS Return Filing Engine** | **Form 24Q/26Q/27Q/27EQ preparation & FVU generation** | **20%** | `TdsReturn` model (11 fields: TAN, formType 4 enum, quarter, status), `TdsChallan` (12 mock records, sections 192/194A/194C/194J/195), `TdsSectionSummary` (6 sections with compliance %), TDS screen with form tabs + quarter/FY selectors, deductor detail sheet with Challans + Sections + Returns tabs | Deductee-wise data entry, section-rate auto-mapping, challan-deductee linking, FVU generation (.fvu), Form 16/16A generation, Form 15G/15H register, correction statements, TRACES API, PAN verification |
| **55** | **MCA/ROC Filing Engine** | **Company & LLP e-form preparation and MCA portal filing** | **20%** | `McaFiling` model (formType 9 enum: MGT-7/MGT-9/AOC-4/DIR-3/ADT-1/INC-22A/Form 8/11/MGT-14, status 5 enum, SRN, fees, penaltyAmount, isOverdue/hasPenalty getters), `Company` model, MCA screen with Companies/Filings tabs, overdue badge, deadline banner | E-form builder UIs (AOC-4, MGT-7, etc.), SRN tracking workflow, payment challan, DSC attachment, pre-fill from CIN, penalty calculator, resolution/minutes templates, MCA V3 API |
| **56** | **Portal Connector Hub** | **Unified API layer for all government portals** | **5%** | Infrastructure hints via DSC vault (Module 37) credential storage, portal credential model with masked display | Abstraction layer for ITD/GSTN/TRACES/MCA/EPFO portals, session management, OTP capture flow, rate limiting/retry, health monitor, audit logging, bulk operation queuing |
| **57** | **Post-Filing Tracker** | **Track filed returns through processing, refunds, demands** | **0%** | FilingJob has `acknowledgementNumber` and `eVerificationStatus` fields (schema only) | ITR processing state machine, refund status tracking, demand detection, GSTR/TDS/MCA status tracking, timeline view, automated refresh, push notifications |
| **58** | **Notice & Demand Management** | **Receive, classify, respond to government notices** | **10%** | Module 36 UI shell (8 mock notices, 7 types, severity filter, Active/Resolved tabs) provides partial overlap | Auto-fetch from ITD e-proceedings, notice classification (143(1)/143(2)/156/271), response templates, hearing tracker, adjournment builder, Section 154 generator, appeal workflow (CIT(A)→ITAT→HC), DIN verification |
| **59** | **Reconciliation Engine** | **Cross-portal data matching and mismatch resolution** | **15%** | `ItcReconciliation` model (GSTR-2A vs books matching with difference %), FilingJob status tracking infrastructure | 26AS vs books TDS recon, AIS vs ITR income recon, Form 16 vs 26AS three-way match, bank statement recon, PAN-level consolidated view, mismatch categorization, resolution suggestions, bulk recon |
| **60** | **DSC Signing & E-Verification** | **Digital signature workflow for all portal submissions** | **10%** | Module 37 DSC vault (8 certs with expiry tracking, token type enum: Class 2/3/USB/Cloud, `isExpiringSoon` 30-day window, portal credentials) | Token detection, document hash signing, e-verification (Aadhaar OTP/net banking/EVC), bulk signing queue, expiry pre-check, signing audit log, multi-signatory workflow |
| **61** | **Bulk Operations Center** | **Mass filing, bulk status check, batch processing** | **0%** | No code exists | Bulk ITR/GST/TDS filing queue, batch status refresh, progress dashboard, retry logic, Excel/CSV import, scheduled filing, client grouping |
| **62** | **Client Filing Dashboard** | **Client-facing view of all filings, status, and documents** | **15%** | Filing Hub aggregates across ITR/GST/TDS/MCA (13 mock items, 6 statuses), Module 18 Client Portal (Messages/Docs/Queries/Notifications tabs) | Per-client filing history timeline, real-time status badges, document download center, payment history, filing comparison YoY, WhatsApp/email preferences, self-service upload |
