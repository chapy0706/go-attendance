---
status: open
created_at: 2025-05-08
closed_at:
---

# Testcontainers 統合テストと E2E テストを整備する

## 概要

Repository 層の Testcontainers 統合テストと、
重要なユーザーフローの Playwright E2E テストを整備する。

## 背景

MVP の実装（〜0022）が揃ったため、
テストカバレッジを整備してリグレッションを防ぐ体制を作る。

## refs

- README.md（テスト方針 セクション）
- .claude/skills/03-implement-repository.md（Testcontainers パターン）
- CLAUDE.md（テスト方針）

## 実装スコープ

### Testcontainers 統合テスト

| ファイル | 操作 | 内容 |
|---|---|---|
| apps/api/internal/adapter/postgres/attendance_repository_test.go | 新規 | attendance_events CRUD 統合テスト |
| apps/api/internal/adapter/postgres/work_session_repository_test.go | 新規 | work_sessions 統合テスト |
| apps/api/internal/adapter/postgres/monthly_summary_repository_test.go | 新規 | monthly_summaries 統合テスト |
| apps/api/internal/adapter/postgres/testutil/container.go | 新規 | Testcontainers 共通セットアップ |

### Playwright E2E テスト

| ファイル | 操作 | 内容 |
|---|---|---|
| e2e/clock-in-out.spec.ts | 新規 | 出勤→退勤フロー |
| e2e/monthly-submit.spec.ts | 新規 | 月次申請フロー |
| e2e/admin-close.spec.ts | 新規 | 管理者月締めフロー |
| e2e/fixtures/users.ts | 新規 | テスト用ユーザー定義 |
| playwright.config.ts | 新規 | Playwright 設定 |

## 完了条件

- [ ] Testcontainers 統合テストが `make test/integ` で通る
- [ ] 出勤→退勤フローの E2E テストが通る
- [ ] 月次申請フローの E2E テストが通る
- [ ] 管理者月締めフローの E2E テストが通る
- [ ] `make test/e2e` が通る
- [ ] make verify が通る

## 禁止事項

- E2E テストで本番 DB に接続しない
- テスト間でデータが汚染されないよう、テストごとにデータをリセットする

## メモ

Testcontainers の PostgreSQL コンテナは各テストで起動・破棄する。
共通セットアップは testutil/container.go に切り出して再利用する。
