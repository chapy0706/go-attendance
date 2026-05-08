---
status: open
created_at: 2025-05-08
closed_at:
---

# コア ADR を作成する

## 概要

README に記載された4本のコア ADR を作成する。
以降の実装がこれらの ADR を根拠として動けるようにする。

## 背景

ADR がないと Claude Code が設計判断の根拠を持てず、
仕様から外れた実装を生成するリスクがある。
実装開始前にコア ADR を揃えて SSOT を整備する。

## refs

- README.md（ADR 作成予定 セクション）
- docs/adr/_template.md（0003 で作成）

## 実装スコープ

| ファイル | 操作 | 内容 |
|---|---|---|
| docs/adr/003-use-clerk-as-primary-auth.md | 新規 | 認証プロバイダの選定理由 |
| docs/adr/004-use-append-only-attendance-events.md | 新規 | イベントソーシング採用理由 |
| docs/adr/005-use-usecase-based-api-endpoints.md | 新規 | UseCase 単位 API 設計の理由 |
| docs/adr/006-use-asia-tokyo-work-date.md | 新規 | タイムゾーン固定方針の理由 |
| docs/adr/007-event-sequence-strategy.md | 新規 | BIGSERIAL グローバル連番の採用理由 |

## 完了条件

- [ ] 上記5ファイルが作成されている
- [ ] 各 ADR に status / context / decision / consequences が記載されている
- [ ] 003: Clerk を使う理由と AuthProvider interface で抽象化する方針が明記されている
- [ ] 004: append-only にする理由と Projection / Snapshot の役割が明記されている
- [ ] 005: UseCase 単位にする理由と PUT ではなく POST を使う意図が明記されている
- [ ] 006: Asia/Tokyo 固定の理由と timestamptz 保存方針が明記されている
- [ ] 007: BIGSERIAL グローバル連番を選んだ理由と歯抜け許容の明記がある
- [ ] make verify が通る

## 禁止事項

- ADR 番号 001・002 は既存扱いのため使わない
- ADR に実装コードを書かない

## メモ

ADR は「なぜそう決めたか」を書く場所。「どう実装するか」は Spec に書く。
