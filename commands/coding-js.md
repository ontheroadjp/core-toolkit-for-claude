# /coding-js

まず `coding-general` を参照し、その後以下の JavaScript 固有ルールを適用すること。

---

## ツールチェーン

- **Linter / Formatter**: Biome（lint + format）
- **テストフレームワーク**: Vitest

---

## 原則

### 1. `var` 禁止 — `const` / `let` のみ使用する

`var` は使用しない。再代入が必要な場合は `let`、それ以外は常に `const` を使う。

```js
// 悪い例
var count = 0;

// 良い例
let count = 0;
const MAX = 100;
```

### 2. `==` 禁止 — 厳密等価演算子 `===` を使う

型強制による予期しない比較を防ぐため、`==` / `!=` は使用しない。常に `===` / `!==` を使う。

```js
// 悪い例
if (value == null) { ... }

// 良い例
if (value === null) { ... }
```

### 3. アロー関数を優先する

コールバック・無名関数はアロー関数で書く。`this` バインディングが必要なメソッド定義を除き、`function` キーワードの無名関数は使わない。

```js
// 悪い例
const doubled = items.map(function(x) { return x * 2; });

// 良い例
const doubled = items.map((x) => x * 2);
```

### 4. オプショナルチェーン（`?.`）とヌル合体演算子（`??`）を積極的に使う

ネストした null / undefined チェックには `?.` を、デフォルト値の設定には `??` を使う。`&&` / `||` による冗長なガード節は避ける。

```js
// 悪い例
const name = user && user.profile && user.profile.name;
const display = name !== null && name !== undefined ? name : 'Guest';

// 良い例
const name = user?.profile?.name;
const display = name ?? 'Guest';
```

### 5. 例外の握り潰し禁止

例外を処理せずに飲み込んではならない。空の `catch {}` や、ログも再 throw もない `catch (e) {}` は禁止。

- エラーを本当に無視してよい場合は、その理由をコメントで明示する。

```js
// 悪い例
try {
  connect();
} catch (e) {}

// 良い例
try {
  connect();
} catch (e) {
  logger.warn('接続に失敗しました。リトライします', e);
}
```
