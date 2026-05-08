---
status: open
created_at: 2025-05-08
closed_at:
---

# 休憩時間変更 UseCase を実装する（ChangeBreakMinutes）

## 概要

勤務セッションの休憩時間を変更する UseCase（ChangeBreakMinutes）を実装する。
break_minutes_changed イベントを追加し、work_sessions Projection を更新する。

## 背景

休憩時間は出勤後〜退勤後まで修正可能であり、
月次申請後は employee による変更を禁止する。
MVP の勤怠集計に休憩時間が必要なため、打刻基盤に続いて実装する。

## refs

- docs/specs/active/0001-domain-rules.md（休憩ルール）
- docs/specs/active/0002-attendance-state-machine.md（月次状態と編集可否）
- docs/specs/active/0003-event-history-model.md（break_minutes_changed イベント）
- .claude/skills/02-implement-usecase.md

## 実装スコープ

| ファイル | 操作 | 層 |
|---|---|---|
| apps/api/internal/usecase/attendance/change_break_minutes.go | 新規 | UseCase |
| apps/api/internal/usecase/attendance/change_break_minutes_test.go | 新規 | UseCase |
| apps/api/internal/port/attendance_repository.go | 更新 | 月次状態取得メソッド追加 |
| apps/api/internal/adapter/postgres/attendance_repository.go | 更新 | 対応実装追加 |
| apps/api/internal/adapter/handler/attendance_handler.go | 更新 | POST .../break-minutes/change 追加 |

## ドメインルール

- 休憩時間は 0 以上の整数（分単位）
- 退勤前でも入力可能（break_minutes は work_session に属する）
- 月次状態が submitted_by_employee / closed の場合は employee による変更不可
- 月次状態が closed の場合は admin も変更不可
- break_minutes_changed イベントを attendance_events に追加する

## 完了条件

- [ ] ChangeBreakMinutes UseCase が実装されている
- [ ] 休憩時間が負の場合にバリデーションエラーを返す
- [ ] 月次状態に応じた編集可否チェックが実装されている
- [ ] break_minutes_changed イベントが attendance_events に追加される
- [ ] work_sessions の break_minutes が更新される
- [ ] 単体テストが追加されている
- [ ] POST /api/work-sessions/{id}/break-minutes/change が動作する
- [ ] make verify が通る

## 禁止事項

- work_sessions の break_minutes を直接 SQL で UPDATE しない（イベント経由）
- PUT メソッドを使わない（POST /change を使う）

## メモ

MVP では休憩開始・終了時刻は記録しない。合計分数のみ。
