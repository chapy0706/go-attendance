---
status: open
created_at: 2025-05-08
closed_at:
---

# デプロイ設定を整備する（Render・Vercel・Neon）

## 概要

Render（バックエンド）・Vercel（フロントエンド）・Neon PostgreSQL（DB）の
デプロイ設定を整備し、本番相当環境で動作確認する。

## 背景

ポートフォリオとして公開するために、
実際に動くデモ環境を用意する必要がある。

## refs

- README.md（Deploy セクション）

## 実装スコープ

| ファイル | 操作 | 内容 |
|---|---|---|
| apps/api/Dockerfile | 新規 | Go API のコンテナイメージ |
| render.yaml | 新規 | Render デプロイ設定 |
| apps/web/vercel.json | 新規 | Vercel デプロイ設定 |
| .github/workflows/deploy.yml | 新規 | CI/CD（main マージ時に自動デプロイ） |
| Makefile | 更新 | make deploy/check ターゲット追加 |

## 完了条件

- [ ] Dockerfile が `docker build` でエラーなく通る
- [ ] Render に Go API がデプロイされている
- [ ] Vercel に Next.js がデプロイされている
- [ ] Neon PostgreSQL にマイグレーションが適用されている
- [ ] デプロイ済み環境で出勤・退勤打刻が動作する
- [ ] HTTPS で公開されている
- [ ] make verify が通る

## 禁止事項

- シークレット（API キー・DB 接続情報）をコードにハードコードしない
- Dockerfile に .env を COPY しない

## メモ

GitHub Actions の Secrets に以下を登録する。
- RENDER_API_KEY
- NEON_DATABASE_URL
- CLERK_SECRET_KEY
- NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY

デモ用 URL を README に追記する。
