# TypeSpec Schema

## Purpose

TypeSpec provides schema-driven API development:
- Define API contracts in `packages/schema/main.tsp`
- Generate OpenAPI 3.0 specification
- Use spec for documentation, validation, and client generation

## Workflow

```bash
cd packages/schema

# Build OpenAPI spec (outputs to dist/openapi.yaml)
pnpm build

# Watch mode for continuous generation
pnpm watch
```

## Current API Definition

`main.tsp` defines:
- Service metadata (title, server URL)
- Root endpoints: `/`, `/health`
- User endpoints: `/users/*`

### Example: Adding New Endpoint

```typescript
@route("/posts")
namespace Posts {
  model Post {
    id: string;
    title: string;
    content: string;
    authorId: string;
  }

  @get
  op listPosts(): {
    @statusCode statusCode: 200;
    @body body: {
      posts: Post[];
    };
  };
}
```

After editing:
1. Run `pnpm build` to generate OpenAPI spec
2. Implement endpoint in `apps/backend/src/index.ts`
3. (Optional) Generate client code from `dist/openapi.yaml`

## Configuration

`tspconfig.yaml`:
- Emitter: `@typespec/openapi3`
- Output: `dist/openapi.yaml`
- Options: `omit-unreachable-types: true`

## Integration

- **Backend**: Implement routes matching TypeSpec definitions
- **Frontend**: Can generate typed API client from OpenAPI spec
- **Documentation**: Use OpenAPI spec with Swagger UI, Redoc, etc.
