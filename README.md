# go-attendance

勤怠打刻アプリを題材に、Go + PostgreSQL + Next.js を用いて、業務ロジック・責務分離・型安全なDBアクセス・テスト・本番デプロイを学習するためのポートフォリオプロジェクトです。

## 目的

このプロジェクトでは、Spring Bootのような包括的フレームワークに依存せず、Goの小さな標準機能と明示的なレイヤード設計を用いてバックエンドを構築します。

目的は、認証・認可、DBトランザクション、打刻ルール、集計バッチ、マイグレーション、テストの責務を自分で設計し、説明できる状態にすることです。

## 技術スタック

### Frontend

- Next.js
- TypeScript
- Zod
- TanStack Query
- Playwright

### Backend

- Go
- net/http または chi
- sqlc
- pgx
- OpenAPI
- Testcontainers for Go

### Database

- PostgreSQL
- Neon PostgreSQL

### Migration

- golang-migrate または goose

### Deploy

- Frontend: Vercel
- Backend: Render
- Database: Neon PostgreSQL

## アーキテクチャ方針

- Domain / UseCase / Port / Adapter を分離する
- Domain と UseCase は HTTP・DB・認証実装に依存しない
- 認証プロバイダは AuthProvider interface の背後に閉じ込める
- SQLはORMで隠さず、sqlcで型安全に扱う
- 時刻処理は Clock interface を通してテスト可能にする
- 打刻データはイベント履歴として保存し、表示・集計用の状態はイベントから導出する
- APIはUseCase単位で設計し、HTTPエンドポイントはUseCaseへの入力境界として扱う
- ProjectionやSnapshotを直接編集するAPIは提供しない
- バッチ処理は cmd 配下の別エントリポイントとして分離する
- README・ADR・SpecをSSOTとして、Claude Codeに渡す前提で進める

## 勤怠仕様メモ

現時点での仮決定事項です。詳細な例外ルールや画面/API仕様は docs/specs 配下の仕様書で定義します。

### ユーザー種別

- MVPでは employee / admin の2種類に固定する
- employee は自分の勤怠を確認・操作する
- admin は全ユーザーの勤怠を確認・管理する

### 認証

- Clerkを第一候補とする
- 最終決定はADRで比較して行う
- Clerkは本人確認にのみ利用する
- employee / admin の権限はアプリケーションDBで管理する
- アプリケーション内部では AuthProvider interface を定義し、Clerkなどの外部認証プロバイダにDomain / UseCaseが直接依存しないようにする

### 時刻・勤怠日の扱い

- タイムゾーンは Asia/Tokyo 固定とする
- DBには timestamptz で保存する
- 表示・集計時に Asia/Tokyo へ変換する
- 打刻時刻はサーバー時刻を正とし、クライアント送信時刻は採用しない
- 勤怠日はカレンダー日付を基本とする
- 日をまたぐ勤務は許可し、勤務日は出勤打刻した日とする

### 打刻・勤怠データ

- attendance_events をappend-onlyなSource of Truthとする
- 修正時は既存イベントを更新せず、修正イベントを追加する
- attendance_days / work_sessions は再生成可能なProjectionとして扱う
- monthly_summaries は月締め時にSnapshotとして固定する
- アプリケーションはProjectionを直接編集するAPIを提供しない
- 休憩時間、案件、交通費などの変更はUseCaseを通じてイベントを追加し、その結果としてProjectionを更新する
- 原則として1勤務日につき1セッションとする
- allow_multiple_sessions=true の場合のみ、同一勤務日に複数セッションを許可する
- 打刻時にはサーバー時刻に加えて、可能な範囲でGPS情報を記録し、不正検知や管理者確認に利用する

### 休憩

- 休憩は開始・終了時刻ではなく、勤務セッション内で取得した合計休憩時間として入力する
- 休憩時間は分単位の整数で入力する
- 休憩時間は勤務時間の集計に使用する
- 休憩時間は出勤後から退勤後まで入力・修正可能とする
- 月次申請後はemployeeによる変更不可とする
- 月締め後はadminも変更不可とする
- MVPでは休憩開始時刻・休憩終了時刻は記録しない

### シフトと打刻時刻

- actual_time / scheduled_time / effective_time を分離する
- 出勤時は、実打刻がシフト開始より早い場合はシフト開始時刻を表示上の正とする
- 出勤時は、実打刻がシフト開始より遅い場合は実打刻時刻を表示上の正とする
- 退勤時は、実打刻がシフト終了より早い場合は実打刻時刻を表示上の正とする
- 退勤時は、実打刻がシフト終了より遅い場合はシフト終了時刻を表示上の正とする
- 集計にはeffective_timeを使用する
- 警告判定にはactual_timeとscheduled_timeの差分を使用する
- 管理側では、シフト時刻と実打刻時刻の両方を確認できるようにする

### 月次状態

- draft: employee / admin ともに編集可能
- submitted_by_employee: employee は編集不可、申請解除可能。admin は編集可能
- submitted_by_admin: admin が代理申請した状態。employee は編集不可、admin は編集可能
- closed: employee / admin ともに編集不可、解除不可、再計算不可
- closed後の誤りは、将来の差分訂正仕様で扱う

### 月次Snapshot

- monthly_summaries は月締め時にSnapshotとして固定する
- Snapshotには、計算日時、計算ルールID、計算ルールバージョン、計算対象イベント範囲を保存する
- 計算対象イベント範囲は時刻ではなくevent_sequenceで保持する
- event_sequence はPostgreSQL BIGSERIALによるグローバル連番とし、歯抜けは許容する
- monthly_summaries には source_event_sequence_from / source_event_sequence_to / source_last_event_id / calculated_at / calculation_rule_id / calculation_rule_version を保存する
- 修正イベントが後から追加された場合、event_sequenceの進行によって再計算対象であることを検知する
- closed後のmonthly_summariesは再計算しない

### 勤怠一覧・集計

- employee は自分の勤怠を日単位・月単位で確認できる
- admin は全ユーザー横断、ユーザー別、日付範囲指定で勤怠を確認できる
- MVPでも勤務時間・休憩時間などの集計済み表示を行う
- 一覧表示では暫定集計を表示する
- 申請ボタン押下時には、確定前バリデーションとして勤怠を再計算する
- 申請後は monthly_summaries にスナップショットを保存する
- 月締め時には最終再計算し、closed summary として固定する
- MVPでは最初からバッチ化せず、UseCase名を分けて後からバッチ化しやすくする

### GPS

- GPSは任意取得とし、取得できない場合でも打刻は可能とする
- GPSは管理側の不正検知情報として扱う
- 位置情報は90日保存し、将来的に削除バッチで破棄する
- 90日経過後は緯度・経度・精度を削除し、gps_status = deleted_after_retention として削除済み状態を残す
- captured_at は位置取得に関する監査メタデータとして保持する
- 管理画面では位置情報の詳細表示を限定する
- GPS情報は attendance_event_locations として attendance_events から分離して保存する
- attendance_event_locations は event_id / latitude / longitude / accuracy_meters / gps_status / captured_at を持つ想定とする

### 稼働案件・交通費

- 勤務セッションは稼働案件を1つ持つ
- ユーザーと稼働案件の紐づきは user_project_assignments で管理する
- 勤務セッションには、勤務時点で選択された案件IDを保存する
- user_project_assignments はユーザーが選択可能な案件の有効期間を表す
- 勤務セッションの案件変更は、対象月がclosedでない場合のみ許可する
- 変更先案件は、勤務日時点で有効なuser_project_assignmentsに含まれる案件のみ許可する
- 有効期間外の案件への変更はMVPでは許可しない
- 案件変更時はイベントを追加する
- 交通費は勤務セッションに紐づく申請データとして扱う
- 交通費申請は片道経路・片道料金・申請区分を持つ
- 申請区分は one_way / round_trip とする
- 交通費申請額 amount_yen は、片道料金と申請区分から導出する
- MVPではemployeeによるamount_yenの直接上書きは許可しない
- adminが例外的に上書きする場合は、交通費修正イベントを追加し、amount_yen_source = admin_override とする
- adminによるamount_yen上書き時は override_reason / overridden_by_user_id / overridden_at を必須とする
- adminによるamount_yen上書き時は transportation_claim_corrected イベントを追加する
- 交通費の編集可否は、対象月の月次勤怠状態に従う
- closed後の交通費修正は不可とし、後追い精算は将来仕様としてSpecに残す
- MVPでは経路と金額の正当性チェックは行わない
- 片道料金は0円以上の整数とする
- 経路ラベルは空文字不可とする
- デフォルト申請設定を用意し、シフト申請時または退勤打刻時に初期値として反映できるようにする
- デフォルト申請設定はテンプレートであり、実際の交通費申請にはその時点の値をスナップショットとして保存する
- 交通費申請の履歴は transportation_claim_events として記録する
- デフォルト申請設定の変更履歴は commute_default_history を独立テーブルとして管理する

### データモデル候補

- projects
- user_project_assignments
- attendance_events
- attendance_event_locations
- attendance_days
- work_sessions
- commute_defaults
- commute_default_history
- transportation_claims
- transportation_claim_events
- monthly_summaries

### UseCase候補

- CalculateDailyAttendance
- CalculateMonthlyAttendance
- SubmitMonthlyAttendance
- CloseMonthlyAttendance

### API方針

- APIはUseCaseごとのエンドポイントに分ける
- Projectionを直接更新しているように見えるAPI名は避ける
- 全ての更新系エンドポイントはUseCaseの入口であり、Projectionを直接更新するAPIではない
- 更新系エンドポイントはHTTPメソッドにPUTではなくPOSTを使い、イベント追加の意図を明示する
- MVPでは打刻系APIのみ Idempotency-Key ヘッダーを必須とし、更新系全般への適用は次フェーズで検討する
- 成功したリクエストのみ冪等性キーを保存し、失敗レスポンスは保存しない
- 冪等性キーは user_id + endpoint + key の単位で管理する
- 同一キーかつ同一payloadの場合は前回成功レスポンスを返す
- 同一キーでpayloadが異なる場合は 409 Conflict を返す
- 冪等性キーの保存期間は24時間とする
- DB制約とトランザクションで二重打刻を防ぐ
- 具体的なHTTPメソッド・パス・リクエスト/レスポンスはOpenAPIとSpecで定義する

### API候補

| 操作 | エンドポイント | 記録される変更 |
| --- | --- | --- |
| 出勤打刻 | POST /api/attendance/clock-in | clock_in_recorded |
| 退勤打刻 | POST /api/attendance/clock-out | clock_out_recorded |
| 休憩時間変更 | POST /api/work-sessions/{id}/break-minutes/change | break_minutes_changed |
| 案件変更 | POST /api/work-sessions/{id}/project/change | project_changed |
| 交通費修正（admin） | POST /api/transportation-claims/{id}/correct | transportation_claim_corrected |
| デフォルト申請設定更新 | POST /api/commute-defaults/{id}/update | commute_default_history record |

### 参照系API候補

- GET /api/transportation-claims
- GET /api/commute-defaults

## 想定機能

### MVP

- ログイン
- 出勤打刻
- 退勤打刻
- 休憩時間の登録
- 稼働案件の選択
- 交通費申請
- デフォルト申請設定
- 勤怠の暫定集計
- 月次申請
- 月締め
- 自分の勤怠一覧
- 管理者による勤怠一覧確認

### 次フェーズ

- 勤怠修正申請
- 承認・却下
- 監査ログ
- CSV出力
- バッチ処理
- 管理者ダッシュボード

## Spec / ADR 作成予定

### Spec

- docs/specs/active/0001-domain-rules.md
- docs/specs/active/0002-attendance-state-machine.md
- docs/specs/active/0003-event-history-model.md
- docs/specs/active/0004-api-usecase-mapping.md
- docs/specs/active/0005-auth-provider-decision.md
- docs/specs/active/0006-gps-policy.md
- docs/specs/active/0007-projects-and-transportation-claims.md

### ADR

- docs/adr/003-use-clerk-as-primary-auth.md
- docs/adr/004-use-append-only-attendance-events.md
- docs/adr/005-use-usecase-based-api-endpoints.md
- docs/adr/006-use-asia-tokyo-work-date.md

## 初期ディレクトリ構成

```txt
attendance-app/
├── apps/
│   ├── web/
│   └── api/
├── db/
│   ├── migrations/
│   └── queries/
├── docs/
│   ├── adr/
│   ├── specs/
│   └── api/
├── e2e/
├── .claude/
├── Makefile
├── docker-compose.yml
└── README.md
```

## 開発原則

- 小さく始める
- 仕様を先に書く
- 実装より先に境界を決める
- AI生成コードは必ず人間がレビューする
- 認証・認可・時刻・DB更新は雑に扱わない
- make verify が通る状態を維持する

## Goを選んだ理由

このプロジェクトでは、あえてSpring Bootのような包括的フレームワークを使わず、Goを採用します。

理由は、フレームワークに隠れやすい認証・DBアクセス・トランザクション・エラーハンドリング・バッチ処理を、自分で設計し理解するためです。

Goは言語仕様がシンプルで、過剰な抽象化を避けやすく、Claude Codeと並走しても構造が崩れにくいと考えています。

## 開発ステータス

現在は初期設計フェーズです。

- [ ] README作成
- [ ] Claude Code作業規約作成
- [ ] 仕様書テンプレート作成
- [ ] ADR作成
- [ ] ディレクトリ初期化
- [ ] Go APIのHello World
- [ ] DB接続
- [ ] 初回マイグレーション
