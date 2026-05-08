---
status: open
created_at: 2025-05-08
closed_at:
---

# ClockIn UseCase を実装する

## 概要

出勤打刻 UseCase（ClockIn）を実装する。
attendance_events にイベントを追加し、work_sessions Projection を更新する。

## 背景

MVP のコア機能である出勤打刻を最初に実装する。
二重打刻防止・Idempotency-Key・Clock interface の扱いを
ここで確立しておくことで、以降の UseCase の雛形になる。

## refs

- docs/specs/active/0001-domain-rules.md（打刻ルール・二重打刻防止）
- docs/specs/active/0003-event-history-model.md（clock_in_recorded イベント）
- docs/specs/active/0004-api-usecase-mapping.md（POST /api/attendance/clock-in）
- docs/adr/004-use-append-only-attendance-events.md
- .claude/skills/02-implement-usecase.md
- .claude/skills/03-implement-repository.md

## 実装スコープ

| ファイル | 操作 | 層 |
|---|---|---|
| apps/api/internal/domain/attendance/event.go | 新規 | Domain |
| apps/api/internal/domain/attendance/errors.go | 新規 | Domain |
| apps/api/internal/port/attendance_repository.go | 新規 | Port |
| apps/api/internal/port/clock.go | 新規 | Port |
| apps/api/internal/usecase/attendance/clock_in.go | 新規 | UseCase |
| apps/api/internal/usecase/attendance/clock_in_test.go | 新規 | UseCase |
| apps/api/internal/adapter/postgres/attendance_repository.go | 新規 | Adapter |
| apps/api/internal/adapter/postgres/clock.go | 新規 | Adapter |

## ドメインルール

- 同一ユーザー・同一勤務日に clock_out_at IS NULL の work_sessions が存在する場合は ErrAlreadyClockedIn を返す
- 打刻時刻はサーバー時刻（Clock interface）を使い、クライアント送信時刻は使わない
- GPS 情報は任意。取得できない場合でも打刻は成功させる（GPS は 0013 で実装）

## Idempotency-Key の扱い

- Idempotency-Key ヘッダーが存在する場合、idempotency_keys テーブルを確認する
- 同一キーで成功済みの場合は前回レスポンスを返す
- 同一キーで payload が異なる場合は 409 Conflict を返す
- 成功後に idempotency_keys に保存する（有効期限 24 時間）

## 完了条件

- [ ] ClockIn UseCase が実装されている
- [ ] UseCase が HTTP / DB / Clerk に直接依存していない
- [ ] Clock interface 経由で時刻を取得している
- [ ] 二重打刻時に ErrAlreadyClockedIn を返す
- [ ] attendance_events に clock_in_recorded イベントが追加される
- [ ] work_sessions Projection が更新される
- [ ] Idempotency-Key による重複リクエスト検知が実装されている
- [ ] 単体テスト（fake repo / fake clock）が追加されている
- [ ] make verify が通る

## 禁止事項

- work_sessions を UseCase から直接 SQL で更新しない（Repository 経由にする）
- time.Now() を UseCase 内で直接呼ばない
- GPS 処理を この Issue で実装しない（0013 で行う）

## メモ

ClockIn が以降の UseCase の実装パターンの基準になる。
丁寧に作ること。
