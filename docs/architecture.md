# Architecture

## System Overview

このプロジェクトは**申請・承認ワークフローシステム**です。組織内での各種申請（出張申請、経費申請、休暇申請など）の作成から承認完了までのプロセスを管理します。

### 主要機能
1. **申請タイプ管理**: 申請種類ごとにフォーム定義と承認フロー定義を版管理
2. **申請作成**: 動的フォームによる申請データ入力、下書き保存、添付ファイルアップロード
3. **承認ワークフロー**: 多段階・並列承認、差戻し、監査ログ記録
4. **RBAC**: 組織・部門・ロールベースのアクセス制御
5. **版管理**: 申請提出時に使用したフォーム・フロー定義を固定し、後の変更の影響を受けない

### 主要ドメイン

#### 申請タイプ管理
- **request_types**: 申請種類（出張申請、経費申請など）
- **form_definitions**: JSON Schemaベースのフォーム定義（版管理）
- **flow_definitions**: 承認フロー定義（ステップ、担当ロール、並列/順次）（版管理）

#### 申請・承認プロセス
- **requests**: 申請レコード（申請者、ステータス、使用した定義版番号）
- **request_steps**: 申請ごとの承認ステップインスタンス
- **step_assignees**: ステップ担当者（ロール解決結果）
- **approval_actions**: 承認・却下・差戻しアクション（監査ログ）

#### 組織・ユーザー管理
- **organizations**: 組織・テナント
- **departments**: 部門
- **users**: ユーザー
- **roles**: ロール定義
- **user_roles**: ユーザーとロールの紐付け

#### 添付ファイル管理
- **attachments**: 添付ファイルメタデータ（S3/MinIOへの参照）

### アーキテクチャ方針

#### Query/Command分離 (CQRS-lite)
- **Query (UseCase/Query)**: 読み取り専用、Prisma Client直接実行、パフォーマンス重視
- **Command (UseCase/Command)**: データ変更、Repository経由、ビジネスロジック実行、トランザクション管理

#### 版管理とバージョン固定
- フォーム定義・フロー定義は版番号で管理（version列）
- 各申請タイプは「公開版」を持つ（published_form_version, published_flow_version）
- 申請提出時に公開版の番号を固定保存（requests.def_versionフィールド）
- 定義の後続変更は過去の申請に影響しない

#### 監査ログ・冪等性
- すべての承認アクションをapproval_actionsに記録（誰が・いつ・何を・理由）
- 重要な変更操作はIdempotency-Keyヘッダー必須化で二重実行防止
- タイムゾーンはUTCで保存、表示時にユーザー設定に変換

## Project Structure

```
workflow-example/
├── apps/
│   ├── backend/          # Hono API server
│   │   ├── src/
│   │   │   └── index.ts  # Main entry point
│   │   ├── prisma/
│   │   │   └── schema.prisma
│   │   └── vite.config.ts
│   └── frontend/         # React SPA
│       ├── src/
│       │   ├── routes/   # TanStack Router file-based routing
│       │   ├── components/ (created via shadcn/ui CLI)
│       │   └── lib/
│       └── vite.config.ts
├── packages/
│   └── schema/           # TypeSpec API definitions
│       ├── main.tsp
│       └── tspconfig.yaml
├── docs/                 # Documentation
└── docker-compose.yml    # PostgreSQL
```

## Backend (apps/backend)

- **Framework**: Hono - lightweight, fast web framework
- **Build**: Vite builds as ES module targeting Node.js 20
- **Database**: Prisma ORM for type-safe database access
- **Entry**: `src/index.ts` exports Hono app with `fetch` handler
- **CORS**: Configured to allow frontend connections

## Frontend (apps/frontend)

- **Routing**: TanStack Router with file-based routing
  - `__root.tsx`: Root layout
  - `index.tsx`: Home page (/)
  - `about.tsx`: About page (/about)
  - Auto-generated: `src/routeTree.gen.ts`
- **Styling**: Tailwind CSS + shadcn/ui components
- **Path Aliases**: `@/*` → `./src/*`

## Schema (packages/schema)

- **Purpose**: Define API contracts using TypeSpec
- **Output**: OpenAPI 3.0 spec at `dist/openapi.yaml`
- **Workflow**: Edit `main.tsp` → build → use spec for docs/codegen
- **Integration**: Backend implements API, frontend can consume types

## Monorepo Management

- **Turborepo**: Task orchestration with caching
  - `turbo.json` defines task dependencies
  - Parallel execution for `dev`, sequential for `build`
- **pnpm workspaces**: Package linking and dependency management
- **Naming**: All packages use `@workflow-example/*` scope

## Code Quality

- **ESLint**: Flat config (eslint.config.js) with TypeScript + React rules
- **Biome**: Fast formatter and linter
- **Husky + lint-staged**: Pre-commit hooks for auto-fix/format
