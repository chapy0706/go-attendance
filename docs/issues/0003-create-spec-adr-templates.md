---
status: open
created_at: 2025-05-08
closed_at:
---

# 仕様書・ADR テンプレートを作成する

## 概要

docs/specs および docs/adr 配下に、以降の仕様書・設計記録を統一した形式で書くためのテンプレートを作成する。

## 背景

README に記載された Spec / ADR の作成予定一覧を実際に書き始める前に、
記述フォーマットを統一しておく必要がある。
テンプレートが SSOT になり、Claude Code への指示精度が上がる。

## refs

- README.md（Spec / ADR 作成予定 セクション）

## 実装スコープ

| ファイル | 操作 | 種別 |
|---|---|---|
| docs/specs/_template.md | 新規 | テンプレート |
| docs/adr/_template.md | 新規 | テンプレート |
| docs/specs/active/.gitkeep | 新規 | ディレクトリ保持 |
| docs/adr/.gitkeep | 新規 | ディレクトリ保持 |

## 完了条件

- [ ] docs/specs/_template.md が作成されている
- [ ] docs/adr/_template.md が作成されている
- [ ] Spec テンプレートに status / created_at / summary / rules / open_questions のセクションがある
- [ ] ADR テンプレートに status / context / decision / consequences / alternatives のセクションがある
- [ ] make verify が通る

## 禁止事項

- 実際の Spec / ADR 内容をこの Issue で書かない（次 Issue 以降で行う）

## メモ

テンプレート作成のみ。内容の記述は 0004 以降で行う。
