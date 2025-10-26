# Frontend (apps/frontend)

## Tech Stack

- **Framework**: React 18
- **Router**: TanStack Router
- **Styling**: Tailwind CSS
- **UI Components**: shadcn/ui
- **Build Tool**: Vite

## Routing

### File-Based Routes

Routes are defined in `src/routes/`:
- `__root.tsx` - Root layout (navigation, outlet)
- `index.tsx` - Home page at `/`
- `about.tsx` - About page at `/about`

Route tree is auto-generated at `src/routeTree.gen.ts` by TanStack Router plugin.

### Adding New Routes

Create a new file in `src/routes/`:
```tsx
// src/routes/example.tsx
import { createFileRoute } from "@tanstack/react-router";

export const Route = createFileRoute("/example")({
  component: Example,
});

function Example() {
  return <div>Example Page</div>;
}
```

## Styling

### Tailwind CSS

Configuration: `tailwind.config.js`
- CSS variables for theming (light/dark mode)
- shadcn/ui integration

### shadcn/ui Components

Add components via CLI:
```bash
cd apps/frontend
npx shadcn@latest add button
npx shadcn@latest add card
npx shadcn@latest add dialog
```

Components are added to `src/components/ui/`.

Configuration: `components.json`

### Utility Function

`src/lib/utils.ts` provides `cn()` for conditional class merging:
```tsx
import { cn } from "@/lib/utils";

<div className={cn("base-class", condition && "conditional-class")} />
```

## API Calls

Use `VITE_API_URL` environment variable:
```tsx
const response = await fetch(`${import.meta.env.VITE_API_URL}/endpoint`);
```
