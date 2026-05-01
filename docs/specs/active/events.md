# Event Specification

## 原則
- すべての変更はイベントとして記録する
- append-only

## Attendance Events
- clock_in
- clock_out
- break_minutes_set
- project_changed

## Transportation Events
- transportation_claim_created
- transportation_claim_updated
- transportation_claim_corrected

## event_sequence
- 単調増加
- 欠番許容
