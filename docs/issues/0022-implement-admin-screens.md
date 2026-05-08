---
status: open
created_at: 2025-05-08
closed_at:
---

# 管理者画面を実装する

## 概要

admin ユーザー向けの勤怠一覧・交通費修正・月締め画面を実装する。

## 背景

MVP に「管理者による勤怠一覧確認」が含まれる。
employee 向け画面（0021）の実装後に admin 専用画面を追加する。

## refs

- docs/specs/active/0001-domain-rules.md（admin の操作権限）
- docs/specs/active/0002-attendance-state-machine.md（月締め操作）
- 0019: 管理者向け API

## 実装スコープ

| ファイル | 操作 | 内容 |
|---|---|---|
| apps/web/app/admin/page.tsx | 新規 | admin ダッシュボード |
| apps/web/app/admin/attendance/page.tsx | 新規 | 全ユーザー勤怠一覧 |
| apps/web/app/admin/attendance/[userId]/page.tsx | 新規 | ユーザー別勤怠詳細 |
| apps/web/features/admin/UserAttendanceTable.tsx | 新規 | 全ユーザー勤怠テーブル |
| apps/web/features/admin/MonthlyCloseButton.tsx | 新規 | 月締めボタン |
| apps/web/features/admin/TransportationCorrectForm.tsx | 新規 | 交通費修正フォーム |
| apps/web/middleware.ts | 更新 | admin ルートへの employee アクセスを拒否 |

## 完了条件

- [ ] admin のみ /admin 配下にアクセスできる
- [ ] employee が /admin にアクセスすると 403 になる
- [ ] 全ユーザーの月次状態一覧が表示される
- [ ] 月締めボタンが動作する
- [ ] admin による交通費修正フォームが動作する（override_reason 必須）
- [ ] make verify が通る

## 禁止事項

- employee ロールで admin 操作ができる実装を書かない
- ロール判定をフロントエンドのみで行わない（バックエンドでも必ず検証する）

## メモ

GPS の詳細表示（緯度・経度）は管理画面でも制限する。
表示可否の詳細は docs/specs/active/0006-gps-policy.md に従う。
