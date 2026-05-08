---
status: open
created_at: 2025-05-08
closed_at:
---

# 打刻系 HTTP Handler を実装する

## 概要

ClockIn・ClockOut UseCase に対応する HTTP Handler とルーティングを実装する。
chi router・認証ミドルウェア・Idempotency-Key の検証を Handler 層で担う。

## 背景

UseCase（0010・0011）と認証基盤（0009）が揃ったため、
HTTP 層を組み合わせて実際に動く打刻 API を完成させる。

## refs

- docs/specs/active/0004-api-usecase-mapping.md（API エンドポイント定義）
- .claude/skills/04-implement-handler.md
- 0009: 認証ミドルウェア
- 0010: ClockIn UseCase
- 0011: ClockOut UseCase

## 実装スコープ

| ファイル | 操作 | 層 |
|---|---|---|
| apps/api/internal/adapter/handler/attendance_handler.go | 新規 | Adapter |
| apps/api/internal/adapter/handler/attendance_handler_test.go | 新規 | Adapter |
| apps/api/internal/adapter/handler/response.go | 新規 | Adapter |
| apps/api/cmd/app/main.go | 更新 | chi router にルート登録 |

## API 仕様

### POST /api/attendance/clock-in

- 認証: Bearer トークン必須
- ヘッダー: Idempotency-Key 必須
- リクエストボディ: なし（サーバー時刻を使用）
- レスポンス: 201 Created `{"event_id": "uuid"}`
- エラー: 400（Idempotency-Key なし）・401（認証失敗）・409（二重打刻 or 冪等性キー衝突）

### POST /api/attendance/clock-out

- 認証: Bearer トークン必須
- ヘッダー: Idempotency-Key 必須
- リクエストボディ: なし
- レスポンス: 200 OK `{"event_id": "uuid"}`
- エラー: 401・409（未出勤 or 退勤時刻不正）

## 完了条件

- [ ] POST /api/attendance/clock-in が動作する
- [ ] POST /api/attendance/clock-out が動作する
- [ ] 未認証リクエストに 401 を返す
- [ ] Idempotency-Key がない場合に 400 を返す
- [ ] Handler に業務判断が含まれていない
- [ ] Handler テストが追加されている（fake UseCase を使う）
- [ ] curl または httpie でローカル動作確認ができる
- [ ] make verify が通る

## 禁止事項

- Handler 内に業務ロジックを書かない
- Handler から DB に直接アクセスしない
- 認証済みユーザー ID と操作対象ユーザー ID を混同しない

## メモ

Handler テストは httptest.NewRecorder を使った単体テストで行う。
統合テストは 0022（E2E）で実施する。
