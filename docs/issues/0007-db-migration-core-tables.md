---
status: open
created_at: 2025-05-08
closed_at:
---

# DB マイグレーション基盤とコアテーブルを作成する

## 概要

goose によるマイグレーション基盤を整備し、
コアテーブル（users・attendance_events・work_sessions・attendance_days）を作成する。

## 背景

打刻 UseCase の実装（0009 以降）が DB テーブルを前提にするため、
先にスキーマを確定させる必要がある。

## refs

- docs/specs/active/0003-event-history-model.md（0006 で作成）
- docs/adr/004-use-append-only-attendance-events.md（0004 で作成）
- README.md（データモデル候補 セクション）

## 実装スコープ

| ファイル | 操作 | 内容 |
|---|---|---|
| db/migrations/001_create_users.sql | 新規 | users テーブル |
| db/migrations/002_create_attendance_events.sql | 新規 | attendance_events テーブル（BIGSERIAL sequence 含む） |
| db/migrations/003_create_work_sessions.sql | 新規 | work_sessions テーブル（Projection） |
| db/migrations/004_create_attendance_days.sql | 新規 | attendance_days テーブル（Projection） |
| db/migrations/005_create_idempotency_keys.sql | 新規 | idempotency_keys テーブル |
| Makefile | 更新 | db/up・db/down・db/reset ターゲットの動作確認 |

## テーブル設計の要件

### attendance_events

```
id              UUID PRIMARY KEY
user_id         UUID NOT NULL REFERENCES users(id)
event_type      TEXT NOT NULL
occurred_at     TIMESTAMPTZ NOT NULL
sequence        BIGSERIAL NOT NULL UNIQUE
payload         JSONB
created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
```

### work_sessions（Projection）

```
id              UUID PRIMARY KEY
user_id         UUID NOT NULL
work_date       DATE NOT NULL
clock_in_at     TIMESTAMPTZ NOT NULL
clock_out_at    TIMESTAMPTZ
break_minutes   INTEGER NOT NULL DEFAULT 0
project_id      UUID REFERENCES projects(id)
allow_multiple  BOOLEAN NOT NULL DEFAULT false
UNIQUE (user_id, work_date) WHERE allow_multiple = false
```

### idempotency_keys

```
id              UUID PRIMARY KEY
user_id         UUID NOT NULL
endpoint        TEXT NOT NULL
key             TEXT NOT NULL
response_status INTEGER NOT NULL
response_body   JSONB
expires_at      TIMESTAMPTZ NOT NULL
created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
UNIQUE (user_id, endpoint, key)
```

## 完了条件

- [ ] `make db/up` がエラーなく通る
- [ ] `make db/down` で1件戻せる
- [ ] attendance_events に sequence BIGSERIAL が定義されている
- [ ] work_sessions に (user_id, work_date) の UNIQUE 制約がある
- [ ] idempotency_keys に (user_id, endpoint, key) の UNIQUE 制約がある
- [ ] すべての外部キーに適切な ON DELETE 方針が設定されている
- [ ] make verify が通る

## 禁止事項

- Projection テーブル（work_sessions / attendance_days）に直接 INSERT する業務コードをこの Issue で書かない
- マイグレーションファイルを手で適用しない（必ず goose 経由）

## メモ

projects テーブルは 0014 で作成する。
work_sessions の project_id は NULL 許容で先に作成し、後から外部キーを追加する方針でも可。
monthly_summaries は 0016 で作成する。
