# Kitchen Garden

A web application that shows which plants you can seed each month, based on a temperate European climate. Users can create an account, browse plants, and maintain their personal garden list.

## Features

- Browse plants by seeding month
- Plants grouped by category: Fruiting, Leafy, Brassica, Root, Legume, Herb
- Month overview showing how many crops can be seeded per month
- User accounts with email-based signup and email verification
- Personal garden list — add or remove plants from your garden
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

Flyway runs all migrations automatically on startup and seeds the plant data.

### Frontend (dev server on port 5173)

```bash
cd frontend
npm install
npm run dev
```

Then open [http://localhost:5173](http://localhost:5173) in your browser.

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

### Plants

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `GET` | `/api/plants?month={1-12}` | No | Plants seedable in the given month |
| `GET` | `/api/plants/counts` | No | Number of seedable crops per month |
| `GET` | `/api/plants/{id}` | No | Single plant detail |

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
| `GET` | `/api/garden` | Yes | IDs of plants in the user's garden |
| `PUT` | `/api/garden/{plantId}` | Yes | Add a plant to the garden |
| `DELETE` | `/api/garden/{plantId}` | Yes | Remove a plant from the garden |

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
│       │   ├── PlantList.vue             # Plant cards with garden toggle
│       │   └── LoginForm.vue
│       └── views/
│           ├── LandingView.vue           # Public landing page
│           ├── HomeView.vue              # Month selector + plant list
│           ├── PlantDetailView.vue       # Plant detail + garden button
│           ├── SignupView.vue            # Email signup form
│           └── VerifyView.vue           # Token verification + password form
└── src/main/
    ├── kotlin/.../kitchengarden/
    │   ├── KitchenGardenApplication.kt
    │   ├── ExposedConfig.kt              # Exposed + transaction manager wiring
    │   ├── plants/Tables.kt              # Plants, SeedingMonths, GardenPlants
    │   ├── plants/Plant.kt
    │   ├── plants/PlantRepository.kt
    │   ├── plants/PlantController.kt
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
            ├── V1__create_schema.sql     # plants, seeding_months
            ├── V2__seed_vegetables.sql   # 24 plants with seeding months
            ├── V3__create_users.sql
            ├── V4__create_roles.sql      # roles, role_authorities, user_roles
            ├── V5__create_user_preferences.sql
            ├── V6__add_email_and_signup_tokens.sql
            ├── V7__create_garden_vegetables.sql
            └── V36__rename_vegetable_to_plant.sql
```
