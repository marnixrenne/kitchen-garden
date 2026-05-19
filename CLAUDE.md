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

`ADMIN_PASSWORD` has no default and is required for non-test startup. Tests use Testcontainers and don't need it.

## Architecture

Spring Boot 4 (Kotlin) backend on port 8080, Vue 3/Vite frontend on port 5173. Frontend proxies `/api/*` to the backend. PostgreSQL via Docker Compose for local dev; Testcontainers (PostgreSQL 15-alpine) for tests.

**Backend layers:**
- `Tables.kt` — Jetbrains Exposed DSL table objects (no JPA annotations)
- `PlantDetail.kt` / `SimpleVeg.kt` — data transfer types
- `PlantRepository.kt` — full plant detail queries
- `GardenRepository.kt` — user-garden queries; also constructs `PlantDetail` with `null` stubs for detail-only fields
- `PlantService.kt` / `GardenService.kt` — thin service layer
- Controllers under `plants/` and `garden/`

**Database:** Flyway migrations in `src/main/resources/db/migration/`. Plant data is seeded through migrations (not a fixture file). V32 was intentionally skipped — the count in `MigrationTest` reflects this.

**Auth:** Session-based Spring Security with CSRF (`CookieCsrfTokenRepository`, non-XOR handler). The `/api/auth/*` endpoints are public; everything else requires authentication.

**i18n:** vue-i18n v11 with EN, NL, ES in `frontend/src/i18n/{en,nl,es}.js`. Tips/descriptions are stored in both the i18n files (preferred) and the DB column (fallback), resolved at render time with `te(key) ? t(key) : dbValue`.

## Adding a plant attribute

When adding a new column to `pts_plants` (e.g. a `foo_type` badge + `foo_tip` text), touch these files in order:

1. **New migration** `V{n}__add_foo_info.sql` — `ALTER TABLE pts_plants ADD COLUMN …`
2. **Seed migration** `V{n+1}__seed_foo_info.sql` — `UPDATE pts_plants SET … WHERE name = '…'`
3. **`Tables.kt`** — add column to the `Plants` object
4. **`PlantDetail.kt`** — add fields to the data class
5. **`PlantRepository.kt`** — map the columns in `findById`
6. **`GardenRepository.kt`** — add `null` stubs to the `PlantDetail(…)` call in `findDetails` (this file also constructs `PlantDetail` and will fail to compile otherwise)
7. **`PlantDetailView.vue`** — add template section, badge CSS, computed tip text
8. **`frontend/src/i18n/{en,nl,es}.js`** — add translation block with `title`, `type`, and `tips`
9. **`MigrationTest.kt`** — update the hardcoded migration count (`assertEquals(N, count, …)`)

The pruning and fertilizer features are the canonical examples of this pattern.
