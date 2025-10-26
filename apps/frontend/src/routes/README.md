# Routes

TanStack Routerのルーティング定義のみを配置。

## 原則

- **具体的なページの実装はしない**
- ルートの定義とレイアウトのみ
- 実際のUI実装は `features/` に配置

## 構成

```
routes/
├── __root.tsx          # ルートレイアウト
├── index.tsx           # / - ホームページのルート定義のみ
├── about.tsx           # /about
└── users/
    ├── index.tsx       # /users
    └── $id.tsx         # /users/:id
```

## サンプルコード

```tsx
// routes/users/index.tsx
import { createFileRoute } from "@tanstack/react-router";
import { UsersPage } from "@/features/users/pages/UsersPage";

export const Route = createFileRoute("/users/")({
  component: UsersPage,
});
```

ページの実装は `features/users/pages/UsersPage.tsx` で行う。
