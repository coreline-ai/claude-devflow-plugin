---
name: code-review
description: Dual-mode review skill — review implementation plans before coding (plan mode) or review code changes after implementation (code mode) with architecture, risk, and test analysis
allowed-tools:
  - Read
  - Glob
  - Grep
  - Agent
  - Bash(ls:*)
  - Bash(git:*)
  - Bash(git diff:*)
  - Bash(git log:*)
  - Bash(git show:*)
arguments:
  - target
argument-hint: "[plan file path, 'code', branch name, or 'diff' for current changes]"
user-invocable: true
when_to_use: |
  Use when the user wants to review an implementation plan or code changes.
  Plan mode: 'review plan', 'engineering review', 'architecture review', 'lock in plan', '엔지니어링 리뷰', '계획 리뷰'
  Code mode: 'review code', 'code review', 'review changes', 'review PR', 'review diff', '코드 리뷰', '변경 리뷰'
---

# Code Review

## Overview

두 가지 모드를 제공하는 리뷰 스킬:
- **Plan mode**: 코딩 전 구현 계획 리뷰
- **Code mode**: 구현 후 코드 변경사항 리뷰

## Inputs

- `$target`: 모드 결정 기준
  - `.md` 파일 경로, `implement_*`, `plan` 키워드 → **Plan mode**
  - `code`, `diff`, 브랜치명, PR 번호 → **Code mode**
  - 모호하면 사용자에게 확인

---

## Plan Mode

### Process

1. 대상 계획서와 관련 프로젝트 문서를 읽는다.
2. 목표와 범위를 평문으로 재진술한다.
3. `references/plan-review-checklist.md`를 기준으로 검토한다:
   - 아키텍처와 데이터 흐름
   - 소유권 경계, 계약, 의존성
   - 엣지케이스, 실패 모드, 보안, 성능, 롤백
   - 테스트 전략과 smoke 커버리지
4. 우선순위가 매겨진 권고사항을 생성한다.
5. 요청 시 계획서에 수용된 권고사항을 반영한다.

### Plan Mode Output

1. **Verdict**: `ready` / `needs revision` / `blocked`
2. Top risks
3. Architecture & contract notes
4. Test coverage notes
5. Required plan edits
6. Recommended next action

### Review Standards (Plan)

선호:
- 암묵적 커플링보다 **명시적 계약**
- 영리한 추상화보다 **지루한 기술**
- 빅뱅 리라이트보다 **점진적 변경**
- 수동 확인보다 **결정적 테스트**

경고:
- 소유자가 불분명한 공유 파일
- 후속 경로 없는 스텁
- happy path만 커버하는 테스트
- 숨겨진 마이그레이션/롤아웃 리스크
- 관련 없는 기능이 섞인 계획
- 정리로 위장한 범위 확장

---

## Code Mode

### Process

1. 변경사항을 수집한다:
   - `git diff` (staged + unstaged)
   - `git diff main...HEAD` (브랜치 전체)
   - `git show <commit>` (특정 커밋)
2. `references/code-review-checklist.md`를 기준으로 검토한다:
   - 정확성 (로직 에러, off-by-one, null 처리, 레이스 컨디션)
   - 보안 (입력 검증, 시크릿 노출, 인젝션, 안전하지 않은 eval)
   - 성능 (복잡도, 메모리, I/O 패턴, 캐싱)
   - 테스트 (커버리지, 엣지케이스, 회귀, 모킹 전략)
   - 스타일/컨벤션 (네이밍, 포맷, import 순서, 데드코드)
3. 심각도별로 발견사항을 분류한다.

### Code Mode Output

1. **Summary table**: 파일별 변경 요약
2. **Findings**: 심각도별 상세 발견사항
3. **Required fixes**: 반드시 수정해야 하는 항목
4. **Suggestions**: 권장 개선사항

### Severity Levels

| Level | 의미 | 조치 |
|---|---|---|
| `critical` | 버그, 보안 취약점, 데이터 손실 위험 | 반드시 수정 |
| `warning` | 잠재적 문제, 성능 이슈 | 수정 권장 |
| `suggestion` | 개선 가능한 부분 | 고려 |
| `nit` | 스타일, 포맷 | 선택적 |
