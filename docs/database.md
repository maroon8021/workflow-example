# Database

## PostgreSQL Setup

PostgreSQL 17 runs in Docker via `docker-compose.yml`.

```bash
# Start database
docker compose up -d

# Stop database
docker compose down

# View logs
docker compose logs -f postgres

# Connect via psql
docker compose exec postgres psql -U postgres -d workflow_example
```

## Schema Structure

Prisma schema is split across multiple files in `apps/backend/prisma/schema/`:

- `schema/schema.prisma` - Generator and datasource configuration
- `schema/user.prisma` - User model
- Add more model files as needed (e.g., `post.prisma`, `comment.prisma`)

This uses Prisma's `prismaSchemaFolder` preview feature for better organization.

### Current Models

**User** (`schema/user.prisma`):
```prisma
model User {
  id        String   @id @default(cuid())
  email     String   @unique
  name      String?
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}
```

## Modifying Schema

1. Edit files in `apps/backend/prisma/schema/` directory
   - Add new models in separate files (e.g., `schema/post.prisma`)
   - Modify existing models in their respective files
2. Generate Prisma Client: `cd apps/backend && pnpm db:generate`
3. Apply changes:
   - **Development**: `pnpm db:push`
   - **Production**: `pnpm db:migrate`

## Prisma Commands

```bash
cd apps/backend

# Generate Prisma Client (after schema changes)
pnpm db:generate

# Push schema to DB (dev only, no migration files)
pnpm db:push

# Create migration (production workflow)
pnpm db:migrate

# Open Prisma Studio (database GUI)
pnpm db:studio
```

## Database Credentials

Default credentials (from `docker-compose.yml`):
- **User**: postgres
- **Password**: postgres
- **Database**: workflow_example
- **Port**: 5432

Connection string:
```
postgresql://postgres:postgres@localhost:5432/workflow_example?schema=public
```

Set in `apps/backend/.env` as `DATABASE_URL`.
