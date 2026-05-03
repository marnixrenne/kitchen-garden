# Kitchen Garden

A Spring Boot web application that shows which vegetables you can seed each month, based on a temperate European climate.

## Features

- Select a month to see all vegetables that can be seeded that month
- Vegetables grouped by category: Fruiting, Leafy, Brassica, Root, Legume, Herb
- Month overview showing how many crops can be seeded per month

## Tech stack

- **Kotlin** + **Spring Boot 4**
- **Jetbrains Exposed** — Kotlin SQL framework for database access
- **Flyway** — database migrations
- **H2** — in-memory database
- **Spring MVC** — REST API + static file serving

## Getting started

```bash
./gradlew bootRun
```

Then open [http://localhost:8080](http://localhost:8080) in your browser.

## API

| Endpoint | Description |
|---|---|
| `GET /api/vegetables?month={1-12}` | Vegetables that can be seeded in the given month |
| `GET /api/vegetables/counts` | Number of seedable crops per month |

## Project structure

```
src/main/
├── kotlin/.../kitchengarden/
│   ├── KitchenGardenApplication.kt   # Spring Boot entry point
│   ├── Tables.kt                     # Exposed table definitions
│   ├── Vegetable.kt                  # Data class
│   ├── VegetableRepository.kt        # Database queries
│   ├── VegetableController.kt        # REST endpoints
│   └── ExposedConfig.kt              # Exposed datasource wiring
└── resources/
    ├── db/migration/                 # Flyway migrations
    └── static/index.html             # Frontend
```