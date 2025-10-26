# Frontend Architecture

フロントエンドはFeature-Sliced Designを採用し、機能ごとにモジュールを分離しています。

## ディレクトリ構造

```
apps/frontend/src/
├── routes/           # TanStack Router - ルーティング定義のみ
├── features/         # Feature-Sliced Design - 機能ごとのモジュール
├── api/             # TypeSpec/OpenAPIから生成されたAPIクライアント
├── components/       # 共通コンポーネント
└── lib/             # ユーティリティ関数
```

## レイヤーの責務

### Routes (`routes/`)

TanStack Routerのルーティング定義のみ。

**原則:**
- 具体的なページの実装はしない
- ルート定義とレイアウトのみ
- 実際のUI実装は `features/` で行う

**構成:**
```
routes/
├── __root.tsx          # ルートレイアウト
├── index.tsx           # / - ホーム
├── about.tsx           # /about
└── users/
    ├── index.tsx       # /users - ユーザー一覧
    └── $id.tsx         # /users/:id - ユーザー詳細
```

**例:**
```tsx
// routes/users/index.tsx
import { createFileRoute } from "@tanstack/react-router";
import { UsersPage } from "@/features/users/pages/UsersPage";

export const Route = createFileRoute("/users/")({
  component: UsersPage,
  // ローダーでデータ取得も可能
  loader: async () => {
    // ...
  },
});
```

### Features (`features/`)

機能ごとにディレクトリを分けるFeature-Sliced Design。

**原則:**
- 各機能は独立している
- 他の機能のコンポーネントを直接importしない
- 共通化が必要なものは `/components` に移動

**機能ごとの構成:**
```
features/
├── users/                  # ユーザー機能
│   ├── components/         # この機能専用のコンポーネント
│   │   ├── UserCard.tsx
│   │   ├── UserList.tsx
│   │   └── UserForm.tsx
│   ├── pages/              # ページコンポーネント
│   │   ├── UsersPage.tsx
│   │   └── UserDetailPage.tsx
│   ├── hooks/              # カスタムフック
│   │   ├── useUser.ts
│   │   └── useUsers.ts
│   ├── types/              # 型定義
│   │   └── user.ts
│   └── api/                # API呼び出し（この機能専用）
│       └── userApi.ts
├── posts/                  # 投稿機能
│   ├── components/
│   ├── pages/
│   ├── hooks/
│   └── api/
└── auth/                   # 認証機能
    ├── components/
    ├── pages/
    └── hooks/
```

**例:**
```tsx
// features/users/pages/UsersPage.tsx
import { UserList } from "../components/UserList";
import { useUsers } from "../hooks/useUsers";

export function UsersPage() {
  const { users, isLoading } = useUsers();

  if (isLoading) return <div>Loading...</div>;

  return (
    <div>
      <h1>Users</h1>
      <UserList users={users} />
    </div>
  );
}

// features/users/hooks/useUsers.ts
import { useQuery } from "@tanstack/react-query";
import { fetchUsers } from "../api/userApi";

export function useUsers() {
  const { data, isLoading } = useQuery({
    queryKey: ["users"],
    queryFn: fetchUsers,
  });

  return {
    users: data ?? [],
    isLoading,
  };
}

// features/users/api/userApi.ts
import { apiClient } from "@/api/client";

export async function fetchUsers() {
  const response = await apiClient.get("/users");
  return response.data.users;
}
```

### API (`api/`)

TypeSpec/OpenAPIから生成されたAPIクライアント。

**構成:**
```
api/
├── generated/          # 自動生成（編集禁止）
│   ├── client.ts
│   ├── types.ts
│   └── endpoints.ts
└── client.ts           # APIクライアント設定
```

**使い方:**
```typescript
// api/client.ts
import axios from "axios";

export const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_URL,
  headers: {
    "Content-Type": "application/json",
  },
});

// リクエスト/レスポンスインターセプター
apiClient.interceptors.request.use((config) => {
  const token = localStorage.getItem("token");
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});
```

**features内での使用:**
```typescript
// features/users/api/userApi.ts
import { apiClient } from "@/api/client";
import type { User } from "@/api/generated/types";

export async function fetchUsers(): Promise<User[]> {
  const response = await apiClient.get("/users");
  return response.data.users;
}

export async function createUser(data: {
  email: string;
  name?: string;
}): Promise<User> {
  const response = await apiClient.post("/users", data);
  return response.data;
}
```

### Components (`components/`)

アプリケーション全体で共有される共通コンポーネント。

**構成:**
```
components/
├── ui/                 # shadcn/ui生成コンポーネント
│   ├── button.tsx
│   ├── card.tsx
│   ├── dialog.tsx
│   └── input.tsx
├── layout/             # レイアウト
│   ├── Header.tsx
│   ├── Footer.tsx
│   └── Sidebar.tsx
└── common/             # その他共通コンポーネント
    ├── LoadingSpinner.tsx
    ├── ErrorBoundary.tsx
    └── Pagination.tsx
```

**原則:**
- 複数の機能で使われるもののみ
- 特定機能専用は `features/` に配置
- shadcn/uiは `ui/` に自動生成

**例:**
```tsx
// components/layout/Header.tsx
import { Link } from "@tanstack/react-router";

export function Header() {
  return (
    <header className="border-b">
      <nav className="container mx-auto p-4">
        <Link to="/">Home</Link>
        <Link to="/users">Users</Link>
        <Link to="/about">About</Link>
      </nav>
    </header>
  );
}
```

## データフロー

```
User Action → Route
             ↓
           Page (features/*/pages/)
             ↓
           Hooks (features/*/hooks/)
             ↓
           API (features/*/api/)
             ↓
           API Client (api/client.ts)
             ↓
           Backend
```

## 状態管理

### Server State
- **React Query** (@tanstack/react-query) を使用
- サーバーデータのキャッシング、再取得、同期

```tsx
// features/users/hooks/useUser.ts
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { fetchUser, updateUser } from "../api/userApi";

export function useUser(id: string) {
  return useQuery({
    queryKey: ["users", id],
    queryFn: () => fetchUser(id),
  });
}

export function useUpdateUser() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: updateUser,
    onSuccess: (data) => {
      queryClient.invalidateQueries({ queryKey: ["users"] });
      queryClient.setQueryData(["users", data.id], data);
    },
  });
}
```

### Client State
- 軽量な状態: useState, useReducer
- 複雑なグローバル状態: Context API or Zustand

## 実装時の注意点

### Route実装時
- ルート定義のみに専念
- ページコンポーネントは `features/` から import
- データローダーは必要に応じて使用

### Feature実装時
- 機能は独立して実装
- 他の機能への依存は `components/` や `api/` 経由のみ
- 関連するコードは同じfeatureディレクトリに配置

### API呼び出し実装時
- `api/client.ts` を経由
- 型は `api/generated/types` から import
- エラーハンドリングは統一的に実装

### コンポーネント実装時
- 再利用可能性を考慮
- Propsは明確に型定義
- shadcn/uiコンポーネントを活用
