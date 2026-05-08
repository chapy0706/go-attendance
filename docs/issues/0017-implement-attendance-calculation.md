---
status: open
created_at: 2025-05-08
closed_at:
---

# 勤怠集計 UseCase を実装する（CalculateDailyAttendance・CalculateMonthlyAttendance）

## 概要

日次・月次の勤怠集計 UseCase を実装する。
effective_time を使って勤務時間を算出し、暫定集計として返す。

## 背景

勤怠一覧表示に集計値が必要なため、
月次申請（0018）の前に集計ロジックを確立する。

## refs

- docs/specs/active/0001-domain-rules.md（actual_time / scheduled_time / effective_time の定義）
- docs/specs/active/0003-event-history-model.md（Projection の構造）
- docs/specs/active/0002-attendance-state-machine.md（集計タイミング）
- README.md（勤怠一覧・集計 セクション）
- .claude/skills/02-implement-usecase.md

## 実装スコープ

| ファイル | 操作 | 層 |
|---|---|---|
| apps/api/internal/domain/attendance/calculation.go | 新規 | Domain（集計ロジック） |
| apps/api/internal/domain/attendance/calculation_test.go | 新規 | Domain |
| apps/api/internal/usecase/attendance/calculate_daily.go | 新規 | UseCase |
| apps/api/internal/usecase/attendance/calculate_monthly.go | 新規 | UseCase |
| apps/api/internal/usecase/attendance/calculate_daily_test.go | 新規 | UseCase |
| apps/api/internal/usecase/attendance/calculate_monthly_test.go | 新規 | UseCase |

## 集計ルール（effective_time の算出）

- 出勤: actual_time がシフト開始より早い → scheduled_time を使う、遅い → actual_time を使う
- 退勤: actual_time がシフト終了より早い → actual_time を使う、遅い → scheduled_time を使う
- 勤務時間 = effective_clock_out - effective_clock_in - break_minutes
- シフトが未設定の場合は actual_time をそのまま effective_time とする

## 完了条件

- [ ] CalculateDailyAttendance UseCase が実装されている
- [ ] CalculateMonthlyAttendance UseCase が実装されている
- [ ] effective_time の算出ロジックが Domain 層に実装されている
- [ ] シフト未設定時のフォールバックが実装されている
- [ ] 集計ロジックの単体テストが追加されている（境界値テスト含む）
- [ ] make verify が通る

## 禁止事項

- 集計ロジックを UseCase 層に書かない（Domain 層に置く）
- シフトテーブルの実体に依存したロジックを書かない（MVP ではシフト未設定を許容する）

## メモ

MVP ではシフト機能が未実装のため、シフト未設定時は actual_time = effective_time として扱う。
シフト機能は次フェーズ。
計算ルールの versioning（calculation_rule_id / version）は 0018 で扱う。
