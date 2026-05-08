---
status: open
created_at: 2025-05-08
closed_at:
---

# GPS 記録を実装する

## 概要

打刻時の GPS 情報を attendance_event_locations に保存する機能を実装する。
GPS は任意取得であり、取得できない場合でも打刻は成功する。

## 背景

GPS は不正打刻の管理側検知情報として使うため、
打刻機能（0010・0011）に組み込む形で実装する。
ただし打刻処理の主フローとは分離し、GPS の失敗が打刻を妨げない設計にする。

## refs

- docs/specs/active/0006-gps-policy.md（0006 別 Issue で作成予定）
- README.md（GPS セクション・gps_status enum）
- docs/adr/004-use-append-only-attendance-events.md

## 実装スコープ

| ファイル | 操作 | 層 |
|---|---|---|
| db/migrations/006_create_attendance_event_locations.sql | 新規 | DB |
| db/queries/attendance_event_locations.sql | 新規 | sqlc クエリ |
| apps/api/internal/domain/attendance/gps.go | 新規 | Domain（GPS 値オブジェクト・gps_status enum） |
| apps/api/internal/port/gps_repository.go | 新規 | Port |
| apps/api/internal/usecase/attendance/clock_in.go | 更新 | GPS 保存を追加 |
| apps/api/internal/usecase/attendance/clock_out.go | 更新 | GPS 保存を追加 |
| apps/api/internal/adapter/postgres/gps_repository.go | 新規 | Adapter |

## gps_status enum

| 値 | 意味 |
|---|---|
| captured | 正常取得 |
| unavailable | 端末が取得不可 |
| permission_denied | ユーザーが拒否 |
| deleted_after_retention | 90日経過後削除済み |

## attendance_event_locations テーブル

```
event_id         UUID NOT NULL REFERENCES attendance_events(id)
latitude         DECIMAL(9,6)
longitude        DECIMAL(9,6)
accuracy_meters  DECIMAL(8,2)
gps_status       TEXT NOT NULL
captured_at      TIMESTAMPTZ NOT NULL
```

## 完了条件

- [ ] attendance_event_locations テーブルが作成されている
- [ ] GPS 情報が attendance_events から分離されたテーブルに保存される
- [ ] GPS 取得失敗（unavailable / permission_denied）の場合でも打刻が成功する
- [ ] gps_status の全 enum 値が Domain 層に定義されている
- [ ] GPS 情報なしで打刻する場合のテストが追加されている
- [ ] GPS 情報ありで打刻する場合のテストが追加されている
- [ ] make verify が通る

## 禁止事項

- GPS 失敗を打刻失敗として扱わない
- GPS の latitude / longitude をクライアントから無検証で受け取らない（範囲チェックを入れる）

## メモ

90日後の削除バッチは次フェーズ（バッチ処理 Issue）で実装する。
この Issue では保存と gps_status 管理のみ行う。
