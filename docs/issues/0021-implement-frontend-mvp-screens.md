---
status: open
created_at: 2025-05-08
closed_at:
---

# 打刻画面・勤怠一覧画面を実装する（フロントエンド MVP）

## 概要

MVP のコア画面である打刻画面・勤怠一覧画面・交通費申請画面・月次申請画面を実装する。

## 背景

バックエンド API（0012〜0019）と Next.js 基盤（0020）が揃ったため、
MVP の画面を実装して一連のユーザーフローを完成させる。

## refs

- docs/specs/active/0001-domain-rules.md
- docs/specs/active/0002-attendance-state-machine.md
- docs/specs/active/0004-api-usecase-mapping.md
- 0020: Next.js セットアップ

## 実装スコープ

| ファイル | 操作 | 内容 |
|---|---|---|
| apps/web/app/dashboard/page.tsx | 新規 | 打刻ダッシュボード |
| apps/web/app/attendance/page.tsx | 新規 | 勤怠一覧（月次） |
| apps/web/app/attendance/[date]/page.tsx | 新規 | 日次勤怠詳細 |
| apps/web/features/clock/ClockButton.tsx | 新規 | 出勤・退勤ボタン |
| apps/web/features/attendance/AttendanceList.tsx | 新規 | 勤怠一覧コンポーネント |
| apps/web/features/transportation/TransportationForm.tsx | 新規 | 交通費申請フォーム |
| apps/web/features/monthly/MonthlySubmitButton.tsx | 新規 | 月次申請ボタン |
| apps/web/hooks/useClockIn.ts | 新規 | TanStack Query mutation |
| apps/web/hooks/useAttendance.ts | 新規 | TanStack Query query |
| apps/web/lib/schemas/ | 新規 | Zod スキーマ定義 |

## 完了条件

- [ ] 出勤ボタンを押すと POST /api/attendance/clock-in が呼ばれる
- [ ] 退勤ボタンを押すと POST /api/attendance/clock-out が呼ばれる
- [ ] 打刻後に UI が更新される（TanStack Query のキャッシュ更新）
- [ ] 勤怠一覧に日次の集計値が表示される
- [ ] 休憩時間を入力して保存できる
- [ ] 交通費申請フォームが動作する
- [ ] 月次申請ボタンが月次状態に応じて表示・非表示を切り替える
- [ ] Idempotency-Key がリクエストごとに生成されている（crypto.randomUUID()）
- [ ] API リクエストの Zod バリデーションが通っている
- [ ] make verify が通る

## 禁止事項

- クライアント側で Clerk JWT をデコードしてロール判定しない
- Idempotency-Key を固定値にしない

## メモ

管理者画面（全ユーザー勤怠一覧）は次 Issue で実装する。
GPS 取得は Geolocation API を使い、取得できない場合は null で送信する。
