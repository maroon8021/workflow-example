# Components

アプリケーション全体で共有される共通コンポーネント。

## 構成

```
components/
├── ui/                 # shadcn/uiで生成されたコンポーネント
│   ├── button.tsx
│   ├── card.tsx
│   └── dialog.tsx
├── layout/             # レイアウト関連
│   ├── Header.tsx
│   ├── Footer.tsx
│   └── Sidebar.tsx
└── common/             # その他の共通コンポーネント
    ├── LoadingSpinner.tsx
    └── ErrorBoundary.tsx
```

## 原則

- 複数の機能で使われるコンポーネントのみ配置
- 特定の機能専用のコンポーネントは `features/` に配置
- shadcn/uiのコンポーネントは `ui/` サブディレクトリに自動生成される
