---
name: dev-plan
description: Create or update lightweight phased development plan documents with checkbox tasks, test cases, and completion criteria for implementation work
allowed-tools:
  - Read
  - Write
  - Glob
  - Grep
  - Agent
  - Bash(ls:*)
  - Bash(git:*)
  - Bash(wc:*)
arguments:
  - goal
argument-hint: "[구현할 기능 또는 프로젝트 목표 설명]"
user-invocable: true
when_to_use: |
  Use when the user wants to create an implementation plan, design document, or phased development roadmap.
  Examples: 'dev plan', 'implementation plan', 'create a plan for', 'phased plan', 'implement_*.md',
  '개발 계획', '구현 계획', '계획 세워줘', '페이즈 나눠줘', '작업 분해', '구현 플랜', '개발 계획 문서'
---

# Dev Plan

## Overview

프로젝트를 분석하고, 범위를 고정하며, 페이즈별 체크박스 태스크 + 테스트 케이스가 포함된 구현 계획서를 생성한다.

## Inputs

- `$goal`: 구현할 기능 또는 프로젝트 목표 설명

---

## Process

### Step 1: 프로젝트 분석

질문하기 전에 먼저 프로젝트를 분석한다:

1. **프로젝트 설정 파악**: `CLAUDE.md`, `README.md`, `package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml` 등 루트 설정 파일을 읽는다.
2. **프로젝트 문서 탐색**: Glob으로 `.md` 파일을 탐색하여 PRD, TRD, ADR, RFC, 기존 계획서 등 핵심 문서를 식별하고 읽는다.
3. **소스 구조 매핑**: Glob으로 디렉토리 레이아웃을 파악한다 (`src/**`, `lib/**`, `app/**` 등).
4. **컨벤션 식별**: 테스트 디렉토리, 린팅 설정, 빌드 설정, CI 파이프라인을 찾는다.
5. **관련 코드 탐색**: `$goal`이 기존 기능을 참조하면, Grep으로 관련 모듈, 인터페이스, 타입을 찾는다.

### Step 2: 요구사항 확인

`$goal`이 모호하거나 부족한 경우에만 핵심 질문을 한다:

- 범위 경계는? (명시적으로 제외되는 것은?)
- 하드 제약 조건은? (성능 목표, 하위 호환성, 특정 API 사용)
- 선호하는 아키텍처/패턴이 있는가?
- 테스트 전략은? (유닛, 통합, E2E?)

**중요**: 과도한 질문 금지. 코드베이스 분석으로 충분한 컨텍스트를 얻었으면 바로 진행한다.

### Step 3: 아키텍처 설계

1. 필요한 **핵심 추상화** 식별 (인터페이스, 타입, 모듈)
2. **데이터 흐름** 매핑 (입력 → 변환 → 출력)
3. 기존 코드와의 **통합점** 식별
4. **병렬화 가능한 것** 파악 (독립 모듈)
5. **순차적이어야 하는 것** 파악 (컴포넌트 간 의존성)

### Step 4: 계획서 생성

`references/dev-plan-template.md` 템플릿을 따라 작성한다. 필수 섹션:

- Context (Why / Current State / Target State / Scope Boundary)
- Architecture Overview (Diagram / Design Decisions / New Files / Modified Files)
- Phase Dependencies
- Implementation Phases (Tasks + Success Criteria + Test Cases + Testing Instructions)
- Integration & Verification
- Edge Cases & Risks
- Execution Rules

### Step 5: 엔지니어링 리뷰

계획서 생성 후, 구현 전에 리뷰를 수행한다:

1. **자체 검증**: 계획서를 `code-review` 스킬의 Plan mode 기준으로 자체 점검한다.
   - 아키텍처 정합성, 소유권 경계, 엣지케이스, 보안, 테스트 전략
2. **Engineering Review 섹션 추가**: 계획서에 다음 테이블을 포함한다:

```md
## Engineering Review

| 항목 | 판정 | 메모 |
|---|---|---|
| 아키텍처 | ready / needs revision / blocked | ... |
| 공유 계약 | ready / needs revision / blocked | ... |
| 엣지케이스 | ready / needs revision / blocked | ... |
| 테스트 전략 | ready / needs revision / blocked | ... |
```

3. **심층 리뷰 필요 시**: 사용자에게 `/code-review [plan-file-path]`로 별도 리뷰를 안내한다.

### Step 6: 저장 및 보고

1. 프로젝트에 `docs/` 디렉토리가 있으면 → `docs/impl-plan-[feature-name].md`
2. 없으면 → 프로젝트 루트에 `impl-plan-[feature-name].md`
3. 결과 보고: 저장 위치, 총 Phase 수, 병렬 가능 Phase, 예상 범위

---

## Quality Rules

### 태스크 구체성
- 모든 태스크에 **정확한 파일 경로**와 **함수/컴포넌트명** 명시
- "인증 모듈 구현" (X) → "`src/services/auth/oauth-client.ts`에 `exchangeCodeForToken()` 함수 구현" (O)

### 페이즈 크기 제한
- 페이즈당 **최대 7개 태스크** (초과 시 하위 Phase로 분할)

### 테스트 명령어
- 복사-붙여넣기로 바로 실행 가능한 **정확한 명령어** 작성

### 성공 기준
- 객관적으로 검증 가능해야 함
- "잘 동작함" (X) → "입력 `{email: 'test@test.com'}`에 대해 HTTP 200과 `{token: string}` 반환" (O)

### 페이즈 독립성
- 각 Phase는 작동하고 테스트 가능한 증분(increment)을 생산
- 데이터 의존성이 없는 Phase는 병렬 가능으로 표시

### 테스트 우선
- Happy-path와 Error-path 테스트 케이스 모두 포함
- 각 Phase의 테스트는 독립적으로 실행 가능해야 함

### 언어
- 기본: **한국어**
- 프로젝트의 기존 문서가 영어면 영어로 전환
- 기술 용어 (함수명, 파일 경로, 명령어)는 항상 영어
