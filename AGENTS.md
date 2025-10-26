# Repository Guidelines

このリポジトリは申請・承認ワークフローシステムのTypeScript monorepoです。コントリビューター向けのガイドラインを以下に示します。

## Project Structure & Module Organization

```
workflow-example/
├── apps/
│   ├── backend/          # Hono API server (Clean Architecture)
│   │   ├── src/
│   │   │   ├── domain/           # エンティティ、Repository interface
│   │   │   ├── usecase/          # ビジネスロジック
│   │   │   │   ├── query/        # GET - Prisma直接実行可
│   │   │   │   └── command/      # POST/PUT/DELETE - Repository経由のみ
│   │   │   ├── infrastructure/   # Repository実装、外部サービス
│   │   │   └── presentation/     # Controller、ルーティング
│   │   └── prisma/schema/        # Prisma schema（分割管理）
│   ├── frontend/         # React SPA (Feature-Sliced Design)
│   │   ├── src/
│   │   │   ├── routes/           # TanStack Router定義のみ
│   │   │   ├── features/         # 機能ごとのモジュール
│   │   │   ├── components/       # 共通コンポーネント
│   │   │   └── api/             # OpenAPI生成コード
│   └── packages/schema/  # TypeSpec API定義
├── docs/                 # ドキュメント
└── scripts/              # 開発・メンテナンススクリプト
```

### Backend Architecture
- **Clean Architecture**を採用し、レイヤーを明確に分離
- **Query/Command分離**: GETはPrisma直接、変更操作はRepository経由
- 詳細は [docs/backend-architecture.md](docs/backend-architecture.md) を参照

### Frontend Architecture
- **Feature-Sliced Design**を採用し、機能ごとに独立したモジュール
- ルーティングとページ実装を分離
- 詳細は [docs/frontend-architecture.md](docs/frontend-architecture.md) を参照

## Build, Test, and Development Commands

モノレポ管理はTurborepo + pnpmを使用。以下のコマンドをルートディレクトリで実行：

```bash
# 開発サーバー起動（全アプリ並列実行）
pnpm dev

# 個別アプリの起動
cd apps/backend && pnpm dev    # Backend: http://localhost:3001
cd apps/frontend && pnpm dev   # Frontend: http://localhost:3000

# ビルド（依存順に実行）
pnpm build

# Lint
pnpm lint

# Format
pnpm format

# Type check
pnpm typecheck

# Clean
pnpm clean

# Database操作（backendディレクトリから）
cd apps/backend
pnpm db:generate  # Prisma Client生成
pnpm db:push      # スキーマをDBへpush（開発）
pnpm db:migrate   # マイグレーション作成（本番）
pnpm db:studio    # Prisma Studio起動
pnpm db:seed      # シードデータ投入
```

## Coding Style & Naming Conventions

### TypeScript
- **Node.js**: 20以上
- **Package Manager**: pnpm 9以上
- **インデント**: 2スペース
- **命名規則**:
  - ファイル・ディレクトリ: kebab-case (`user-repository.ts`)
  - 変数・関数: camelCase (`getUserById`)
  - クラス・型: PascalCase (`UserRepository`, `CreateUserRequest`)
  - 定数: UPPER_SNAKE_CASE (`MAX_FILE_SIZE`)

### Backend Specific
- Domain層は外部依存禁止
- Command UseCaseはPrisma直接アクセス禁止
- Repository interfaceは必ずDomain層に定義
- エラーはドメイン例外をthrowし、Presentation層でHTTPステータスに変換

### Frontend Specific
- routes/はルーティング定義のみ、実装はfeatures/に配置
- 機能間の直接importは禁止、共通化はcomponents/経由
- API呼び出しはapi/client.ts経由
- React Queryでサーバー状態管理

### Code Quality Tools
- **ESLint**: TypeScript + React Hooks ルール
- **Biome**: フォーマット + Lint
- **Prettier**: マークダウン等のフォーマット
- **TypeScript**: strict mode有効

設定ファイル:
- `eslint.config.js` (Flat config)
- `biome.json`
- `tsconfig.json` (各アプリ)

## Testing Guidelines

### テストフレームワーク
- **Vitest**: Backend + Frontend両対応
- **React Testing Library**: Frontendコンポーネントテスト
- **Playwright**: E2Eテスト（将来追加予定）

### テストファイル配置
```
src/
├── domain/
│   └── entities/
│       ├── User.ts
│       └── User.test.ts         # 同じディレクトリにテストを配置
├── usecase/
│   └── command/
│       ├── createUser.ts
│       └── createUser.test.ts
```

### テスト実行
```bash
# 全テスト実行
pnpm test

# Watch mode
pnpm test:watch

# Coverage
pnpm test:coverage

# 目標カバレッジ: ≥85%
```

### テスト作成ガイドライン
- ファイル名: `*.test.ts` または `*.spec.ts`
- Domain層のテストは外部依存なしで実行可能に
- Repository実装はインメモリ実装でテスト
- UseCaseはRepository mockを使用
- Controllerは統合テストで検証

## Commit & Pull Request Guidelines

### Commit Message
Conventional Commitsに従う:
```
feat: add user authentication
fix: resolve approval step calculation bug
chore: update dependencies
docs: add workflow state diagram
test: add tests for createUser usecase
refactor: extract validation logic to domain service
```

- **Type**: feat, fix, chore, docs, test, refactor, style, perf
- **Scope**: (optional) affected module
- **Message**: 72文字以内、命令形、小文字始まり

### Pull Request
1. **ブランチ命名**: `feat/user-auth`, `fix/approval-bug`
2. **PRテンプレート**:
   ```markdown
   ## 概要
   （変更内容の簡潔な説明）

   ## 変更詳細
   - 変更点1
   - 変更点2

   ## テスト
   - [ ] pnpm test 成功
   - [ ] pnpm lint 成功
   - [ ] 手動テスト完了

   ## 関連Issue
   Closes #123
   ```
3. **レビュー前チェック**:
   - `pnpm lint` 成功
   - `pnpm typecheck` 成功
   - `pnpm test` 成功
   - Huskyのpre-commit hook通過

### Pre-commit Hooks (Husky + lint-staged)
コミット時に自動実行:
- ESLint --fix
- Biome format --write
- TypeScript type check

## Security & Configuration Tips

### 環境変数管理
- **絶対禁止**: `.env`ファイルのコミット
- **必須**: `.env.example`に必要な変数を記載
- **命名規則**:
  - Backend: `DATABASE_URL`, `BACKEND_PORT`, `JWT_SECRET`
  - Frontend: `VITE_API_URL`, `VITE_*`（Viteプレフィックス必須）

### シークレット管理
- JWT_SECRET, API_KEY等は`.env`のみに記載
- 本番環境は環境変数またはシークレット管理サービス使用
- `.gitignore`に`.env`が含まれていることを確認

### 依存関係管理
- `pnpm-lock.yaml`を必ずコミット
- 依存関係更新はPR単位で実施
- セキュリティアラートは優先対応

## Database Management

### Prisma Schema
- スキーマは`apps/backend/prisma/schema/`に分割管理
- `schema/schema.prisma`: generator/datasource定義
- `schema/*.prisma`: モデル定義（テーブルごと）

### Migration Workflow
```bash
# 開発環境
cd apps/backend
pnpm db:push              # スキーマをDBに反映（マイグレーション不要）

# 本番環境
pnpm db:migrate           # マイグレーション作成
git add prisma/migrations
git commit -m "feat: add organizations table"

# デプロイ時
npx prisma migrate deploy # マイグレーション適用
```

### Seed Data
```bash
cd apps/backend
pnpm db:seed              # シードデータ投入
```

## Documentation

### ドキュメント体系
- **CLAUDE.md**: AI向けクイックリファレンス
- **README.md**: プロジェクト概要、クイックスタート
- **docs/**: 詳細ドキュメント
  - `architecture.md`: プロジェクト全体構造
  - `backend-architecture.md`: バックエンド設計
  - `frontend-architecture.md`: フロントエンド設計
  - `database-schema.md`: データベース設計
  - `workflow-states.md`: 状態遷移図
  - `development.md`: 開発手順
  - `backend.md`, `frontend.md`: 技術詳細

### ドキュメント更新タイミング
- アーキテクチャ変更時は必ず更新
- 新機能追加時は該当ドキュメントに追記
- Breaking changesは必ず文書化

## Additional Resources

- [Turborepo Documentation](https://turbo.build/repo/docs)
- [Hono Documentation](https://hono.dev/)
- [Prisma Documentation](https://www.prisma.io/docs)
- [TanStack Router Documentation](https://tanstack.com/router/latest)
- [Biome Documentation](https://biomejs.dev/)
