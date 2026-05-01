# API Specification

## 勤怠
POST /api/attendance/clock-in
POST /api/attendance/clock-out

POST /api/work-sessions/{id}/break-minutes/change
POST /api/work-sessions/{id}/project/change

## Idempotency
- Key必須
- 成功のみ保存
