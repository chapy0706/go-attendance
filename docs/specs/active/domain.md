# Domain Specification

## 概要
本システムは勤怠管理・交通費申請を行う業務アプリケーションである。

設計原則:
- 事実はイベントとして記録する
- 表示はProjectionで行う
- 月次確定後はSnapshotとして固定する

## 用語
- Attendance Event
- Work Session
- Monthly Summary
- Transportation Claim
- Commute Default

## ユーザー種別
- employee
- admin

## 勤怠ルール
- 出勤・退勤はイベントとして記録する
- 勤務日は出勤日基準とする
- タイムゾーンは Asia/Tokyo 固定

## 休憩
- 休憩は合計分数として扱う

## 案件
- 勤務セッションは1つの案件に紐づく

## 交通費
- 片道料金と区分から金額を導出

## 月次状態
- draft
- submitted_by_employee
- submitted_by_admin
- closed
