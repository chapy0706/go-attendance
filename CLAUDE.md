# CLAUDE.md

このリポジトリでは、Claude Code を設計意図を守る共同作業者として使用します。
実装者ではなく、Spec・ADR・Issue を起点に動く補助エージェントとして扱います。

---

## 作業の起点

Claude Code はすべての作業を `docs/issues/` 配下の Issue ファイルから開始します。
Issue ファイルを指定されたら、以下の順で必ず読み込んでから着手してください。

1. 指定された `docs/issues/*.md`（作業内容・完了条件を把握する）
2. `README.md`（プロジェクト全体の方針）
3. Issue に記載された `refs` の Spec / ADR
4. 関連する既存コードのディレクトリ構成

読み込み後、着手前に必ず **影響範囲と変更計画** を人間に説明してください。
承認を得てから実装に進んでください。

---

## Issue の完了フロー

```
1. Issue を読む
2. 参照 Spec / ADR を確認する
3. 影響範囲・変更計画を説明して承認を得る
4. .claude/skills/ から該当スキルを読む
5. 実装する
6. make verify を実行する
7. 完了報告（Issue の完了条件を一つずつ確認する）
```

`make verify` が失敗した場合は、自分で修正して再実行してください。
3回試みても通らない場合は、失敗内容を人間に報告して指示を仰いでください。

---

## アーキテクチャ原則

- 依存方向は Domain -> UseCase -> Port <- Adapter の順に保つ
- Domain 層に HTTP・DB・認証・環境変数を持ち込まない
- UseCase 層に SQL を書かない
- Adapter 層に業務判断を書かない
- 時刻は `time.Now()` を直接呼ばず、必ず `Clock` interface 経由にする
- DB 更新はトランザクション境界を明示する
- 認証済みユーザー ID と操作対象ユーザー ID を混同しない
- Projection（attendance_days / work_sessions）を直接更新する実装を書かない
- UseCase を経由しない DB 更新コードを書かない

---

## Go 実装ルール

- package は小さく保つ
- interface は利用側に置く
- エラーは握りつぶさない
- `context.Context` を外部境界から渡す
- グローバル状態を避ける
- `panic` は起動時の設定不備など復旧不能な場面に限定する
- sqlc 生成コードは手で編集しない

---

## テスト方針

- Domain は単体テスト中心
- UseCase は Repository mock または fake でテスト
- Repository は Testcontainers で PostgreSQL 統合テスト
- API は handler 単位のテストを用意
- 重要なユーザーフローは Playwright で E2E を用意

---

## 禁止事項

- 仕様が曖昧なまま実装する
- Spec / ADR に記載のない設計判断を勝手に行う
- 暗黙の仕様を作る
- 一時的な回避コードを残す（`// TODO: 後で直す` などを本流にコミットしない）
- 型を無視する
- `.env` / keys / tokens / secrets を読む・ログに出す・コミットする
- 破壊的コマンドを実行する（`rm -rf` / `reset --hard` / force push）

---

## 完了条件の確認方法

```sh
make verify
```

証跡が必要な場合は以下も実行すること。

```sh
make evidence
```

---

## 不明点の扱い

- 仕様が決まっていない箇所は実装を止め、Spec に `TODO:` として残す
- 設計の判断が必要な場合は人間に確認を求める
- 不要な抽象化を増やさない

---

## スキル一覧

実装パターンに迷ったら `.claude/skills/` 配下の該当スキルを読んでください。

| スキル | 内容 |
|---|---|
| 01-read-issue.md | Issue の読み方・着手フロー |
| 02-implement-usecase.md | UseCase の実装パターン |
| 03-implement-repository.md | Repository の実装パターン |
| 04-implement-handler.md | HTTP Handler の実装パターン |
| 05-close-issue.md | Issue 完了の確認フロー |
