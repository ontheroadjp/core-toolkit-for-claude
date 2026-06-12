# /coding-py

まず `coding-general` を参照し、その後以下の Python 固有ルールを適用すること。

---

## ツールチェーン

- **Linter / Formatter**: ruff（lint + format）
- **型チェッカー**: mypy（strict モード）
- **テストフレームワーク**: pytest

---

## 原則

### 1. 全関数に型アノテーションを付与する

関数の引数と戻り値にはすべて明示的な型アノテーションを付ける。型なしの `def f(x):` は禁止。

```python
# 悪い例
def add(a, b):
    return a + b

# 良い例
def add(a: int, b: int) -> int:
    return a + b
```

### 2. `Any` は原則禁止

代替手段がない場合を除き `typing.Any` を使用しない。やむを得ず使用する場合は `# type: ignore` コメントと理由を必ず添える。

- 型が本当に不明な場合は `object` を使う。
- 構造的な契約を表現する場合は `Protocol` を使う。
- 呼び出しをまたいで型情報を保持する場合は `TypeVar` / `Generic` を使う。

```python
# 悪い例
from typing import Any
def process(data: Any) -> Any: ...

# 良い例
from typing import Protocol
class Processable(Protocol):
    def process(self) -> str: ...
```

### 3. 例外の握り潰し禁止

例外を処理せずに飲み込んではならない。ログ出力も再 raise もない `except: pass` や `except Exception: pass` は禁止。

- エラーを本当に無視してよい場合は、その理由をコメントで明示する。

```python
# 悪い例
try:
    connect()
except Exception:
    pass

# 良い例
try:
    connect()
except TimeoutError:
    logger.warning("接続がタイムアウトしました。リトライします")
```

### 4. マジックナンバー禁止

業務ルールや設定を表すリテラルの数値・文字列はすべて名前付き定数に置き換える。

```python
# 悪い例
if retries > 3:
    raise RuntimeError

# 良い例
MAX_RETRY_COUNT = 3
if retries > MAX_RETRY_COUNT:
    raise RuntimeError
```

### 5. 関数は単一責任

関数はそれぞれ 1 つのことだけを行う。説明に「〜して〜する」という複合表現が必要な場合は、分割する。

### 6. `pytest` 規約に従う

- テストファイル: `test_<モジュール名>.py`
- テスト関数: `test_<挙動>_<条件>()`
- 期待される例外は `pytest.raises` を使用する。手動で catch して assert するのは禁止。
- レガシーコードとの統合が必要な場合を除き、`unittest.TestCase` は使用しない。
