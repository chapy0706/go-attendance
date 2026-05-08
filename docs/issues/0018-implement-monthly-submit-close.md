---
status: open
created_at: 2025-05-08
closed_at:
---

# 月次申請・月締め UseCase を実装する

## 概要

月次申請（SubmitMonthlyAttendance）・月締め（CloseMonthlyAttendance）UseCase を実装する。
monthly_summaries テーブルに Snapshot を保存し、event_sequence による再計算検知を行う。

## 背景

月次状態管理は MVP の核心機能。
集計 UseCase（0017）が揃ったため、
申請・締め処理と Snapshot の保存を実装する。

## refs

- docs/specs/active/0002-attendance-state-machine.md（月次状態遷移）
- docs/specs/active/0003-event-history-model.md（monthly_summaries の構造）
- docs/adr/004-use-append-only-attendance-events.md
- docs/adr/007-event-sequence-strategy.md（BIGSERIAL グローバル連番）
- .claude/skills/02-implement-usecase.md

## 実装スコープ

| ファイル | 操作 | 層 |
|---|---|---|
| db/migrations/013_create_monthly_summaries.sql | 新規 | DB |
| db/queries/monthly_summaries.sql | 新規 | sqlc クエリ |
| apps/api/internal/domain/attendance/monthly_state.go | 新規 | Domain（状態遷移ロジック） |
| apps/api/internal/usecase/attendance/submit_monthly.go | 新規 | UseCase |
| apps/api/internal/usecase/attendance/submit_monthly_by_admin.go | 新規 | UseCase |
| apps/api/internal/usecase/attendance/close_monthly.go | 新規 | UseCase |
| apps/api/internal/usecase/attendance/submit_monthly_test.go | 新規 | UseCase |
| apps/api/internal/usecase/attendance/close_monthly_test.go | 新規 | UseCase |
| apps/api/internal/adapter/handler/monthly_handler.go | 新規 | Adapter |

## monthly_summaries テーブル

```
id                              UUID PRIMARY KEY
user_id                         UUID NOT NULL
year_month                      TEXT NOT NULL (YYYY-MM)
status                          TEXT NOT NULL
total_work_minutes              INTEGER NOT NULL
total_break_minutes             INTEGER NOT NULL
source_event_sequence_from      BIGINT NOT NULL
source_event_sequence_to        BIGINT NOT NULL
source_last_event_id            UUID NOT NULL
calculated_at                   TIMESTAMPTZ NOT NULL
calculation_rule_id             TEXT NOT NULL
calculation_rule_version        INTEGER NOT NULL
UNIQUE (user_id, year_month)
```

## ドメインルール

- draft → submitted_by_employee（employee のみ）
- draft → submitted_by_admin（admin のみ）
- submitted_by_employee → draft（employee が申請解除）
- submitted_by_employee → closed（admin が締め）
- closed への遷移は不可逆
- 申請時に CalculateMonthlyAttendance を実行して Snapshot を保存する
- closed 後は再計算・再保存しない

## 完了条件

- [ ] monthly_summaries テーブルが作成されている
- [ ] SubmitMonthlyAttendance UseCase が実装されている
- [ ] SubmitMonthlyAttendanceByAdmin UseCase が実装されている
- [ ] CloseMonthlyAttendance UseCase が実装されている
- [ ] 状態遷移バリデーションが Domain 層に実装されている
- [ ] Snapshot に source_event_sequence_from / to / source_last_event_id が保存される
- [ ] closed 後の再計算が拒否される
- [ ] 単体テストが追加されている（状態遷移の境界値含む）
- [ ] make verify が通る

## 禁止事項

- closed 後の monthly_summaries を更新するコードを書かない
- 状態遷移ロジックを UseCase 層に書かない（Domain 層に置く）

## メモ

calculation_rule_id / version は MVP では定数（例: "v1" / 1）で管理する。
ルールのバージョニング機能は次フェーズ。
