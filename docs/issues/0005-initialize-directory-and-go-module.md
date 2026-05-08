---
status: open
created_at: 2025-05-08
closed_at:
---

# ディレクトリ構成・Go module を初期化する

## 概要

README に記載された初期ディレクトリ構成を作成し、
Go module・pnpm workspace・docker-compose の初期設定を行う。

## 背景

後続 Issue の実装がすべてこの構成を前提にする。
先にディレクトリ構成とモジュール定義を確定させることで、
Claude Code がファイル配置を迷わないようにする。

## refs

- README.md（初期ディレクトリ構成 セクション）
- docs/adr/004-use-append-only-attendance-events.md（0004 で作成）

## 実装スコープ

| ファイル | 操作 | 内容 |
|---|---|---|
| apps/api/go.mod | 新規 | Go module 定義 |
| apps/api/cmd/app/main.go | 新規 | エントリポイント（Hello World レベル） |
| apps/api/internal/domain/.gitkeep | 新規 | ディレクトリ保持 |
| apps/api/internal/usecase/.gitkeep | 新規 | ディレクトリ保持 |
| apps/api/internal/port/.gitkeep | 新規 | ディレクトリ保持 |
| apps/api/internal/adapter/.gitkeep | 新規 | ディレクトリ保持 |
| apps/web/package.json | 新規 | Next.js プロジェクト定義 |
| db/migrations/.gitkeep | 新規 | ディレクトリ保持 |
| db/queries/.gitkeep | 新規 | ディレクトリ保持 |
| docker-compose.yml | 新規 | PostgreSQL ローカル開発環境 |
| .env.example | 新規 | 環境変数サンプル（実値なし） |

## 完了条件

- [ ] README 記載のディレクトリ構成がすべて作成されている
- [ ] `go mod tidy` がエラーなく通る
- [ ] `go run ./apps/api/cmd/app` でサーバーが起動する（Hello World レベルで可）
- [ ] `docker compose up -d` で PostgreSQL が起動する
- [ ] .env.example に DATABASE_URL / PORT が含まれている
- [ ] .env* が .gitignore に含まれている
- [ ] make verify が通る

## 禁止事項

- .env に実際のシークレットを書かない
- apps/api/internal/ 配下に業務ロジックをまだ書かない（次 Issue 以降）

## メモ

Go のモジュール名は `github.com/{org}/attendance-app/apps/api` を想定。
実際のリポジトリ名に合わせて変更すること。
