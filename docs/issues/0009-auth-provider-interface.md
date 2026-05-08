---
status: open
created_at: 2025-05-08
closed_at:
---

# 認証基盤を実装する（AuthProvider interface・Clerk adapter）

## 概要

AuthProvider interface を定義し、Clerk を使った実装と HTTP ミドルウェアを作成する。
Domain / UseCase が認証プロバイダに直接依存しない構造を確立する。

## 背景

打刻 API（0010 以降）が認証済みユーザー ID を必要とする。
Clerk への直接依存を避けるため、Port 層に AuthProvider interface を置き、
Clerk 実装を Adapter 層に閉じ込める構造を先に作る。

## refs

- docs/adr/003-use-clerk-as-primary-auth.md（0004 で作成）
- docs/specs/active/0001-domain-rules.md（0006 で作成）
- README.md（認証 セクション）

## 実装スコープ

| ファイル | 操作 | 内容 |
|---|---|---|
| apps/api/internal/port/auth.go | 新規 | AuthProvider interface 定義 |
| apps/api/internal/adapter/clerk/auth_provider.go | 新規 | Clerk を使った AuthProvider 実装 |
| apps/api/internal/adapter/handler/middleware/auth.go | 新規 | 認証ミドルウェア（context に UserID を載せる） |
| apps/api/internal/adapter/handler/context.go | 新規 | context から UserID を取得するヘルパー |
| apps/api/internal/adapter/clerk/auth_provider_test.go | 新規 | fake AuthProvider を使った単体テスト |

## interface 設計

```go
// port/auth.go
type AuthProvider interface {
    VerifyToken(ctx context.Context, token string) (AuthClaims, error)
}

type AuthClaims struct {
    ExternalUserID string // Clerk の sub
}
```

```go
// ミドルウェアが context に載せるキー型
type contextKey string
const UserIDKey contextKey = "userID"
```

## 完了条件

- [ ] AuthProvider interface が port 層に定義されている
- [ ] Clerk 実装が adapter 層に閉じ込められている
- [ ] ミドルウェアが Bearer トークンを検証して context に UserID を載せる
- [ ] ミドルウェアがトークン不正の場合に 401 を返す
- [ ] fake AuthProvider を使った単体テストが追加されている
- [ ] Domain / UseCase のコードが Clerk パッケージを import していない
- [ ] make verify が通る

## 禁止事項

- Domain 層・UseCase 層に Clerk SDK を import しない
- context に UserID 以外の認証情報を載せない（ロールはアプリ DB から取得する）
- 認証済みユーザー ID と操作対象ユーザー ID を混同するコードを書かない

## メモ

employee / admin のロール判定はアプリ DB の users テーブルから取得する。
Clerk の JWT に含まれるロール情報は参照しない。
