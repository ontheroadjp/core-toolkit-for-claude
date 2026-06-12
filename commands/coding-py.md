# /coding-py

Follow `coding-general` first, then apply the following Python-specific rules.

---

## Toolchain

- **Linter / Formatter**: ruff (lint + format)
- **Type checker**: mypy (strict mode)
- **Test framework**: pytest

---

## Principles

### 1. Type annotations required on all functions

Every function argument and return value must have an explicit type annotation. No bare `def f(x):` without types.

```python
# bad
def add(a, b):
    return a + b

# good
def add(a: int, b: int) -> int:
    return a + b
```

### 2. `Any` is prohibited in principle

Do not use `typing.Any` unless there is no alternative. If `Any` is unavoidable, add a `# type: ignore` comment with an explanation of why.

- Prefer `object` for truly unknown types.
- Prefer `Protocol` to express structural contracts.
- Prefer generics (`TypeVar`, `Generic`) to preserve type information across call boundaries.

```python
# bad
from typing import Any
def process(data: Any) -> Any: ...

# good
from typing import Protocol
class Processable(Protocol):
    def process(self) -> str: ...
```

### 3. No silent exception suppression

Never swallow exceptions without handling them. `except: pass` or `except Exception: pass` without a log or re-raise is forbidden.

- If an error is truly ignorable, add an explicit comment explaining why.

```python
# bad
try:
    connect()
except Exception:
    pass

# good
try:
    connect()
except TimeoutError:
    logger.warning("Connection timed out; retrying")
```

### 4. No magic numbers

Replace all literal numeric or string constants that encode a business rule or configuration with named constants.

```python
# bad
if retries > 3:
    raise RuntimeError

# good
MAX_RETRY_COUNT = 3
if retries > MAX_RETRY_COUNT:
    raise RuntimeError
```

### 5. Single responsibility per function

Each function should do exactly one thing. If a function description requires "and", split it.

### 6. Use `pytest` conventions

- Test files: `test_<module>.py`
- Test functions: `test_<behavior>_<condition>()`
- Use `pytest.raises` for expected exceptions; do not catch and assert manually.
- Avoid `unittest.TestCase` unless integrating with legacy code.
