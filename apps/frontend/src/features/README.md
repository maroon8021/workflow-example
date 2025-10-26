# Features

機能ごとにディレクトリを分けて実装する、いわゆるFeature-Sliced Design。

## 構成

各機能ごとにディレクトリを作成:

```
features/
├── users/
│   ├── components/     # この機能専用のコンポーネント
│   ├── pages/          # ページコンポーネント
│   ├── hooks/          # カスタムフック
│   ├── types/          # 型定義
│   └── api/            # API呼び出し（この機能専用）
├── posts/
│   ├── components/
│   ├── pages/
│   ├── hooks/
│   └── types/
└── auth/
    ├── components/
    ├── pages/
    └── hooks/
```

## 例

```
features/users/
├── components/
│   ├── UserCard.tsx
│   └── UserList.tsx
├── pages/
│   ├── UsersPage.tsx
│   └── UserDetailPage.tsx
├── hooks/
│   └── useUser.ts
└── api/
    └── userApi.ts
```

## 原則

- 各機能は独立している
- 他の機能のコンポーネントを直接importしない
- 共通化が必要なコンポーネントは `/components` に移動
