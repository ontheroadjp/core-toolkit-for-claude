# /coding-ts

まず `coding-general` と `coding-js` を参照し、その後以下の TypeScript 固有ルールを適用すること。

---

## ツールチェーン

- **Linter / Formatter**: Biome（lint + format）
- **テストフレームワーク**: Vitest
- **型チェッカー**: TypeScript コンパイラ（`strict: true`）

---

## 原則

### 1. `strict: true` を必ず有効にする

`tsconfig.json` の `compilerOptions` には `"strict": true` を明示する。個別フラグ（`noImplicitAny` など）で代替しない。

```json
// 悪い例
{
  "compilerOptions": {
    "noImplicitAny": true,
    "strictNullChecks": true
  }
}

// 良い例
{
  "compilerOptions": {
    "strict": true
  }
}
```

### 2. `any` 原則禁止 — `unknown` を使う

`any` を使うと型チェックが無効になる。型が不明な値には `unknown` を使い、型ガードで絞り込む。

```ts
// 悪い例
function parse(data: any) {
  return data.value;
}

// 良い例
function parse(data: unknown) {
  if (typeof data === 'object' && data !== null && 'value' in data) {
    return (data as { value: unknown }).value;
  }
  throw new Error('不正なデータ形式');
}
```

### 3. 型アサーション（`as`）原則禁止 — 型ガードを使う

`as` による強制キャストは型安全性を破壊する。型ガード関数（`is` 述語）または `in` / `typeof` / `instanceof` で型を絞り込む。

```ts
// 悪い例
const user = response as User;

// 良い例
function isUser(value: unknown): value is User {
  return (
    typeof value === 'object' &&
    value !== null &&
    typeof (value as Record<string, unknown>).id === 'string'
  );
}
if (isUser(response)) {
  // ここで response は User 型
}
```

### 4. 非 null アサーション（`!`）禁止

`value!` は実行時エラーの原因になる。`??` / `?.` またはガード節で明示的に処理する。

```ts
// 悪い例
const name = user!.name;

// 良い例
const name = user?.name ?? '名無し';
```

### 5. `enum` 禁止 — `const` + `as const` またはstring ユニオン型を使う

`enum` はランタイムオブジェクトを生成し、Tree-shaking を妨げる。定数には `const` + `as const`、型には string ユニオンを使う。

```ts
// 悪い例
enum Direction {
  Up = 'UP',
  Down = 'DOWN',
}

// 良い例（値が必要な場合）
const Direction = {
  Up: 'UP',
  Down: 'DOWN',
} as const;
type Direction = typeof Direction[keyof typeof Direction];

// 良い例（型だけでよい場合）
type Direction = 'UP' | 'DOWN';
```

### 6. オブジェクト形状には `interface`、ユニオン・エイリアスには `type` を使う

- オブジェクトの構造定義（拡張・実装が想定される）→ `interface`
- ユニオン型・交差型・プリミティブのエイリアス → `type`

```ts
// 悪い例（ユニオンに interface は使えない）
interface Result = Success | Failure; // 構文エラー

// 良い例
interface User {
  id: string;
  name: string;
}

type Result = Success | Failure;
type UserId = string;
```
