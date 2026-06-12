# /coding-general

Language-agnostic implementation principles for AI agents. Apply these regardless of programming language or framework.

---

## Principles

### 1. No guessing — check the docs first

Before using any library, function, or API, check the official documentation or type stubs. Never infer behavior from naming alone.

- Read the relevant section of the official docs or source type stubs.
- If the docs are ambiguous, state the ambiguity and ask the user before proceeding.

### 2. Ask when specs are unclear — never assume

If the requirement, expected behavior, or edge-case handling is not explicitly stated, stop and ask. Do not fill in gaps with assumptions.

- State exactly what is unclear.
- Propose an interpretation only as a question, not as a decision.

### 3. Follow existing patterns and conventions

Read the surrounding code before writing new code. Match the naming conventions, file structure, error handling style, and abstraction level already present in the project.

- Do not introduce new patterns when an existing one fits.
- If an existing pattern is clearly wrong, flag it separately — do not silently fix it as a side effect.

### 4. Single responsibility per function

Each function, method, or module should do exactly one thing. If a function needs a multi-clause description using "and", it should be split.

### 5. No silent exception suppression

Never swallow exceptions without handling them. Bare `except: pass`, empty `catch {}`, or `_ = err` without a return or log are forbidden.

- If an error is truly ignorable, add an explicit comment explaining why.

### 6. No magic numbers

Replace all literal numeric (or string) constants that encode a business rule or configuration with named constants.

- Define constants at the top of the file or in a dedicated constants module.
- The name must convey intent, not just value (`MAX_RETRY_COUNT = 3`, not `THREE = 3`).
