# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

The NSF Resilience App is a community-based peer-to-peer information and resource sharing platform for disaster response. It consists of:
- **Flutter frontend** (`src/support_sphere/`) — mobile + web app
- **Python/FastAPI backend** (`src/support_sphere_py/`) — REST API
- **Supabase** — PostgreSQL database with auth (deployed via Kubernetes)

## Build & Task System

All tasks are managed via **Pixi** (`pixi.toml` at repo root). Run `pixi run <task>` for any operation.

### Frontend (Flutter)
```
pixi run flutter-get     # Install Flutter dependencies (pubspec.yaml)
pixi run run             # Run on connected device
pixi run run-web         # Run in Chrome (web)
```

Or directly in `src/support_sphere/`:
```
flutter pub get
flutter run
flutter test
flutter test test/path/to/test_file.dart   # Run single test
flutter analyze                             # Lint
```

### Backend (Python/FastAPI)
```
pixi run fast-api-server-dev    # Dev server with auto-reload (localhost:8000)
pixi run fast-api-server-run    # Production server
```

Or directly in `src/support_sphere_py/`:
```
pip install -e .
uvicorn support_sphere.apis.main:app --reload
pytest                          # Run tests
pytest path/to/test_file.py     # Run single test
```

### Infrastructure / Database
```
pixi run supabase           # Start local Supabase
pixi run db-init            # Initialize database schema
pixi run setup-infra        # Set up local k3d cluster with Supabase
pixi run clean              # Clean Docker and k3d resources
```

## Architecture

### Flutter Frontend (`src/support_sphere/`)

Follows **Clean Architecture + BLoC** state management:

- `lib/main.dart` — Entry point; initializes Supabase and wraps app in BLoC providers
- `lib/logic/bloc/` — BLoC events/states/cubits (auth, user, etc.)
- `lib/presentation/` — UI pages, widgets, and router
- `lib/data/` — Repository classes that call Supabase or backend APIs
- `lib/constants/` — App-wide constants including Supabase config
- `lib/utils/` — Helper utilities

**Routing**: Auth-driven routing in `presentation/router/`. Unauthenticated users see auth screens; authenticated users are routed based on role/state.

**Supabase integration**: The Flutter app connects directly to Supabase for auth and data. The FastAPI backend is a separate service for operations requiring server-side logic.

### Python Backend (`src/support_sphere_py/`)

FastAPI app following a **Repository Pattern**:

- `apis/main.py` — FastAPI app, router registration
- `apis/v1/` — Versioned API endpoints
- `models/` — SQLModel/Pydantic models (enums, public domain, auth)
- `repositories/` — Data access layer (`BaseRepository` + domain-specific repos)
- `services/` — Business logic layer
- `scripts/cli_app.py` — Typer CLI for DB operations

### Database / Supabase

- PostgreSQL with PostGIS extension for geospatial features
- Supabase Auth for user management and Row Level Security
- Schema migrations managed in `deployment/supabase/`
- Local dev uses k3d + Kubernetes Helm charts (`vendors/supabase-kubernetes/`)

### Key Domain Models

Found in `src/support_sphere_py/src/support_sphere/models/`:
- `OperationalEvent` — Active disaster response events
- `PointOfInterest` — Mapped resources/locations
- `Resource` / `ResourceRequest` — Community resource management
- `UserChecklist` — Task management for users
- `Cluster` / `HouseholdUnit` — Community groupings

### Deployment

- **Local**: k3d Kubernetes cluster via `pixi run setup-infra`
- **Cloud**: AWS via OpenTofu (`deployment/cloud/`)
- **CI/CD**: GitHub Actions (`.github/workflows/`)
  - Flutter tests: `ci_support_sphere_flutter.yml`
  - Python backend CD: `cd_support_sphere_py.yml`
- **Secrets**: Mozilla SOPS (`.sops.yaml`)

## Environment Configuration

- Flutter: `src/support_sphere/lib/constants/` contains Supabase URL/key config
- Python: `.env` file with `DATABASE_URL`, Supabase credentials
- Pixi manages Python/system dependencies; Flutter SDK managed separately
