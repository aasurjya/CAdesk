# CADesk Architecture & Automation Blueprint

> **Single source of truth** for the full system architecture.
> All implementation agents read this file to generate code without further instruction.
>
> **Last reviewed:** 2026-03-13 | **Status:** Draft v2

---

## Table of Contents

1. [System Overview](#1-system-overview)
2. [Backend — Go API Gateway](#2-backend--go-api-gateway)
3. [Database — Three-Tier Strategy](#3-database--three-tier-strategy)
4. [Auth, Security & Compliance](#4-auth-security--compliance)
5. [RPA Pipeline — Portal Automation](#5-rpa-pipeline--portal-automation)
6. [Hosting & Scaling](#6-hosting--scaling)
7. [Observability & Reliability](#7-observability--reliability)
8. [Flutter App Additions](#8-flutter-app-additions)
9. [CI/CD Pipelines](#9-cicd-pipelines)
10. [Automation Pipeline — Agent-Driven](#10-automation-pipeline--agent-driven)
11. [Implementation Phases](#11-implementation-phases)
12. [Repo Structure](#12-repo-structure)
13. [Constraints & Invariants](#13-constraints--invariants)
14. [Decision Log](#14-decision-log)

---

## 1. System Overview

**CADesk** — Complete practice management for Chartered Accountants (India).

![System Architecture](docs/architecture/01-system-overview.svg)

### Design Principles

| Principle | Implementation | Failure Mode Addressed |
|-----------|---------------|----------------------|
| **Offline-first** | Drift SQLite on device, sync engine with conflict resolution | Network loss, slow connections |
| **Immutable state** | `copyWith()` everywhere, Riverpod providers | Race conditions, stale UI |
| **Domain untouched** | Real impls added beside mocks, interfaces frozen | Regression risk during migration |
| **Zero secrets in app** | All credentials server-side (Supabase Vault) | App bundle reverse-engineering |
| **Scale horizontally** | Stateless Go API, Redis queue, worker pool | Traffic spikes during filing season |
| **Edge-first** | Cloudflare CDN + R2 = global low-latency | Indian ISP latency variance |
| **Graceful degradation** | Circuit breakers per portal, offline fallback, retry with backoff | Portal outages (GSTN during filing) |
| **Idempotent operations** | Idempotency keys on all mutations, deduplication at queue level | Network retries, duplicate submissions |

### 74 Feature Modules

All have domain models + mock repositories. Real implementations wire to Go backend.

<details>
<summary>Full module list</summary>

accounts, advanced_audit, ai_automation, analytics, assessment, audit, billing,
bulk_operations, ca_gpt, client_portal, clients, cma, collaboration, compliance,
crypto_vda, dashboard, data_pipelines, documents, dsc_vault, e_verification,
ecosystem, einvoicing, esg_reporting, faceless_assessment, fee_leakage, fema,
filing, firm_operations, gst, gstn_api, idp, income_tax, industry_playbooks,
knowledge_engine, lead_funnel, litigation, llp_compliance, llp, mca_api, mca,
more, msme, notice_resolution, nri_tax, ocr, onboarding, payroll, platform,
portal_connector, portal_export, portal_parser, post_filing, practice_benchmarking,
practice, reconciliation, regulatory_intelligence, regulatory_trust, renewal_expiry,
roadmap_modules, rpa, sebi, settings, sme_cfo, staff_monitoring, startup_compliance,
startup, tasks, tax_advisory, tds, time_tracking, today, traces, transfer_pricing,
vda, virtual_cfo, xbrl
</details>

---

## 2. Backend — Go API Gateway

### Why Go

| Factor | Go | Node.js (alternative) |
|--------|----|-----------------------|
| Cold start | <50ms | 2-5s |
| Concurrency | Goroutines (10K+ concurrent) | Event loop (single-threaded) |
| Memory | ~20MB baseline | ~80MB baseline |
| Binary | Single static binary, 15MB Docker | node_modules, 200MB+ image |
| Type safety | Compile-time | Runtime (even with TS) |

### Stack

| Component | Choice | Why |
|-----------|--------|-----|
| Router | `chi` v5 | Lightweight, stdlib-compatible, middleware composable |
| HTTP client | `net/http` + `retryablehttp` | Portal calls need retries + exponential backoff |
| Circuit breaker | `sony/gobreaker` | Per-portal circuit breakers (GSTN goes down during filing season) |
| Logging | `slog` (stdlib) | Structured, zero-alloc, JSON output |
| Tracing | OpenTelemetry SDK | Distributed traces across Go → RPA → Supabase |
| Metrics | Prometheus client | Request latency, error rates, queue depth, portal health |
| Config | `envconfig` | 12-factor, no config files in container |
| Validation | `go-playground/validator` | Struct tag validation |
| Testing | `testify` + `httptest` | Table-driven tests, mock portals |

### API Design

```
Base URL: https://api.cadesk.app/v1

Authentication:  Bearer <supabase-jwt>
Idempotency:     Idempotency-Key header (required on all POST/PUT/PATCH)
Rate limiting:   Per-firm + per-portal (see below)
Pagination:      Cursor-based (not offset) — stable under concurrent writes

Response envelope:
  {
    "data": <T>,
    "error": null,
    "meta": {
      "cursor": "eyJ...",
      "has_more": true,
      "total": 1250           // only on explicit ?count=true
    }
  }
```

### API Versioning

- **URL-based:** `/v1/`, `/v2/` — major breaking changes only
- **Deprecation:** Old version supported for 6 months after new version ships
- **No breaking changes within a version** — additive only (new fields, new endpoints)

### Rate Limiting (Multi-Level)

| Level | Limit | Key | Purpose |
|-------|-------|-----|---------|
| Global per firm | 200 req/min | `firm_id` | Prevent abuse |
| GSTN | 30 req/min | `firm_id:gstn` | GSTN's own limit is ~60/min |
| TRACES | 10 req/min | `firm_id:traces` | TRACES is slow, aggressive = IP ban |
| ITD | 20 req/min | `firm_id:itd` | ITD rate limits strict during filing |
| MCA | 30 req/min | `firm_id:mca` | MCA is more lenient |
| Bulk operations | 5 req/min | `firm_id:bulk` | Bulk jobs are expensive |

Algorithm: Redis sliding window (not fixed window — avoids burst at boundaries).

### Endpoint Groups

```
/v1/auth/                  # Token refresh, session management
/v1/clients/               # CRUD, search, bulk import
/v1/income-tax/            # ITR filing, returns, demands
/v1/gst/                   # GSTR-1/3B, ITC reconciliation
/v1/tds/                   # TDS returns, challans, Form 16
/v1/mca/                   # Company filings, compliance
/v1/portals/{portal}/      # Generic portal proxy (GSTN, MCA, ITD, TRACES, EPFO)
/v1/jobs/                  # Job queue CRUD, status polling
/v1/jobs/{id}/result       # Download job output (PDF/FVU from R2)
/v1/documents/             # Upload, list, download (R2-backed)
/v1/billing/               # Invoices, payments, receipts
/v1/admin/health           # Health check (public)
/v1/admin/ready            # Readiness check (dependencies OK)
/v1/admin/metrics          # Prometheus metrics (internal only)
```

### Portal Proxy Architecture

```
Flutter ──► Go API ──► Portal API (GSTN, MCA)     [direct REST]
Flutter ──► Go API ──► Redis Queue ──► Playwright  [RPA for ITD, TRACES, EPFO]
```

Portal credentials: **Supabase Vault** (AES-256), fetched at request time, never cached beyond request lifecycle. Never logged — `slog` has redaction middleware for `sensitive`-tagged fields.

### Circuit Breaker per Portal

```
CLOSED (normal) ──► OPEN (5 failures in 60s) ──► HALF-OPEN (30s cooldown)
                                                       │
                                              success → CLOSED
                                              failure → OPEN

When OPEN:
  → Return cached last-known-good data if available
  → Return 503 with retry-after header
  → Flutter shows "Portal temporarily unavailable" + local data fallback
```

**Why this matters:** GSTN goes down for hours during filing deadlines (31 Mar, 31 Jul, 31 Dec). Without circuit breakers, the app hangs and users lose trust.

### Directory Structure

```
/CA-app-backend/
  cmd/server/main.go
  internal/
    api/
      router.go
      middleware/           # auth, ratelimit, idempotency, logging, recovery, cors
    portals/
      gstn/client.go       # + circuit breaker
      mca/client.go        # + circuit breaker
      itd/dispatcher.go    # → RPA queue
      traces/dispatcher.go
      epfo/dispatcher.go
      health.go            # periodic portal probe
    jobs/
      queue.go             # Redis-backed priority queue
      scheduler.go         # cron-triggered (GSTR-2B, 26AS)
      worker_pool.go
      idempotency.go       # job deduplication
      dlq.go               # dead letter queue
    rpa/
      dispatcher.go
      results.go
      healthcheck.go       # DOM checksum validator
    storage/r2.go          # S3-compatible Cloudflare R2
    vault/credentials.go   # Supabase Vault
    observability/         # OpenTelemetry, Prometheus, slog
    domain/                # shared types, error codes
  pkg/
    supabase/client.go
    redis/client.go
  Dockerfile
  fly.toml
  go.mod
```

---

## 3. Database — Three-Tier Strategy

![Data Flow](docs/architecture/02-data-flow.svg)

### Tier 1: Drift (SQLite) — On-Device

| Property | Value |
|----------|-------|
| Latency | <1ms (local disk) |
| Availability | 100% (always local) |
| Encryption | SQLCipher (AES-256) |
| Schema | Drift Table classes (type-safe, generated) |
| Purpose | Offline-first reads, sync queue for writes |

### Tier 2: Supabase PostgreSQL — Cloud

| Property | Value |
|----------|-------|
| Region | Mumbai (ap-south-1) |
| Latency | 10-50ms |
| Multi-tenancy | `firm_id` RLS on every table |
| Realtime | WebSocket push for job status |
| Backup | PITR (7 days) + daily pg_dump (30 days) |
| Search | GIN `tsvector` indexes |

### Tier 3: Upstash Redis — Cache/Queue

| Property | Value |
|----------|-------|
| Latency | <5ms (HTTP API, Mumbai) |
| Persistence | **None** — ephemeral by design |
| Failure mode | Rebuild from PG (slower but correct) |
| Scaling | Serverless, per-command billing |

**Invariant:** Redis is NEVER the source of truth. All durable state lives in Supabase PG. If Redis dies, the system is slower but correct.

### RLS Policies

```sql
-- Firm isolation (every table, no exceptions)
CREATE POLICY "firm_isolation" ON <table>
  FOR ALL
  USING (firm_id = (auth.jwt() ->> 'firm_id')::uuid);

-- Role-based (sensitive tables: billing, payroll, staff_monitoring)
CREATE POLICY "role_access" ON <sensitive_table>
  FOR SELECT
  USING (
    firm_id = (auth.jwt() ->> 'firm_id')::uuid
    AND (auth.jwt() ->> 'role')::text = ANY(ARRAY['admin', 'partner', 'manager'])
  );

-- Audit trigger (every table)
CREATE TRIGGER audit_<table>
  BEFORE INSERT OR UPDATE ON <table>
  FOR EACH ROW EXECUTE FUNCTION set_audit_columns();
```

### Indexing Strategy

```sql
-- Baseline (every table):
CREATE INDEX idx_<table>_firm_id ON <table>(firm_id);
CREATE INDEX idx_<table>_created ON <table>(firm_id, created_at DESC);

-- Search:
CREATE INDEX idx_clients_search ON clients
  USING gin(to_tsvector('english', name || ' ' || pan || ' ' || email));

-- Hot queries (partial indexes):
CREATE INDEX idx_active_tasks ON tasks(firm_id, assigned_to, due_date)
  WHERE status IN ('pending', 'in_progress');
CREATE INDEX idx_pending_invoices ON invoices(firm_id, due_date)
  WHERE status = 'pending';
```

### Offline Sync — Server-Wins with Conflict Notification

**Why server-wins:** Financial data needs a single canonical source. Two CAs editing the same ITR is rare (assigned per staff). Merge conflicts in financial figures = dangerous.

```
1. Each Drift row: local_version, server_version, dirty flag
2. On save: increment local_version, set dirty = true
3. On connectivity: push dirty rows to server
4. Server compares server_version:
   - Match → accept, increment, return OK
   - Mismatch → reject with current server version
5. On reject: overwrite local, notify user:
   "Your changes to X were overwritten because [other user] saved a newer version"
6. Conflict log in sync_conflicts table for user review
```

### Realtime Connection Management

Supabase Realtime limit: ~500 concurrent on Pro. Strategy:
- Subscribe only to user's own firm's job updates (filtered channel)
- Unsubscribe when leaving screen
- Fallback to polling (`/v1/jobs?status=pending` every 10s) if WebSocket fails

### Redis Key Structure

```
session:{portal}:{client_id}       → portal token (TTL: 15min)
job:{job_id}                       → job state (TTL: 24h)
rate:{firm_id}:{scope}             → sliding window (TTL: 60s)
rpa:queue                          → sorted set (priority)
idem:{idempotency_key}             → response cache (TTL: 24h)
cb:{portal}                        → circuit breaker state
portal:health:{portal}             → last probe result (TTL: 5min)
```

---

## 4. Auth, Security & Compliance

![Auth & RBAC](docs/architecture/03-auth-rbac.svg)

### Token Management

| Token | Storage | TTL | Refresh |
|-------|---------|-----|---------|
| Access JWT | `flutter_secure_storage` | 1 hour | Auto via `supabase_flutter` |
| Refresh token | `flutter_secure_storage` | 30 days | On expiry |
| Portal session | Upstash Redis (server) | 15 min | On portal API call |

### JWT Claims

```json
{
  "sub": "user-uuid",
  "firm_id": "firm-uuid",
  "role": "manager",
  "email": "ca@firm.in"
}
```

### RBAC

| Role | Scope | Can See | Can Modify | Billing |
|------|-------|---------|-----------|---------|
| `owner` | Firm-wide | Everything | Everything + settings | Full |
| `partner` | Firm-wide | Everything | Assigned clients | Full |
| `manager` | Team | Team's clients | Assigned clients | View |
| `staff` | Individual | Assigned only | Assigned work | No |
| `intern` | Individual | Assigned tasks | Submit for review | No |

Enforced at **3 levels**: Go middleware + Supabase RLS + Flutter GoRouter guards.

### Security Layers

1. **Transport:** TLS 1.3 everywhere
2. **Auth:** JWT with `firm_id` + `role`, validated in Go middleware
3. **Authorization:** RLS + role checks at API and DB layers
4. **Idempotency:** Required header on all mutations — prevents duplicate filings
5. **Secrets:** Supabase Vault for portal creds, env vars for service secrets
6. **Validation:** Go struct tags, Dart model constructors
7. **Rate limiting:** Multi-level Redis sliding window
8. **Audit trail:** All operations logged (timestamp + user + action + IP)
9. **Webhook verification:** HMAC-SHA256 on incoming webhooks
10. **Log redaction:** PAN, Aadhaar, passwords stripped from all logs
11. **Local encryption:** SQLCipher for SQLite at rest
12. **CSP headers:** Content Security Policy on Flutter Web

### India DPDP Act 2023 Compliance

| Requirement | Implementation |
|-------------|---------------|
| Consent | Explicit consent during onboarding → `consent_log` table |
| Purpose limitation | Portal creds used only for declared filing purposes |
| Data minimization | Only collect fields needed per service |
| Right to erasure | `DELETE /v1/clients/{id}/data` → cascade all records + R2 |
| Data retention | Financial records: 8 years (Indian tax law). Auto-archive. |
| Breach notification | Audit log + alerting. 72-hour window. |
| Cross-border | All data in ap-south-1. R2 geo-restricted to India. |
| Data export | `GET /v1/clients/{id}/export` → ZIP of all data |

---

## 5. RPA Pipeline — Portal Automation

![RPA Pipeline](docs/architecture/04-rpa-pipeline.svg)

### Job Lifecycle

| Step | Component | Action |
|------|-----------|--------|
| 1 | Flutter | POST `/v1/jobs` + Idempotency-Key |
| 2 | Go API | Validate JWT, check circuit breaker, fetch creds from Vault |
| 3 | Redis | ZADD to priority sorted set (`rpa:queue`) |
| 4 | Playwright | Pop job, checksum DOM selectors, launch browser, execute |
| 5 | Storage | Upload PDF → R2, update jobs table (Supabase) |
| 6 | Realtime | WebSocket push → Flutter ("completed") |
| 7 | Flutter | Download via R2 presigned URL (direct, bypasses API) |

### Failure Handling

| Failure Type | Response |
|-------------|----------|
| Circuit breaker OPEN | Return 503 + retry-after. Flutter shows "Portal busy, queued." |
| RPA execution failure | Screenshot → R2. Retry 3x (1s, 2s, 4s backoff). |
| DOM checksum mismatch | Try selector v2. If still fails → alert ops. |
| 3x retries exhausted | Move to Dead Letter Queue. Alert firm admin + ops. |

### Dead Letter Queue

```
Job fails → retry 3x with backoff → DLQ

DLQ actions:
  - Retry (re-queue)
  - Resolve (handled manually)
  - Escalate (flag for developer)

Alerts:
  DLQ depth > 10 → notify firm admin
  DLQ depth > 50 → notify CADesk ops
```

### RPA Fragility Mitigation

Government portals change HTML without notice. Defenses:

1. **DOM checksums** — SHA256 of key selectors before each run. Mismatch = alert.
2. **Screenshot on failure** — every failure captured, uploaded to R2, linked in DLQ.
3. **Selector versioning** — `v1`, `v2` selector sets per portal. Auto-fallback.
4. **Weekly smoke tests** — scheduled login to each portal, validate navigation.
5. **Auto-create GitHub issue** on any checksum change.

### Data Pipelines

| Pipeline | Trigger | Latency | Failure Mode |
|----------|---------|---------|-------------|
| e-Invoice IRN | Webhook | <1s | Reject invalid HMAC, DLQ |
| GSTR-2B | Cron (daily 2am) | ~5min | Retry next hour, alert after 3 |
| 26AS/AIS | RPA (on demand) | ~2min | DLQ, screenshot |
| TDS challans | RPA (on demand) | ~1min | DLQ, screenshot |
| MCA filings | Direct API | <2s | Circuit breaker, retry |
| Bank statements | IDP (OCR) | ~30s | Manual review on low confidence |

---

## 6. Hosting & Scaling

### Infrastructure Map

| Component | Platform | Region | Scaling |
|-----------|----------|--------|---------|
| Flutter Web | Cloudflare Pages | Global CDN | Auto (edge-cached) |
| Go API | Fly.io | Mumbai (bom) | Horizontal auto-scale |
| Playwright RPA | Fly.io (separate app) | Mumbai (bom) | Scale by queue depth |
| PostgreSQL | Supabase Pro | ap-south-1 | Vertical (managed) |
| Redis | Upstash | ap-south-1 | Serverless |
| Storage | Cloudflare R2 | ap-south-1 | Unlimited |
| Errors | Sentry | Auto | Client + server |
| Dashboards | Grafana Cloud | Auto | Metrics + traces |

### Scaling Targets by Phase

| Metric | Phase 1 | Phase 2 | Phase 3 |
|--------|---------|---------|---------|
| Concurrent users | 50 | 500 | 5,000 |
| API requests/min | 500 | 5,000 | 50,000 |
| RPA jobs/hour | 10 | 100 | 1,000 |
| DB rows | 100K | 1M | 10M |
| p95 API latency | <500ms | <300ms | <200ms |
| Uptime SLA | 99% | 99.5% | 99.9% |

### Filing Season Surge Plan

Indian tax filing has extreme peaks (31 Mar, 31 Jul, 31 Dec). Traffic spikes 10-20x.

1. **Pre-scale** Go API to 5 machines 48h before deadline
2. **Pre-scale** RPA workers to 10 instances
3. **Circuit breakers** → "Portal busy, queued for retry"
4. **Batch queue** → users submit, system processes overnight
5. **Offline mode** → all local data available
6. **Status page** → `status.cadesk.app` showing portal health

### Fly.io Config

```toml
# Go API
[http_service]
  auto_stop_machines = true
  auto_start_machines = true
  min_machines_running = 1
  concurrency_hard_limit = 250

[[vm]]
  size = "shared-cpu-1x"
  memory = "512mb"

# RPA Workers (separate app)
[[vm]]
  size = "shared-cpu-2x"
  memory = "1gb"    # Playwright needs RAM
```

### Performance Optimizations

| Optimization | Impact |
|-------------|--------|
| Go in Mumbai | <10ms to Indian portals |
| Cloudflare CDN | <50ms globally for static |
| Redis session cache | Avoid 3-5s re-auth to portals |
| Drift for reads | Instant, zero network |
| R2 presigned URLs | Direct download, bypass API |
| Supavisor pooling | Handle 500+ PG connections |
| Cursor pagination | Stable under concurrent writes |
| Gzip/Brotli | 60-80% payload reduction |
| Batch API endpoints | Reduce round trips on slow networks |

---

## 7. Observability & Reliability

### Monitoring Stack

```
Flutter        ──► Sentry (errors + performance)
Go API         ──► Prometheus → Grafana Cloud (metrics)
               ──► OpenTelemetry → Grafana Tempo (traces)
               ──► slog JSON → Fly.io drain → Grafana Loki (logs)
RPA Workers    ──► Sentry (errors) + custom metrics
Supabase       ──► Built-in dashboard
```

### Alert Thresholds

| Metric | Warning | Critical |
|--------|---------|----------|
| API 5xx rate | >1% | >5% |
| API p95 latency | >500ms | >2s |
| RPA queue depth | >50 | >200 |
| RPA failure rate | >10% | >30% |
| DB connections | >70% | >90% |
| Redis memory | >70% | >90% |
| DLQ depth | >10 | >50 |

### Error Handling Strategy

| Error Type | Response | Retry |
|-----------|----------|-------|
| Transient (5xx, timeout) | Exponential backoff (1s, 2s, 4s) | 3x max |
| Client (4xx) | Return clear error message | No |
| Portal down | Circuit breaker → queue → retry later | Auto |
| Data conflict | Return conflict details → sync engine | No |

### Disaster Recovery

| Component | Backup | RTO | RPO |
|-----------|--------|-----|-----|
| Supabase PG | PITR (continuous) | 1h | 0 |
| Supabase PG | pg_dump (daily) | 4h | 24h |
| R2 objects | Versioning | Instant | 0 |
| Redis | None (ephemeral) | Rebuild from PG | N/A |
| SQLite | Device-local | Re-sync | Last sync |

### Supabase Vendor Risk Mitigation

Supabase is Auth + DB + Realtime + Storage. Exit plan:
- Auth → GoTrue (open source), self-hostable
- DB → Standard PostgreSQL, migrate to any PG host
- Realtime → Abstract behind interface, swap to Ably/Pusher
- Storage → R2 is already separate

All Supabase interactions go through `pkg/supabase/` abstraction. Migration = swap implementation.

---

## 8. Flutter App Additions

### New Dependencies

```yaml
dependencies:
  dio: ^5.4.0                       # HTTP client
  drift: ^2.15.0                    # SQLite ORM
  sqlite3_flutter_libs: ^0.5.0      # SQLite native libs
  sqlcipher_flutter_libs: ^0.6.0    # SQLite encryption
  supabase_flutter: ^2.3.0          # Auth + Realtime
  flutter_secure_storage: ^9.0.0    # Token storage
  connectivity_plus: ^5.0.0         # Online/offline
  path_provider: ^2.1.0             # DB file location
  path: ^1.9.0                      # Path utilities
  sentry_flutter: ^7.0.0            # Error tracking
```

### Feature Flags (Mock → Real Migration)

Per-module flags in Supabase `feature_flags` table. No redeploy to roll back.

```dart
final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  if (!flags.isEnabled('clients_real_repo')) {
    return MockClientRepository();
  }
  return ClientRepositoryImpl(
    remote: ClientRemoteSource(ref.watch(apiClientProvider)),
    local: ClientLocalSource(ref.watch(appDatabaseProvider)),
  );
});
```

Rollback: set flag to `false` → all users fall back to mock within 5 min (cache TTL).

### New Core Files

```
lib/core/
  network/
    api_client.dart              # Dio singleton + interceptors
    api_endpoints.dart           # Endpoint constants
    api_interceptors.dart        # Auth, retry, idempotency, logging
    connectivity_provider.dart   # Online/offline state
  database/
    app_database.dart            # Drift database (encrypted)
    tables/                      # One per table group
    daos/                        # Data access objects
  auth/
    supabase_auth_provider.dart  # Riverpod AsyncNotifier
    auth_state.dart              # Auth state model
    role_guard.dart              # GoRouter route guards
  sync/
    sync_engine.dart             # Queue + push + conflict
    conflict_resolver.dart       # Server-wins + notification
    sync_status_provider.dart    # UI indicator
  feature_flags/
    feature_flag_provider.dart   # Remote config
    flag_cache.dart              # Local cache (5min TTL)
  error/
    error_handler.dart           # Centralized handling
    sentry_reporter.dart         # Sentry integration
```

### API Client

```dart
@riverpod
Dio apiClient(Ref ref) {
  final dio = Dio(BaseOptions(
    baseUrl: const String.fromEnvironment('API_BASE_URL',
        defaultValue: 'https://api.cadesk.app/v1'),
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 30),
  ));

  dio.interceptors.addAll([
    AuthInterceptor(ref),
    IdempotencyInterceptor(),
    RetryInterceptor(maxRetries: 3, backoffFactor: 2),
    ConnectivityInterceptor(ref),
    if (kDebugMode) LoggingInterceptor(),
  ]);

  return dio;
}
```

### Repository Implementation Pattern

```
lib/features/<module>/
  domain/
    models/                    # FROZEN
    repositories/              # FROZEN
  data/
    repositories/
      mock_*_repository.dart   # Keep for tests
      *_repository_impl.dart   # NEW — orchestrates remote + local
    datasources/
      *_remote_source.dart     # Dio HTTP calls
      *_local_source.dart      # Drift queries
    mappers/
      *_mapper.dart            # JSON ↔ domain (pure functions)
  presentation/                # Provider swap via feature flag
```

### Offline UX

```
Status bar:
  Online (synced) | Online (3 pending) | Offline (12 queued)

When offline:
  - All reads work (Drift)
  - Writes queue locally
  - Portal ops: "Will sync when online"
  - User can review queued changes

When back online:
  - Auto-sync in background
  - Conflicts shown as notifications
  - User reviews + resolves each conflict
```

---

## 9. CI/CD Pipelines

![CI/CD](docs/architecture/05-cicd-pipeline.svg)

### Flutter Pipeline

```
flutter analyze → flutter test --coverage → coverage gate (BLOCKING)
  → flutter build web → Cloudflare Pages (main)
  → flutter build ipa → Fastlane TestFlight (tag push)
  → sentry-cli upload-dif
```

### Go Backend Pipeline

```
golangci-lint → go test -race → go build → docker build
  → fly deploy (main)
```

### Playwright RPA Pipeline

```
npm ci → npm test → docker build → fly deploy (main)
```

### Supabase Migrations

```
push to main (supabase/migrations/**) → supabase db push
  → verify RLS policies on all new tables
```

---

## 10. Automation Pipeline — Agent-Driven

### Module Implementation Loop

For each of the 74 modules:

```
/start-task "Implement *RepositoryImpl for <module>"

  1. READ    — mock repo + domain models → understand interface
  2. TEST    — tdd-guide writes failing tests (mock HTTP, verify mapping)
  3. IMPL    — RemoteSource + LocalSource + Mapper + *RepositoryImpl
  4. REVIEW  — code-reviewer checks error handling, idempotency, offline
  5. FLAG    — add feature flag entry (default: false)
  6. COMMIT  — CI → coverage gate → merge
```

### Agent Roles

| Agent | Role |
|-------|------|
| `tdd-guide` | Write tests first for every `*RepositoryImpl` |
| `planner` | Decompose module into work units |
| `code-reviewer` | Check: errors, idempotency, offline, no domain mutations |
| `security-reviewer` | Check credential leaks, injection |
| `build-error-resolver` | Auto-fix build failures |

---

## 11. Implementation Phases

![Phases](docs/architecture/06-implementation-phases.svg)

### Phase 1 — Foundation (2-3 sprints)

**Goal:** End-to-end flow for 1 module (clients).

| Deliverable | Details |
|-------------|---------|
| Go backend | chi router + auth + health endpoint + Fly.io |
| Supabase | Core schema + RLS + Auth setup |
| Redis | Provisioned in ap-south-1 |
| Flutter deps | Dio, Drift, Supabase, Sentry |
| Core files | api_client, app_database, auth_provider |
| Feature flags | Infrastructure ready |
| Sync engine | Basic offline queue |
| First impl | `ClientRepositoryImpl` end-to-end |
| Observability | Sentry + Prometheus + slog |
| CI | Flutter + Go GitHub Actions |

**Exit:** Tests green, client CRUD works online + offline, Grafana shows metrics. **1/74 modules.**

### Phase 2 — Portal Integration (3-4 sprints)

**Goal:** Government portal access via Go proxy.

| Deliverable | Details |
|-------------|---------|
| Circuit breakers | Per portal (GSTN, MCA, ITD, TRACES, EPFO) |
| Rate limiting | Multi-level (per firm + per portal) |
| GSTN | Direct REST API (sandbox → prod) |
| MCA | Direct REST API |
| TRACES RPA | Form 16/16A bulk download |
| ITD RPA | Return status, demand notices |
| Job queue | Redis + DLQ |
| Storage | R2 + presigned URLs |
| Realtime | WebSocket + polling fallback |
| RPA health | DOM checksums, smoke tests |
| 10 modules | Feature-flagged real impls |

**Exit:** Can file GSTR-1, download Form 16. Circuit breakers work. **10/74 modules.**

### Phase 3 — Full Automation (4-6 sprints)

**Goal:** All 74 modules live, batch ops working.

| Deliverable | Details |
|-------------|---------|
| 64 modules | Agent-driven loop, feature-flagged |
| Batch engine | Bulk Form 16, TDS, GSTR-1 |
| EPFO RPA | ECR filing |
| Data pipelines | GSTR-2B cron, 26AS scrape, IRN webhook |
| Full sync | Drift ↔ Supabase + conflict UI |
| iOS | TestFlight via Fastlane |
| DPDP Act | Consent, erasure, export |
| Hardening | Alerting, runbooks, on-call |
| Load test | 50K req/min target |
| Surge plan | Filing season pre-scaling |

**Exit:** 74/74 modules, <200ms p95, DLQ <10 steady state, 99.9% uptime.

---

## 12. Repo Structure

```
/CA-app (Flutter — this repo)
  lib/
    core/
      network/               # Dio, endpoints, interceptors
      database/              # Drift, tables, DAOs, encryption
      auth/                  # Supabase auth, RBAC guards
      sync/                  # Offline sync, conflict resolution
      feature_flags/         # Remote config
      error/                 # Sentry, error handling
    features/                # 74 modules
  test/
  supabase/migrations/       # PostgreSQL schema
  docs/architecture/          # SVG diagrams (this doc references)
  arc.md                     # THIS FILE
  CLAUDE.md                  # Agent instructions

/CA-app-backend (Go — separate repo)
  cmd/server/main.go
  internal/
    api/                     # Router, middleware
    portals/                 # GSTN, MCA, ITD, TRACES, EPFO + circuit breakers
    jobs/                    # Queue + scheduler + DLQ
    rpa/                     # Playwright dispatcher + health
    storage/                 # R2
    vault/                   # Supabase Vault
    observability/           # OTel, Prometheus, slog
  pkg/                       # Supabase, Redis wrappers
  Dockerfile, fly.toml

/CA-app-rpa (Node.js Playwright — separate repo)
  scripts/                   # traces/, itd/, epfo/ (versioned selectors)
  src/
    worker.ts                # Redis consumer
    browser.ts               # Playwright pool
    healthcheck.ts           # DOM checksum
    screenshot.ts            # Failure capture → R2
  Dockerfile, fly.toml
```

---

## 13. Constraints & Invariants

| # | Rule | Enforced By | If Violated |
|---|------|-------------|------------|
| 1 | Domain layer FROZEN | Code review, agents | Breaks 727+ tests |
| 2 | Immutable state only | Riverpod, Drift | Race conditions |
| 3 | TDD mandatory | `tdd-guide`, coverage gate | Blocked by CI |
| 4 | 100% test coverage | `.coverage-thresholds.json` | PR cannot merge |
| 5 | No secrets in Flutter | Build-time env vars, Vault | Security audit fail |
| 6 | RLS on every table | Migration CI check | Cross-tenant leak |
| 7 | File size: 400 typical, 800 max | `code-reviewer` | Review rejection |
| 8 | Clean Architecture | Import rules | Build error |
| 9 | Offline-first reads | Drift | App unusable offline |
| 10 | Stateless API | No in-memory state | Scaling fails |
| 11 | Idempotency on mutations | Required header | Duplicate filings |
| 12 | Feature-flagged rollout | Supabase config | Can't roll back |
| 13 | Webhook HMAC verification | Signature check | Data injection |
| 14 | Audit trail for portals | `audit_log` table | Compliance fail |
| 15 | No PAN/Aadhaar in logs | slog redaction | DPDP violation |

---

## 14. Decision Log

| Date | Decision | Rationale | Alternatives |
|------|----------|-----------|-------------|
| 2026-03-13 | Go backend | <50ms cold start, goroutines, tiny binary | Node.js (more RAM), Rust (overkill) |
| 2026-03-13 | Supabase | PG + RLS + Realtime + Mumbai region | Firebase (no India DC), Neon (newer) |
| 2026-03-13 | Fly.io | Mumbai PoP, auto-scale, cheap | AWS (complex), Railway (no Mumbai) |
| 2026-03-13 | Server-wins sync | Financial data needs single truth | CRDTs (complex), LWW (silent loss) |
| 2026-03-13 | Separate RPA service | Playwright is Node-only, isolate scaling | Rod (Go, less mature) |
| 2026-03-13 | Cursor pagination | Stable under concurrent writes | Offset (breaks at scale) |
| 2026-03-13 | Feature flags | Roll back per-module, no redeploy | Compile flags (requires deploy) |
| 2026-03-13 | SQLCipher | PAN/Aadhaar on device needs encryption | No encryption (DPDP violation) |
