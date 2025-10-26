# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

TypeScript monorepo for a full-stack web application:
- **Frontend**: React + TanStack Router + shadcn/ui
- **Backend**: Hono + Vite + Prisma
- **Database**: PostgreSQL 17 (Docker)
- **Schema**: TypeSpec → OpenAPI
- **Monorepo**: Turborepo + pnpm workspaces

## Common Commands

```bash
# Development
pnpm dev                    # Start all apps
pnpm build                  # Build all apps
pnpm lint                   # Lint all code
pnpm format                 # Format all code

# Database (from apps/backend)
pnpm db:generate            # Generate Prisma client
pnpm db:push                # Push schema to DB (dev)
pnpm db:migrate             # Create migration (prod)
pnpm db:studio              # Open Prisma Studio

# Docker
docker compose up -d        # Start PostgreSQL
docker compose down         # Stop PostgreSQL
```

## Documentation

For detailed information, see the `docs/` directory:

- **[docs/architecture.md](docs/architecture.md)** - Project structure and architecture
- **[docs/backend-architecture.md](docs/backend-architecture.md)** - **Backend architecture (Clean Architecture)**
- **[docs/frontend-architecture.md](docs/frontend-architecture.md)** - **Frontend architecture (Feature-Sliced Design)**
- **[docs/development.md](docs/development.md)** - Development workflows and setup
- **[docs/backend.md](docs/backend.md)** - Backend (Hono + Prisma) details
- **[docs/frontend.md](docs/frontend.md)** - Frontend (React + TanStack Router) details
- **[docs/database.md](docs/database.md)** - Database schema and operations
- **[docs/schema.md](docs/schema.md)** - TypeSpec API schema development

## Quick Reference

- Monorepo packages: `@workflow-example/*`
- Backend: http://localhost:3001
- Frontend: http://localhost:3000
- Add packages: `pnpm add --filter @workflow-example/<app> <package>`
