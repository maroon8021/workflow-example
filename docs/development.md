# Development Guide

## Initial Setup

```bash
# 1. Install dependencies
pnpm install

# 2. Start PostgreSQL
docker compose up -d

# 3. Copy environment files
cp .env.example .env
cp apps/backend/.env.example apps/backend/.env
cp apps/frontend/.env.example apps/frontend/.env

# 4. Setup Husky
pnpm prepare

# 5. Generate Prisma client
cd apps/backend && pnpm db:generate

# 6. Push schema to database
cd apps/backend && pnpm db:push
```

## Daily Workflow

```bash
# Start all development servers (parallel)
pnpm dev

# Or start individually
cd apps/backend && pnpm dev   # http://localhost:3001
cd apps/frontend && pnpm dev  # http://localhost:3000

# Build all apps
pnpm build

# Type check all code
pnpm typecheck

# Lint and format
pnpm lint
pnpm format
```

## Adding Packages

```bash
# To workspace root (shared dev dependencies)
pnpm add -Dw <package>

# To specific app
pnpm add --filter @workflow-example/backend <package>
pnpm add --filter @workflow-example/frontend <package>
pnpm add --filter @workflow-example/schema <package>
```

## Environment Variables

All apps have `.env.example` files. Copy and modify as needed:

- **Root `.env`**: Shared variables
- **Backend `.env`**: `DATABASE_URL`, `BACKEND_PORT`
- **Frontend `.env`**: `VITE_API_URL`
