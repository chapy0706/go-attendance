---
status: open
created_at: YYYY-MM-DD
closed_at:
---

# タイトル（例: ClockIn UseCase を実装する）

## 概要

何をするのかを1〜2文で書く。

## 背景

なぜこの作業が必要なのかを書く。
どの仕様・設計判断に基づいているかを示す。

## refs

- docs/specs/active/000X-xxx.md
- docs/adr/00X-xxx.md

## 実装スコープ

変更・追加するファイルと層を明示する。

| ファイル | 操作 | 層 |
|---|---|---|
| apps/api/internal/usecase/attendance/clock_in.go | 新規 | UseCase |
| apps/api/internal/usecase/attendance/clock_in_test.go | 新規 | UseCase |
| apps/api/internal/port/attendance_repository.go | 追加 | Port |

## 完了条件

- [ ] ...
- [ ] ...
- [ ] make verify が通る

## 禁止事項

この Issue の実装で行ってはいけないことを書く。

- Projection を直接更新しない
- UseCase に SQL を書かない
- （その他この Issue 固有の制約）

## メモ

設計上の迷いや決定の記録、次 Issue への引き継ぎ事項などを書く。
