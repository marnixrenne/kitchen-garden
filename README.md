# Kitchen Garden

A web application that shows which vegetables you can seed each month, based on a temperate European climate. Users can create an account, browse vegetables, and maintain their personal garden list.

## Features

- Browse vegetables by seeding month
- Vegetables grouped by category: Fruiting, Leafy, Brassica, Root, Legume, Herb
- Month overview showing how many crops can be seeded per month
- User accounts with email-based signup and email verification
- Personal garden list — add or remove vegetables from your garden
- User preferences (key-value store per user)
- Role-based access control

## Tech stack

**Backend**
- **Kotlin** + **Spring Boot 4** — REST API
- **Jetbrains Exposed** — Kotlin SQL framework (DSL mode)
- **Flyway** — database migrations
- **PostgreSQL** — database (via Docker)
- **Spring Security** — session-based authentication
- **Spring Mail** — email verification (logs link to console when SMTP is not configured)

**Frontend**
- **Vue 3** — UI framework (Composition API)
- **vue-router v4** — client-side routing
- **vue-i18n v11** — internationalisation (English + Dutch)
- **Vite** — dev server and build tool
- **Vitest** + **@vue/test-utils** — component unit tests

## Getting started

### Prerequisites

Start the PostgreSQL database with Docker Compose:

```bash
docker compose -f docker/docker-compose.yml up -d
```

### Backend (API on port 8080)

```bash
./gradlew bootRun
```

Flyway runs all migrations automatically on startup and seeds the vegetable data.

### Frontend (dev server on port 5173)

```bash
cd frontend
npm install
npm run dev
```

Then open [http://localhost:5173](http://localhost:5173) in your browser.

### Frontend tests

```bash
cd frontend
npm test
```

Tests run with [Vitest](https://vitest.dev/) + [@vue/test-utils](https://test-utils.vuejs.org/) in a happy-dom environment. The test suite lives in `frontend/src/views/__tests__/` and covers component behaviour such as data loading on mount, route-param-driven re-fetching, and the companion garden toggle button.

### Default credentials

An admin user is created automatically on first startup:

| Username | Password |
|---|---|
| `admin` | value of `ADMIN_PASSWORD` (default: `admin`) |

## Configuration

All settings can be overridden via environment variables:

| Variable | Default | Description |
|---|---|---|
| `PORT` | `8080` | HTTP port the server listens on |
| `DB_HOST` | `localhost` | PostgreSQL host |
| `DB_PORT` | `5432` | PostgreSQL port |
| `DB_NAME` | `kitchengarden` | Database name |
| `DB_USER` | `kitchengarden` | Database username |
| `DB_PASSWORD` | `kitchengarden` | Database password |
| `DATASOURCE_URL` | _(built from DB_* vars)_ | Override the full JDBC URL directly |
| `ADMIN_PASSWORD` | `admin` | Password for the auto-created admin user (only used on first startup) |
| `APP_BASE_URL` | `http://localhost:5173` | Base URL used in verification emails |
| `MAIL_HOST` | `localhost` | SMTP host |
| `MAIL_PORT` | `1025` | SMTP port |
| `MAIL_FROM` | `noreply@kitchengarden.local` | From address for outgoing mail |

When no SMTP server is reachable, the verification link is printed to the application log instead.

## Deployment

### Render

The project includes a `Dockerfile` (multi-stage: Node → JDK → JRE) and a `render.yaml` blueprint.

**Deploy via Blueprint (recommended):**

1. Push the repository to GitHub
2. Go to the Render dashboard → **New → Blueprint**
3. Connect the repository — Render reads `render.yaml` and creates both the web service and the managed PostgreSQL database automatically
4. Once deployed, open the web service's **Environment** tab and set:
   - `APP_BASE_URL` → your Render service URL (e.g. `https://kitchen-garden.onrender.com`)
   - `MAIL_HOST`, `MAIL_PORT`, `MAIL_USERNAME`, `MAIL_PASSWORD` → your SMTP provider credentials (e.g. Mailgun, Resend)

**Free tier notes:**

- The web service spins down after 15 minutes of inactivity; the first request after sleep is slow and in-memory sessions are lost
- Render's free PostgreSQL plan expires after 90 days

## API

### Vegetables

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `GET` | `/api/vegetables?month={1-12}` | No | Vegetables seedable in the given month |
| `GET` | `/api/vegetables/counts` | No | Number of seedable crops per month |
| `GET` | `/api/vegetables/{id}` | No | Single vegetable detail |

### Authentication

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `POST` | `/api/auth/login` | No | Log in (`email` + `password` form fields) |
| `POST` | `/api/auth/logout` | Yes | Log out |
| `GET` | `/api/auth/me` | Yes | Current user info |
| `POST` | `/api/auth/signup` | No | Initiate signup — sends verification email |
| `GET` | `/api/auth/verify/{token}` | No | Validate a signup token |
| `POST` | `/api/auth/complete` | No | Complete signup — set password |

### Garden

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `GET` | `/api/garden` | Yes | IDs of vegetables in the user's garden |
| `PUT` | `/api/garden/{vegetableId}` | Yes | Add a vegetable to the garden |
| `DELETE` | `/api/garden/{vegetableId}` | Yes | Remove a vegetable from the garden |

### Preferences

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `GET` | `/api/preferences` | Yes | All preferences for the current user |
| `PUT` | `/api/preferences/{key}` | Yes | Set a preference value |
| `DELETE` | `/api/preferences/{key}` | Yes | Delete a preference |

## Project structure

```
├── docker-compose.yml                    # PostgreSQL 15
├── frontend/                             # Vue 3 + Vite
│   └── src/
│       ├── App.vue                       # Root component, nav bar
│       ├── main.js                       # Entry point
│       ├── router/index.js               # Routes + auth guard
│       ├── stores/auth.js                # Auth state (Pinia-style)
│       ├── i18n/                         # en.js + nl.js translations
│       ├── components/
│       │   ├── MonthSelector.vue
│       │   ├── VegetableList.vue         # Vegetable cards with garden toggle
│       │   └── LoginForm.vue
│       └── views/
│           ├── __tests__/
│           │   └── VegetableDetailView.spec.js
│           ├── LandingView.vue           # Public landing page
│           ├── HomeView.vue              # Month selector + vegetable list
│           ├── VegetableDetailView.vue   # Vegetable detail + garden button
│           ├── SignupView.vue            # Email signup form
│           └── VerifyView.vue           # Token verification + password form
└── src/main/
    ├── kotlin/.../kitchengarden/
    │   ├── KitchenGardenApplication.kt
    │   ├── ExposedConfig.kt              # Exposed + transaction manager wiring
    │   ├── Tables.kt                     # Vegetables, SeedingMonths, GardenVegetables, UserPreferences
    │   ├── Vegetable.kt
    │   ├── VegetableRepository.kt
    │   ├── VegetableController.kt
    │   ├── GardenRepository.kt
    │   ├── GardenController.kt
    │   ├── PreferenceRepository.kt
    │   ├── PreferenceController.kt
    │   └── security/
    │       ├── Tables.kt                 # Users, Roles, RoleAuthorities, UserRoles, SignupTokens
    │       ├── SecurityConfig.kt         # Spring Security configuration
    │       ├── UserDetailsServiceImpl.kt
    │       ├── AuthController.kt         # /api/auth/me, logout
    │       ├── SignupController.kt       # /api/auth/signup, verify, complete
    │       ├── SignupService.kt          # Token generation, email sending
    │       └── DataInitializer.kt        # Seeds admin user on first startup
    └── resources/
        ├── application.yaml
        └── db/migration/
            ├── V1__create_schema.sql     # vegetables, seeding_months
            ├── V2__seed_vegetables.sql   # 24 vegetables with seeding months
            ├── V3__create_users.sql
            ├── V4__create_roles.sql      # roles, role_authorities, user_roles
            ├── V5__create_user_preferences.sql
            ├── V6__add_email_and_signup_tokens.sql
            └── V7__create_garden_vegetables.sql
```
