# Backend (apps/backend)

## Tech Stack

- **Framework**: Hono
- **Build Tool**: Vite
- **ORM**: Prisma
- **Database**: PostgreSQL 17
- **Runtime**: Node.js 20+

## Entry Point

`src/index.ts` exports a default object with:
- `port`: Server port (from `BACKEND_PORT` env var, default 3001)
- `fetch`: Hono's request handler

## Prisma Workflow

Schema files are in `prisma/schema/` directory:
- `schema/schema.prisma` - Generator and datasource config
- `schema/user.prisma` - User model
- Add more model files as needed

### Development
```bash
cd apps/backend

# After editing files in prisma/schema/
pnpm db:generate  # Regenerate Prisma Client
pnpm db:push      # Push schema to database (no migration files)

# Open database GUI
pnpm db:studio
```

### Production
```bash
cd apps/backend

# Create migration
pnpm db:migrate

# Apply migrations (in deployment)
npx prisma migrate deploy
```

## Adding API Endpoints

1. Define route in `src/index.ts`
2. Update TypeSpec definition in `packages/schema/main.tsp`
3. Rebuild schema: `cd packages/schema && pnpm build`

## CORS Configuration

CORS is enabled for all routes via `app.use("/*", cors())` in `src/index.ts`.
Modify as needed for production.
