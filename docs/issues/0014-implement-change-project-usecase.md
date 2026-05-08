---
status: open
created_at: 2025-05-08
closed_at:
---

# 案件管理と ChangeProject UseCase を実装する

## 概要

projects・user_project_assignments テーブルを作成し、
勤務セッションの案件変更 UseCase（ChangeProject）を実装する。

## 背景

退勤後に案件を変更するユースケースが MVP に含まれるため、
打刻基盤が整った段階で案件管理を追加する。

## refs

- docs/specs/active/0001-domain-rules.md（案件変更ルール）
- docs/specs/active/0007-projects-and-transportation-claims.md（別途作成予定）
- README.md（稼働案件・交通費 セクション）
- .claude/skills/02-implement-usecase.md

## 実装スコープ

| ファイル | 操作 | 層 |
|---|---|---|
| db/migrations/007_create_projects.sql | 新規 | DB |
| db/migrations/008_create_user_project_assignments.sql | 新規 | DB |
| db/queries/projects.sql | 新規 | sqlc クエリ |
| apps/api/internal/domain/project/ | 新規 | Domain |
| apps/api/internal/usecase/attendance/change_project.go | 新規 | UseCase |
| apps/api/internal/usecase/attendance/change_project_test.go | 新規 | UseCase |
| apps/api/internal/adapter/postgres/project_repository.go | 新規 | Adapter |
| apps/api/internal/adapter/handler/attendance_handler.go | 更新 | POST .../project/change 追加 |

## ドメインルール

- 対象月が closed の場合は案件変更不可（ErrMonthClosed）
- 変更先案件が勤務日時点の user_project_assignments に含まれない場合は ErrProjectNotAssigned
- 有効期間外の案件への変更は MVP では許可しない
- 変更時は project_changed イベントを attendance_events に追加する

## 完了条件

- [ ] projects / user_project_assignments テーブルが作成されている
- [ ] ChangeProject UseCase が実装されている
- [ ] 月 closed 時の変更拒否が実装されている
- [ ] 有効期間外案件への変更拒否が実装されている
- [ ] project_changed イベントが attendance_events に追加される
- [ ] 単体テストが追加されている
- [ ] POST /api/work-sessions/{id}/project/change が動作する
- [ ] make verify が通る

## 禁止事項

- work_sessions の project_id を UseCase から直接 SQL で更新しない（イベント経由）
- Projection の直接更新コードを書かない

## メモ

work_sessions の project_id は Projection として、
project_changed イベントから導出して更新する。
