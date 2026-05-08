---
status: open
created_at: 2025-05-08
closed_at:
---

# ClockOut UseCase を実装する

## 概要

退勤打刻 UseCase（ClockOut）を実装する。
attendance_events に clock_out_recorded イベントを追加し、
work_sessions の clock_out_at を更新する。

## 背景

ClockIn（0010）に続くコア打刻機能。
退勤時刻の有効性チェック（出勤より前は不可）や
未出勤状態での退勤防止などのドメインルールをここで実装する。

## refs

- docs/specs/active/0001-domain-rules.md（打刻ルール）
- docs/specs/active/0003-event-history-model.md（clock_out_recorded イベント）
- docs/specs/active/0004-api-usecase-mapping.md（POST /api/attendance/clock-out）
- .claude/skills/02-implement-usecase.md

## 実装スコープ

| ファイル | 操作 | 層 |
|---|---|---|
| apps/api/internal/usecase/attendance/clock_out.go | 新規 | UseCase |
| apps/api/internal/usecase/attendance/clock_out_test.go | 新規 | UseCase |
| apps/api/internal/port/attendance_repository.go | 更新 | Port（ClockOut 用メソッド追加） |
| apps/api/internal/adapter/postgres/attendance_repository.go | 更新 | Adapter（ClockOut 用実装追加） |

## ドメインルール

- clock_out_at IS NULL の work_sessions が存在しない場合は ErrNotClockedIn を返す
- 退勤時刻が出勤時刻より前の場合は ErrInvalidClockOutTime を返す
- 打刻時刻はサーバー時刻（Clock interface）を使う

## 完了条件

- [ ] ClockOut UseCase が実装されている
- [ ] 未出勤状態での退勤に ErrNotClockedIn を返す
- [ ] 退勤時刻が出勤時刻より前の場合に ErrInvalidClockOutTime を返す
- [ ] attendance_events に clock_out_recorded イベントが追加される
- [ ] work_sessions の clock_out_at が更新される
- [ ] Idempotency-Key による重複リクエスト検知が実装されている
- [ ] 単体テストが追加されている
- [ ] make verify が通る

## 禁止事項

- time.Now() を UseCase 内で直接呼ばない
- work_sessions を UseCase から直接 SQL で更新しない

## メモ

日をまたぐ勤務（深夜退勤）は仕様上許容する。
勤務日は出勤打刻した日とするため、work_sessions の work_date は更新しない。
