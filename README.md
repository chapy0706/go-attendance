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
- 打刻データはイベント履歴として保存し、表示・集計用の状態はイベントから導出する
- バッチ処理は cmd 配下の別エントリポイントとして分離する
- README・ADR・SpecをSSOTとして、Claude Codeに渡す前提で進める

## 勤怠仕様メモ

現時点での仮決定事項です。詳細な例外ルールや画面/API仕様は docs/specs 配下の仕様書で定義します。

### ユーザー種別

- MVPでは employee / admin の2種類に固定する
- employee は自分の勤怠を確認・操作する
- admin は全ユーザーの勤怠を確認・管理する

### 時刻・勤怠日の扱い

- タイムゾーンは Asia/Tokyo 固定とする
- DBには timestamptz で保存する
- 表示・集計時に Asia/Tokyo へ変換する
- 打刻時刻はサーバー時刻を正とし、クライアント送信時刻は採用しない
- 勤怠日はカレンダー日付を基本とする
- 日をまたぐ勤務は許可し、勤務日は出勤打刻した日とする

### 打刻・勤怠データ

- 勤怠データは attendance_events のような打刻イベント記録モデルを基本とする
- 原則として1勤務につき出勤・退勤は1回ずつとする
- 連勤機能が有効な場合は、同一日に複数勤務を許可する
- 休憩は1勤務内の合計休憩時間として扱う
- 打刻時にはサーバー時刻に加えて、可能な範囲でGPS情報を記録し、不正検知や管理者確認に利用する

### 勤怠一覧・集計

- employee は自分の勤怠を日単位・月単位で確認できる
- admin は全ユーザー横断、ユーザー別、日付範囲指定で勤怠を確認できる
- MVPでも勤務時間・休憩時間などの集計済み表示を行う

## 想定機能

### MVP

- ログイン
- 出勤打刻
- 退勤打刻
- 休憩時間の登録
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
