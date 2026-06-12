---
name: coding-ts
description: TypeScript 固有のコーディング規約（strict: true、any 禁止、型ガード等）を coding-general・coding-js の原則に重ねて適用する。ユーザーが /coding-ts を呼んだとき、または TypeScript のコーディング規約に従うよう求めたときに使用する。
---

# Coding TypeScript スキル

## Source Of Truth

`commands/coding-ts.md` が TypeScript コーディング規約の唯一の定義元。

## 必須動作

1. `commands/coding-general.md` を Read し、言語非依存の原則を適用する。
2. `commands/coding-js.md` を Read し、JavaScript 固有のルールを重ねて適用する。
3. `commands/coding-ts.md` を Read し、TypeScript 固有のルールをさらに重ねて適用する。
4. ソースファイルが明示的に指示しない限り、ルールを再解釈・省略・拡張しない。
5. 自分の前提とソースファイルの内容が矛盾する場合は、ソースファイルに従う。

## スコープガード

- このスキルから `commands/coding-ts.md`、`commands/coding-js.md`、`commands/coding-general.md` を編集しない。
- いずれかのファイルが見つからない・読めない場合は、復元されるまで coding-ts ワークフローを実行できない旨を報告する。
