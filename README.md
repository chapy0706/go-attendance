# go-attendance

勤怠打刻アプリを題材に、Go + PostgreSQL + Next.js を用いて、業務ロジック・責務分離・型安全なDBアクセス・テスト・本番デプロイを学習するためのポートフォリオプロジェクトです。

## 目的

このプロジェクトでは、Spring Bootのような包括的フレームワークに依存せず、Goの小さな標準機能と明示的なレイヤード設計を用いてバックエンドを構築します。

目的は、認証・認可、DBトランザクション、打刻ルール、集計バッチ、マイグレーション、テストの責務を自分で設計し、説明できる状態にすることです。

## 技術スタック

### Frontend

- Next.js
- TypeScript
- Zod
- TanStack Query
- Playwright

### Backend

- Go
- net/http または chi
- sqlc
- pgx
- OpenAPI
- Testcontainers for Go

### Database

- PostgreSQL
- Neon PostgreSQL

### Migration

- golang-migrate または goose

### Deploy

- Frontend: Vercel
- Backend: Render
- Database: Neon PostgreSQL

## アーキテクチャ方針

- Domain / UseCase / Port / Adapter を分離する
- Domain と UseCase は HTTP・DB・認証実装に依存しない
- SQLはORMで隠さず、sqlcで型安全に扱う
- 時刻処理は Clock interface を通してテスト可能にする
- バッチ処理は cmd 配下の別エントリポイントとして分離する
- README・ADR・SpecをSSOTとして、Claude Codeに渡す前提で進める

## 想定機能

### MVP

- ユーザー登録・ログイン
- 出勤打刻
- 退勤打刻
- 休憩開始
- 休憩終了
- 自分の勤怠一覧
- 管理者による勤怠一覧確認

### 次フェーズ

- 勤怠修正申請
- 承認・却下
- 監査ログ
- 日次集計
- 月次締め
- CSV出力
- バッチ処理
- 管理者ダッシュボード

## 初期ディレクトリ構成

```txt
attendance-app/
├── apps/
│   ├── web/
│   └── api/
├── db/
│   ├── migrations/
│   └── queries/
├── docs/
│   ├── adr/
│   ├── specs/
│   └── api/
├── e2e/
├── .claude/
├── Makefile
├── docker-compose.yml
└── README.md
```

## 開発原則

- 小さく始める
- 仕様を先に書く
- 実装より先に境界を決める
- AI生成コードは必ず人間がレビューする
- 認証・認可・時刻・DB更新は雑に扱わない
- make verify が通る状態を維持する

## Goを選んだ理由

このプロジェクトでは、あえてSpring Bootのような包括的フレームワークを使わず、Goを採用します。

理由は、フレームワークに隠れやすい認証・DBアクセス・トランザクション・エラーハンドリング・バッチ処理を、自分で設計し理解するためです。

Goは言語仕様がシンプルで、過剰な抽象化を避けやすく、Claude Codeと並走しても構造が崩れにくいと考えています。

## 開発ステータス

現在は初期設計フェーズです。

- [ ] README作成
- [ ] Claude Code作業規約作成
- [ ] 仕様書テンプレート作成
- [ ] ADR作成
- [ ] ディレクトリ初期化
- [ ] Go APIのHello World
- [ ] DB接続
- [ ] 初回マイグレーション

