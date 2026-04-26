# ADR 002: Use PostgreSQL over SQLite for Main App

## Status

Accepted

## Context

Go + SQLite + CGI は、小さな個人ツールを安く長く運用する構成として魅力がある。

一方、このプロジェクトは転職用ポートフォリオとして、複数ユーザー、管理者、承認、監査ログ、バッチ集計を含む業務アプリケーションを想定している。

## Decision

メインアプリではPostgreSQLを採用する。

## Reasons

- 複数ユーザー・管理者機能を説明しやすい
- トランザクション、制約、集計、監査ログを実務寄りに設計できる
- Neon PostgreSQLとRender/Vercel構成に乗せやすい
- Testcontainersで統合テストを構築しやすい

## Consequences

- SQLite構成より運用要素は増える
- DB接続、マイグレーション、環境変数管理が必要になる
- ただし、転職用の説明材料としては有利になる
