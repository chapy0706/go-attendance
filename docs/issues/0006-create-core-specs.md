---
status: open
created_at: 2025-05-08
closed_at:
---

# コア Spec を作成する

## 概要

実装の根拠となるコア Spec（ドメインルール・状態遷移・イベントモデル・API-UseCase マッピング）を作成する。

## 背景

Spec が存在しない状態で Claude Code に実装を依頼すると、
仕様の解釈が都度変わるリスクがある。
特にイベントモデルと月次状態遷移は複数の UseCase が依存するため、
先に文書化して SSOT を確立する。

## refs

- README.md（勤怠仕様メモ セクション全体）
- docs/adr/004-use-append-only-attendance-events.md（0004 で作成）
- docs/adr/005-use-usecase-based-api-endpoints.md（0004 で作成）
- docs/specs/_template.md（0003 で作成）

## 実装スコープ

| ファイル | 操作 | 内容 |
|---|---|---|
| docs/specs/active/0001-domain-rules.md | 新規 | ユーザー種別・時刻・打刻のドメインルール |
| docs/specs/active/0002-attendance-state-machine.md | 新規 | 月次状態遷移・編集可否マトリクス |
| docs/specs/active/0003-event-history-model.md | 新規 | イベント種別・Projection・Snapshot の定義 |
| docs/specs/active/0004-api-usecase-mapping.md | 新規 | API エンドポイントと UseCase の対応表 |

## 完了条件

- [ ] 0001: employee / admin の操作権限・時刻ルール・打刻ルール・二重打刻防止方針が明記されている
- [ ] 0002: draft / submitted_by_employee / submitted_by_admin / closed の状態遷移と、各状態での操作可否マトリクスが明記されている
- [ ] 0003: attendance_events のイベント種別一覧・各 Projection の再生成方法・Snapshot の保存内容（event_sequence 範囲含む）が明記されている
- [ ] 0004: 全 API エンドポイントと対応する UseCase・記録されるイベントの対応表が明記されている
- [ ] make verify が通る

## 禁止事項

- Spec に実装コードを書かない
- 未決定事項は `TODO:` として残し、勝手に決定しない

## メモ

GPS・認証・案件交通費の Spec（0005〜0007）は次 Issue 以降で作成する。
この Issue ではコア 4 本に集中する。
