import { createFileRoute } from "@tanstack/react-router";

export const Route = createFileRoute("/")({
  component: Index,
});

function Index() {
  return (
    <div className="space-y-4">
      <h1 className="text-4xl font-bold">Welcome to Workflow Example</h1>
      <p className="text-muted-foreground">
        This is a monorepo template with React, TanStack Router, Hono, and
        Prisma.
      </p>
    </div>
  );
}
