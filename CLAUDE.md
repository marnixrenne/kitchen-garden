# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

**Backend:**
```bash
./gradlew bootRun          # start backend (requires ADMIN_PASSWORD env var)
./gradlew test             # run all tests
./gradlew compileKotlin    # compile only
./gradlew test --tests "org.marnixrenne.kitchengarden.PlantApiTest"  # single test class
```

**Frontend:**
```bash
cd frontend && npm run dev    # start Vite dev server (proxies /api to :8080)
cd frontend && npm run build  # production build
```

`ADMIN_PASSWORD` has no default and is required for non-test startup. Tests use Testcontainers (PostgreSQL 15-alpine) and don't need it.

Start PostgreSQL for local dev:
```bash
docker compose -f docker/docker-compose.yml up -d
```

## Architecture

Spring Boot 4 (Kotlin) backend on port 8080, Vue 3/Vite frontend on port 5173. Frontend proxies `/api/*` to the backend.

**Backend package structure** (domain-driven, each package has `domain/`, `application/`, `infrastructure/` sub-packages):
- `plants/` — plant catalogue; `PlantTables.kt` holds the Exposed DSL objects; `Plant.kt` is the list DTO, `PlantDetail.kt` has the full detail type with enums (`PlantLifespan`, `SowingMethod`, `CompanionRelationship`)
- `garden/` — named user gardens split into beds (every plant instance sits in exactly one bed; a garden always keeps at least one), plant instances, log entries with lifecycle states (a log holding only moves has no state), week summaries, planting suggestions
- `garden/lifecycle/` — lifecycle state machine per plant instance
- `garden/plan/` — `PlantPlanCalculator` (pure domain object, has unit tests) computes germination/harvest/pruning/fertilizing/watering date ranges from a seed date
- `preferences/` — key-value user preferences
- `user/` — `UserResolver` extracts `UserId` from the security context
- `security/` — Spring Security config, signup flow, brute-force protection; `security/Tables.kt` holds user/role/signup-token table objects
- `mail/` — `MailService` interface with two implementations: `SmtpMailService` (default) and `ResendMailService` (activated when `RESEND_API_KEY` is set); verification links are logged to console when no SMTP is reachable
- `admin/` — admin-only endpoints

**Application services follow lightweight CQRS:** each bounded context has separate `*CommandService` and `*QueryService` classes.

**Database:** Flyway migrations in `src/main/resources/db/migration/`. Plant data is seeded through migrations (not a fixture file). V32 was intentionally skipped — the count in `MigrationTest` reflects this (76 successful migrations through V77).

**Auth:** Session-based Spring Security with CSRF (`CookieCsrfTokenRepository`, non-XOR handler). The JS SPA reads the raw `XSRF-TOKEN` cookie and sends it as `X-XSRF-TOKEN`; the `CsrfCookieFilter` forces the deferred token to materialise on every response. `/api/auth/**` and `/api/plants/**` are public; `/api/admin/**` requires `ROLE_ADMIN`; everything else requires authentication.

**i18n:** vue-i18n v11 with EN, NL, ES in `frontend/src/i18n/{en,nl,es}.js`. Tips/descriptions are stored in both the i18n files (preferred) and the DB column (fallback), resolved at render time with `te(key) ? t(key) : dbValue`.

**Frontend routing:** `router/index.js` uses `meta.requiresAuth`, `meta.requiresAdmin`, `meta.noAdmin`, and `meta.guestOnly` flags. Admin users are redirected away from regular views (`/discover`, `/garden`) to `/admin` automatically.

## Adding a plant attribute

When adding a new column to `pts_plants` (e.g. a `foo_type` badge + `foo_tip` text), touch these files in order:

1. **New migration** `V{n}__add_foo_info.sql` — `ALTER TABLE pts_plants ADD COLUMN …`
2. **Seed migration** `V{n+1}__seed_foo_info.sql` — `UPDATE pts_plants SET … WHERE name = '…'`
3. **`plants/infrastructure/PlantTables.kt`** — add column to the `Plants` object
4. **`plants/domain/PlantDetail.kt`** — add fields to the `PlantDetail` data class (add enums here too if needed)
5. **`plants/infrastructure/ExposedPlantRepository.kt`** — map the column in `findById`
6. **`garden/infrastructure/ExposedGardenRepository.kt`** — add `null` stubs to the `PlantDetail(…)` call in `findDetails` (this file also constructs `PlantDetail` and will fail to compile otherwise)
7. **`PlantDetailView.vue`** — add template section, badge CSS, computed tip text
8. **`frontend/src/i18n/{en,nl,es}.js`** — add translation block with `title`, `type`, and `tips`
9. **`MigrationTest.kt`** — update the two hardcoded counts: migration count (`assertEquals(76, count, …)`) and plant count (`assertEquals(183, count, …)`)

The pruning and fertilizer features are the canonical examples of this pattern.

## Agent skills

### Issue tracker

Issues live in GitHub Issues on `marnixrenne/kitchen-garden` (via `gh`). See `docs/agents/issue-tracker.md`.

### Triage labels

Default vocabulary: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: `GLOSSARY.md` + `docs/adr/` at the repo root. See `docs/agents/domain.md`.
