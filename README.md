# Workflow Example

A full-stack TypeScript monorepo template with React, Hono, Prisma, and TypeSpec.

## Tech Stack

- **Frontend**: React + TanStack Router + shadcn/ui + Tailwind CSS
- **Backend**: Hono + Vite + Prisma ORM
- **Database**: PostgreSQL 17
- **Schema**: TypeSpec for API schema-driven development
- **Monorepo**: Turborepo + pnpm workspaces

## Quick Start

```bash
# Install dependencies
pnpm install

# Start PostgreSQL
docker compose up -d

# Setup environment files
cp .env.example .env
cp apps/backend/.env.example apps/backend/.env
cp apps/frontend/.env.example apps/frontend/.env

# Setup Husky
pnpm prepare

# Generate Prisma client and push schema
cd apps/backend
pnpm db:generate
pnpm db:push
cd ../..

# Start development servers
pnpm dev
```

- Frontend: http://localhost:3000
- Backend: http://localhost:3001

## Documentation

- **[CLAUDE.md](./CLAUDE.md)** - Quick reference for Claude Code
- **[docs/](./docs/)** - Detailed documentation
  - [Architecture](./docs/architecture.md)
  - [Backend Architecture (Clean Architecture)](./docs/backend-architecture.md)
  - [Frontend Architecture (Feature-Sliced Design)](./docs/frontend-architecture.md)
  - [Development Guide](./docs/development.md)
  - [Backend](./docs/backend.md)
  - [Frontend](./docs/frontend.md)
  - [Database](./docs/database.md)
  - [Schema (TypeSpec)](./docs/schema.md)
