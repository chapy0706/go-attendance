---
status: open
created_at: 2025-05-08
closed_at:
---

# 勤怠一覧 API を実装する

## 概要

employee が自分の勤怠を日単位・月単位で確認できる API と、
admin が全ユーザー横断で確認できる API を実装する。

## 背景

MVP の「自分の勤怠一覧」「管理者による勤怠一覧確認」機能に対応する。
集計・申請機能（0017・0018）が揃ったため、一覧表示を実装する。

## refs

- docs/specs/active/0001-domain-rules.md（閲覧権限）
- docs/specs/active/0004-api-usecase-mapping.md（API エンドポイント定義）
- .claude/skills/04-implement-handler.md

## 実装スコープ

| ファイル | 操作 | 層 |
|---|---|---|
| apps/api/internal/usecase/attendance/list_daily_attendance.go | 新規 | UseCase |
| apps/api/internal/usecase/attendance/list_monthly_attendance.go | 新規 | UseCase |
| apps/api/internal/adapter/handler/attendance_list_handler.go | 新規 | Adapter |
| db/queries/attendance_list.sql | 新規 | sqlc クエリ |

## API 仕様

### GET /api/attendance/daily?year_month=YYYY-MM

- employee: 自分のデータのみ取得
- admin: クエリパラメータで user_id 指定可能
- レスポンス: 日次勤怠一覧（work_sessions + 暫定集計値）

### GET /api/attendance/monthly?year_month=YYYY-MM

- employee: 自分の月次サマリー取得
- admin: クエリパラメータで user_id 指定可能
- レスポンス: 月次集計・月次状態

### GET /api/admin/attendance?year_month=YYYY-MM（admin 専用）

- admin のみアクセス可能
- 全ユーザーの月次状態一覧を返す

## 完了条件

- [ ] GET /api/attendance/daily が動作する
- [ ] GET /api/attendance/monthly が動作する
- [ ] employee が他ユーザーのデータを取得できないことを確認している
- [ ] admin 専用エンドポイントへの employee アクセスが 403 を返す
- [ ] 暫定集計値が一覧に含まれている
- [ ] Handler テストが追加されている
- [ ] make verify が通る

## 禁止事項

- employee が他ユーザーの勤怠データを参照できる実装を書かない
- 認証済みユーザー ID と操作対象ユーザー ID を混同しない

## メモ

admin 向けの詳細ダッシュボード機能は次フェーズ。
この Issue では MVP の最低限の一覧表示のみ実装する。
