---
status: open
created_at: 2025-05-08
closed_at:
---

# 交通費申請と commute_defaults を実装する

## 概要

交通費申請（transportation_claims）・デフォルト申請設定（commute_defaults）のテーブルと
関連 UseCase を実装する。
admin による交通費修正（CorrectTransportationClaim）も含む。

## 背景

MVP 機能に交通費申請・デフォルト申請設定が含まれるため、
案件管理（0014）に続いて実装する。

## refs

- README.md（稼働案件・交通費 セクション）
- docs/specs/active/0007-projects-and-transportation-claims.md（別途作成予定）
- docs/specs/active/0002-attendance-state-machine.md（交通費の編集可否）
- .claude/skills/02-implement-usecase.md

## 実装スコープ

| ファイル | 操作 | 層 |
|---|---|---|
| db/migrations/009_create_commute_defaults.sql | 新規 | DB |
| db/migrations/010_create_commute_default_history.sql | 新規 | DB |
| db/migrations/011_create_transportation_claims.sql | 新規 | DB |
| db/migrations/012_create_transportation_claim_events.sql | 新規 | DB |
| apps/api/internal/domain/transportation/ | 新規 | Domain |
| apps/api/internal/usecase/transportation/submit_transportation_claim.go | 新規 | UseCase |
| apps/api/internal/usecase/transportation/correct_transportation_claim.go | 新規 | UseCase |
| apps/api/internal/usecase/transportation/update_commute_default.go | 新規 | UseCase |
| apps/api/internal/adapter/handler/transportation_handler.go | 新規 | Adapter |

## ドメインルール

- amount_yen = 片道料金 × (one_way: 1 / round_trip: 2) で導出する
- employee による amount_yen の直接上書きは不可
- admin 上書き時は transportation_claim_corrected イベントを追加・override_reason 必須
- commute_defaults の変更は commute_default_history に記録する（attendance_events には入れない）
- 片道料金は 0 以上の整数
- 経路ラベルは空文字不可

## 完了条件

- [ ] 上記テーブルが作成されている
- [ ] SubmitTransportationClaim UseCase が実装されている
- [ ] CorrectTransportationClaim UseCase（admin 用）が実装されている
- [ ] UpdateCommuteDefault UseCase が実装されている
- [ ] commute_defaults の変更が commute_default_history に記録される（attendance_events に入らない）
- [ ] admin 上書き時に override_reason / overridden_by_user_id / overridden_at が保存される
- [ ] 月次状態に応じた編集可否チェックが実装されている
- [ ] GET /api/transportation-claims が動作する
- [ ] GET /api/commute-defaults が動作する
- [ ] POST /api/transportation-claims/{id}/correct が動作する
- [ ] make verify が通る

## 禁止事項

- commute_default_updated を attendance_events に入れない
- employee が amount_yen を直接上書きできる実装を書かない

## メモ

交通費申請の初期値反映（退勤打刻時にデフォルト設定を反映）は
UX 都合のため、フロントエンド実装 Issue で扱う。
