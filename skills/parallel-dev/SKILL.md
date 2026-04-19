---
name: parallel-dev
description: Plan and coordinate parallel development workstreams using Claude Code sub-agents with worktree isolation for safe concurrent implementation
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Agent
  - Bash(ls:*)
  - Bash(git:*)
  - Bash(wc:*)
arguments:
  - goal
argument-hint: "[병렬화할 구현 목표 또는 dev-plan 파일 경로]"
user-invocable: true
when_to_use: |
  Use when the user wants to parallelize implementation, split work into multiple agents, define file ownership,
  coordinate sub-agents, reduce merge conflicts, create a merge/integration plan, or use worktree isolation.
  Examples: 'parallel workstreams', 'split work', 'parallelize', 'sub-agent', 'ownership boundaries',
  '병렬 구현', '작업 분리', '워크스트림', '병렬 개발', 'worktree로 나눠서', '에이전트 분배'
---

# Parallel Dev

## Overview

하나의 구현 목표를 안전하고 독립적으로 실행할 수 있는 워크스트림으로 분해한다. Claude Code의 Agent 도구와 worktree isolation을 활용하여 **최대 동시성 + 파일 충돌 없음**을 보장한다.

## Inputs

- `$goal`: 구현 목표 설명 또는 기존 dev-plan 파일 경로

---

## Process

### Step 1: 목표 확인

1. `$goal`이 파일 경로면 해당 계획서를 읽는다.
2. 현재 활성 변경사항(`git status`)과 기존 계획서를 확인한다.
3. 목표, 비목표, 제약 조건을 명확히 한다.

### Step 2: 터치포인트 매핑

1. Glob으로 관련 파일/디렉토리를 스캔한다.
2. Grep으로 수정이 필요한 코드 위치를 찾는다.
3. 공유 의존성(타입, 인터페이스, 설정)을 식별한다.

### Step 3: Foundation 분리

공유 계약(contracts), 타입, 인터페이스를 **작은 Foundation 워크스트림**으로 분리한다. Foundation이 먼저 머지되어야 나머지가 안전하게 진행된다.

### Step 4: 워크스트림 분배

각 워크스트림에 대해 정의한다:

- Objective (목표)
- Deliverables (산출물)
- Owned paths (소유 파일/디렉토리)
- Non-owned paths (건드리면 안 되는 파일)
- Dependencies (의존 워크스트림)
- Tests (검증 방법)
- Done criteria (완료 조건)

`references/parallel-templates.md`의 Workstream Card 형식을 사용한다.

### Step 5: Agent 호출 생성

각 워크스트림을 Claude Code Agent 호출로 변환한다:

- `isolation: "worktree"` — Git worktree 격리로 파일 충돌 방지
- `subagent_type` — 작업 성격에 맞는 타입 선택
- 프롬프트에 소유권 경계와 규칙을 명시

`references/worktree-agent-guide.md`를 참조하여 작성한다.

### Step 6: 병합 순서 결정

1. Foundation 계약/타입 먼저
2. 독립 leaf 워크스트림 (병렬 가능)
3. 공유 wiring/UI
4. 문서
5. 전체 검증

### Step 7: 검증

- 워크스트림별 대상 테스트 실행
- 통합 후 전체 테스트 실행

---

## Sub-Agent Rules

- 각 worker에게 **명시적 파일 소유권**과 **비소유 경계**를 부여한다.
- worker는 코드베이스에 혼자가 아님을 인지해야 한다.
- worker는 다른 에이전트의 수정을 revert하거나 덮어쓰지 않는다.
- 광범위 탐색보다 **범위가 한정된 구현 태스크**를 우선한다.
- 최종 통합과 전체 검증은 **메인 에이전트**가 수행한다.

## Output Shape

1. Workstream Cards (테이블)
2. Ownership Matrix
3. Contract Checklist
4. Merge Sequence
5. Agent Invocation Prompts
6. Risks & Coordination Notes
