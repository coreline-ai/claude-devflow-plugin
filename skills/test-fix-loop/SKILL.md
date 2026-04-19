---
name: test-fix-loop
description: Automated test-driven fix loop — run tests, analyze failures, investigate root causes, fix code, and re-run until all tests pass with configurable max iterations
allowed-tools:
  - Read
  - Edit
  - Write
  - Glob
  - Grep
  - Agent
  - Bash(npm test:*)
  - Bash(npx:*)
  - Bash(bun test:*)
  - Bash(bun run:*)
  - Bash(pytest:*)
  - Bash(python3 -m pytest:*)
  - Bash(go test:*)
  - Bash(cargo test:*)
  - Bash(jest:*)
  - Bash(vitest:*)
  - Bash(make test:*)
  - Bash(make:*)
  - Bash(tsc:*)
  - Bash(git diff:*)
  - Bash(git status:*)
  - Bash(ls:*)
  - Bash(wc:*)
arguments:
  - target
argument-hint: "[test command, file pattern, or 'investigate' for analysis-only mode]"
user-invocable: true
when_to_use: |
  Use when the user wants to run tests and fix failures in a loop, debug test failures, investigate root causes,
  or achieve passing tests through iterative fixes.
  Examples: 'run tests and fix', 'test fix loop', 'make tests pass', 'fix failing tests', 'investigate failure',
  '테스트 돌리고 고쳐줘', '테스트 통과시켜', '실패 원인 분석', '테스트 루프', '디버그'
---

# Test Fix Loop

## Overview

테스트를 실행하고, 실패를 분석하고, 코드를 수정하고, 다시 실행하는 루프를 자동화한다. 원인 분석(investigate) 모드도 포함한다.

## Inputs

- `$target`: 다음 중 하나
  - 테스트 명령어 (예: `npm test`, `pytest tests/api/`)
  - 파일 패턴 (예: `tests/auth/*.test.ts`)
  - `investigate` — 수정 없이 원인 분석만

---

## Process

### Step 1: 테스트 프레임워크 감지

`$target`이 명령어가 아니면 자동 감지한다. 상세 감지 규칙과 실패 분류는 `references/tfl-workflow-guide.md`를 참조한다.

| 파일 | 프레임워크 | 기본 명령어 |
|---|---|---|
| `package.json` (scripts.test) | npm/bun | `npm test` / `bun test` |
| `vitest.config.*` | Vitest | `npx vitest run` |
| `jest.config.*` | Jest | `npx jest` |
| `pyproject.toml` [tool.pytest] | pytest | `python3 -m pytest` |
| `go.mod` | Go test | `go test ./...` |
| `Cargo.toml` | Cargo | `cargo test` |
| `Makefile` (test target) | Make | `make test` |

### Step 2: 테스트 실행

Bash로 테스트를 실행하고 전체 출력을 캡처한다.

### Step 3: 실패 파싱

출력에서 실패 정보를 추출한다:

| 분류 | 패턴 |
|---|---|
| Compilation error | `SyntaxError`, `TypeError`, `cannot find module`, build 실패 |
| Assertion failure | `AssertionError`, `expect(...).toBe(...)`, `assertEqual` 실패 |
| Runtime exception | `ReferenceError`, `NullPointerException`, segfault |
| Timeout | `timeout`, `exceeded`, `SIGTERM` |

실패한 테스트 이름, 파일 위치, 에러 메시지, 스택 트레이스를 구조화한다.

### Step 4: 원인 조사

1. 실패한 테스트 파일을 Read로 읽는다.
2. 스택 트레이스의 소스 코드를 추적한다.
3. Grep으로 관련 함수/모듈을 찾는다.
4. 복잡한 경우 Agent(subagent_type: "Explore")로 심층 조사한다.

**Investigation 모드** (`$target` = `investigate`): 이 단계에서 멈추고 분석 결과를 보고한다.
- 실패 트리 (어떤 테스트가 왜 실패하는지)
- 호출 체인 분석
- 가설 순위 (가장 가능성 높은 원인부터)
- 제안 수정안 (적용하지 않음)

### Step 5: 최소 수정 적용

- 프로덕션 코드를 수정한다 (테스트 코드가 아닌).
- 테스트 자체가 잘못된 경우에만 테스트를 수정한다.
- 한 번에 하나의 관심사(concern)만 수정한다.
- 수정 범위를 최소로 유지한다.

### Step 6: 재실행

1. 실패했던 테스트만 먼저 실행 (빠른 피드백).
2. 통과하면 전체 테스트 스위트 실행 (회귀 확인).

### Step 7: 루프

- 전부 통과할 때까지 Step 2~6을 반복한다.
- 기본 최대 반복: **5회**.
- 같은 테스트가 같은 에러로 **3회 연속** 실패하면 루프를 중단하고 보고한다.

### Step 8: 결과 보고

- 총 반복 횟수
- 수정한 파일 목록
- 각 반복에서 수정한 내용 요약
- 최종 테스트 결과 (통과/잔여 실패)

---

## Loop Rules

1. **최소 수정**: 한 반복에서 한 관심사만 수정
2. **프로덕션 코드 우선**: 테스트보다 소스 코드 수정을 우선
3. **범위 제한**: 실패와 관련 없는 코드를 수정하지 않음
4. **반복 추적**: 각 반복의 변경사항을 기록하여 롤백 가능하게
5. **중단 조건**:
   - 최대 반복 초과
   - 같은 에러 3회 연속 반복
   - 근본적 설계 문제 발견 (수동 개입 필요)
   - 외부 의존성 문제 (네트워크, DB, 서비스)
