---
status: open
created_at: 2025-05-08
closed_at:
---

# Next.js をセットアップして認証画面を実装する

## 概要

Next.js (App Router) プロジェクトを初期化し、
Clerk を使ったログイン・ログアウト画面を実装する。

## 背景

バックエンドの打刻 API（0012）が動作する状態になったため、
フロントエンドの基盤を整備して画面から操作できるようにする。

## refs

- docs/adr/003-use-clerk-as-primary-auth.md（0004 で作成）
- README.md（Frontend セクション）

## 実装スコープ

| ファイル | 操作 | 内容 |
|---|---|---|
| apps/web/package.json | 更新 | Next.js・Clerk SDK・Zod・TanStack Query 追加 |
| apps/web/app/layout.tsx | 新規 | ClerkProvider ラップ |
| apps/web/app/sign-in/page.tsx | 新規 | Clerk SignIn コンポーネント |
| apps/web/app/page.tsx | 新規 | ログイン後リダイレクト先 |
| apps/web/middleware.ts | 新規 | Clerk 認証ミドルウェア |
| apps/web/lib/api-client.ts | 新規 | API クライアント基盤（Bearer トークン付与） |

## 完了条件

- [ ] `pnpm dev` で Next.js が起動する
- [ ] Clerk のサインイン画面が表示される
- [ ] ログイン後に /dashboard にリダイレクトされる
- [ ] 未認証時に /sign-in にリダイレクトされる
- [ ] api-client.ts が Clerk の getToken() で Bearer トークンを取得して付与する
- [ ] make verify が通る

## 禁止事項

- Clerk の JWT をクライアント側でデコードしてロール判定しない（ロールはバックエンドで判定）
- .env.local に実際のシークレットを Git にコミットしない

## メモ

NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY / CLERK_SECRET_KEY は .env.example に追記する。
