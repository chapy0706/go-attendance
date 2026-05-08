---
status: open
created_at: 2025-05-08
closed_at:
---

# sqlc セットアップとコード生成基盤を整備する

## 概要

sqlc の設定ファイルを整備し、コアテーブルに対するクエリファイルを作成して
型安全な DB アクセスコードを生成できる状態にする。

## 背景

Repository 実装（0010 以降）が sqlc 生成コードに依存するため、
先にコード生成基盤を整備する。
sqlc 生成コードは手で編集しないルールのため、
クエリファイルの管理方針を確立しておく必要がある。

## refs

- README.md（Backend セクション：sqlc・pgx）
- docs/specs/active/0003-event-history-model.md（0006 で作成）
- 0007 で作成したマイグレーションファイル

## 実装スコープ

| ファイル | 操作 | 内容 |
|---|---|---|
| apps/api/sqlc.yaml | 新規 | sqlc 設定ファイル |
| db/queries/attendance_events.sql | 新規 | attendance_events クエリ |
| db/queries/work_sessions.sql | 新規 | work_sessions クエリ |
| db/queries/idempotency_keys.sql | 新規 | idempotency_keys クエリ |
| db/queries/users.sql | 新規 | users クエリ |
| apps/api/internal/adapter/postgres/db/（生成） | 生成 | sqlc 生成コード（手編集禁止） |
| Makefile | 更新 | make sqlc ターゲットの動作確認 |

## 主なクエリ要件

### attendance_events

- InsertAttendanceEvent（イベント追加・RETURNING id, sequence）
- ListAttendanceEventsByUserAndMonth（ユーザー・月指定で一覧取得）
- GetLatestAttendanceEventSequence（最新 sequence 取得）

### work_sessions

- UpsertWorkSession（INSERT OR UPDATE・Projection 更新用）
- GetActiveWorkSession（clock_out_at IS NULL で取得）
- GetWorkSessionByID（ID 指定取得）

### idempotency_keys

- InsertIdempotencyKey（新規登録）
- GetIdempotencyKey（user_id + endpoint + key で取得）
- DeleteExpiredIdempotencyKeys（期限切れ削除）

## 完了条件

- [ ] `make sqlc` がエラーなく通る
- [ ] apps/api/internal/adapter/postgres/db/ に生成コードが出力されている
- [ ] 生成コードに上記クエリに対応する関数が含まれている
- [ ] make verify が通る

## 禁止事項

- apps/api/internal/adapter/postgres/db/ 配下のファイルを手で編集しない
- sqlc.yaml に override を多用しない（型の嘘を作らない）

## メモ

sqlc のバージョンは v2 系を使うこと。
pgx/v5 ドライバを使うため、sqlc.yaml の sql.engine を pgx に設定する。
