# Kitchen Garden

A web application that shows which vegetables you can seed each month, based on a temperate European climate.

## Features

- Select a month to see all vegetables that can be seeded that month
- Vegetables grouped by category: Fruiting, Leafy, Brassica, Root, Legume, Herb
- Month overview showing how many crops can be seeded per month

## Tech stack

**Backend**
- **Kotlin** + **Spring Boot 4** — REST API
- **Jetbrains Exposed** — Kotlin SQL framework
- **Flyway** — database migrations
- **H2** — in-memory database

**Frontend**
- **Vue 3** — UI framework
- **Vite** — dev server and build tool

## Getting started

Both the backend and frontend need to run simultaneously during development.

**Backend** (API on port 8080)
```bash
./gradlew bootRun
```

**Frontend** (dev server on port 5173)
```bash
cd frontend
npm install
npm run dev
```

Then open [http://localhost:5173](http://localhost:5173) in your browser.

## API

| Endpoint | Description |
|---|---|
| `GET /api/vegetables?month={1-12}` | Vegetables that can be seeded in the given month |
| `GET /api/vegetables/counts` | Number of seedable crops per month |

## Project structure

```
├── frontend/                         # Vue 3 + Vite
│   ├── src/
│   │   ├── App.vue                   # Root component
│   │   ├── main.js                   # Entry point
│   │   └── components/
│   │       ├── MonthSelector.vue
│   │       └── VegetableList.vue
│   ├── index.html
│   ├── vite.config.js                # Proxies /api to localhost:8080
│   └── package.json
└── src/main/
    ├── kotlin/.../kitchengarden/
    │   ├── KitchenGardenApplication.kt
    │   ├── Tables.kt                 # Exposed table definitions
    │   ├── Vegetable.kt              # Data class
    │   ├── VegetableRepository.kt    # Database queries
    │   ├── VegetableController.kt    # REST endpoints
    │   └── ExposedConfig.kt          # Exposed datasource wiring
    └── resources/
        └── db/migration/             # Flyway migrations
```
