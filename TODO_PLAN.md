# フェーズ1 TODO & 実装方針

## フェーズ完了の定義 (Definition of Done)
- 代表的な申請種類（出張申請）の作成→提出→承認→完了までを UI から通しで実行できる。
- 申請タイプ・フォーム・承認フローの版管理が行え、公開版の切替が反映される。
- 申請と承認操作が監査ログ・添付制御付きで永続化され、RBAC に従って参照できる。
- 初期データとセットアップ手順で、新規環境でも 30 分以内に検証フローを再現できる。

## エピック別タスクリスト
### 0. 横断: リポジトリガイド
- [x] `AGENTS.md` を作成し、コントリビューター向けガイドラインを整備済み。

### 1. ドメイン設計・仕様確定
- [ ] 要求と現状ドキュメントの差分精査し、`docs/architecture.md` を更新。
- [ ] 状態遷移図（申請/承認）を `docs/schema.md` に追加。
- [ ] Prisma スキーマ草案を `apps/backend/prisma/schema/` に落とし込み、レビュー。
**Implementation Notes**: バージョン固定の成立条件や差戻しルールを明文化し、ロール/部署の解釈を揃える。

### 2. モノレポ開発基盤
- [ ] `pnpm`/`turbo` スクリプト整理（`pnpm dev`, `pnpm lint`, `pnpm test`）。
- [ ] `.env.example` を整備し、必須環境変数を列挙。
- [ ] `docker-compose.yml` に Postgres + MinIO + Mailhog を追加し、起動検証。
**Implementation Notes**: Turbo パイプラインは `build`, `lint`, `test`, `dev` を定義し、CI で再利用する。

### 3. RBAC / 組織管理
- [ ] Prisma モデルに organizations/departments/users/roles/user_roles を追加し、`pnpm prisma migrate dev` を実行。
- [ ] シードスクリプトでデモ組織・部門・ユーザーを投入（`pnpm backend seed`）。
- [ ] 認証/テナント解決ミドルウェアを Hono に実装（JWT + org header）。
**Implementation Notes**: 承認者判定用に role/dept 解決サービスを用意し、並列承認で利用。

### 4. 申請タイプ・版管理 API
- [ ] `request_types` CRUD と公開切替エンドポイントを実装。
- [ ] `form_definitions`/`flow_definitions` の作成・複製・公開 API を実装。
- [ ] バージョン整合性検証（フォームとフロー版の一致）をサーバサイドで保証。
**Implementation Notes**: JSON Schema 編集向けに Zod スキーマを定義し、バリデーションを共通化。

### 5. 申請作成・提出フロー
- [ ] 下書き保存 API/UI（フォーム定義に基づく動的バリデーション）。
- [ ] 添付アップロード（S3 署名 URL + `attachments` テーブル登録）。
- [ ] 提出処理で `requests` レコード作成、`def_version` 固定、ステータス `in_review` へ遷移。
**Implementation Notes**: 添付上限チェックと不正拡張子拒否をアップロード前後で実施。

### 6. 承認ワークフローエンジン
- [ ] 申請提出時に `request_steps` と `step_assignees` を定義から展開。
- [ ] 承認/却下/差戻し API を実装し、並列ステップで全員承認を評価。
- [ ] `approval_actions` に監査ログを書き込み、差戻し時は理由を必須化。
**Implementation Notes**: `prisma.$transaction` + `SELECT ... FOR UPDATE` 相当で二重承認を防止。差戻し時に `current_step` を更新。

### 7. 申請参照 UI/API
- [ ] 申請者向け一覧・詳細（フィルタ：種類/ステータス/更新日時）。
- [ ] 承認者向け割当一覧（`?assigned=true`）と操作 UI。
- [ ] 管理者向け全件ビューと履歴・添付表示。
**Implementation Notes**: フロントは TanStack Router + Query、詳細表示にタイムラインコンポーネントを利用。

### 8. エラーハンドリング・冪等制御
- [ ] 共通レスポンスフォーマット `{ success, data, error }` を導入。
- [ ] `Idempotency-Key` ヘッダ必須化と `idempotency_keys` 保存ロジックを実装。
- [ ] ドメイン例外 → HTTP 400/403/409 マッピングと UI トースト表示。
**Implementation Notes**: 既存の Hono middleware を拡張してログ関連付け ID を付与。

### 9. 初期データ & デモシナリオ
- [ ] サンプル申請タイプ（出張申請 2 段承認）テンプレートを Seed に追加。
- [ ] デモユーザー（申請者/上長/経理/管理者）の認証情報を `.env.example` に記載。
- [ ] `docs/development.md` にデモ手順（セットアップ→申請完了）を追記。

### 10. 非機能検証・QA
- [ ] k6 などで一覧 API の P95 を計測し、目標値を記録。
- [ ] UI/バックエンドのタイムゾーン表示を `Asia/Tokyo`（例）で統一確認。
- [ ] 回帰テスト（unit, integration, e2e）を整備し、カバレッジ >=85% を検証。

## 依存・要確認事項
- 認証方式の最終決定（既存の ID プロバイダ連携有無）。
- 添付ファイルの保管先（S3 互換で問題ないか、保存期間/暗号化ポリシー）。
- UI デザイン指針（既存デザインシステムやテーマカラーの有無）。
- 通知要件（メール/Slack など）をフェーズ1で求めるかどうか。
