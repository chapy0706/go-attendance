# ADR 001: Use Go for Backend

## Status

Accepted

## Context

勤怠打刻アプリのバックエンド技術として、Spring Boot、Ruby on Rails、Goを比較した。

Spring Bootは業務アプリケーションで強力だが、今回の目的はフレームワークに隠れがちな認証・DBアクセス・トランザクション・バッチ処理を自分で設計し理解することである。

Ruby on RailsはMVP作成速度に優れるが、動的型付けかつRailsの規約に乗る比重が大きく、今回の静的型付け言語学習という目的からは少し外れる。

## Decision

バックエンドにはGoを採用する。

## Reasons

- 静的型付けである
- 言語仕様が小さく、過剰な抽象化を避けやすい
- 単一バイナリでデプロイしやすい
- HTTP APIとバッチ処理を同じ言語で扱いやすい
- PostgreSQLと組み合わせた業務アプリケーションに適している
- Claude Codeと並走しても構造を保ちやすい

## Consequences

- Spring Bootのような包括的な機能は自分で選定・実装する必要がある
- 認証・認可・Validation・OpenAPI・DIの設計責任が増える
- その分、設計意図をREADMEやADRで説明しやすくなる
