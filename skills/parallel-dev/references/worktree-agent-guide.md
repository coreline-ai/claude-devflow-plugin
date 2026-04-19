# Worktree Agent Guide

## Claude Code Agent + Worktree Isolation

Claude Code의 `Agent` 도구에 `isolation: "worktree"`를 설정하면 Git worktree를 사용하여 격리된 복사본에서 작업한다.

### 동작 방식

1. Agent 호출 시 임시 Git worktree가 생성된다.
2. Agent는 격리된 복사본에서 파일을 수정한다.
3. 변경사항이 없으면 worktree가 자동 정리된다.
4. 변경사항이 있으면 worktree 경로와 브랜치가 반환된다.
5. 메인 에이전트가 변경사항을 리뷰하고 머지한다.

### 언제 사용하는가

| 상황 | worktree 사용 | 이유 |
|---|---|---|
| 독립적인 파일 영역 작업 | O | 충돌 위험 없이 병렬 실행 |
| 여러 에이전트 동시 실행 | O | 각자 격리된 환경에서 안전하게 수정 |
| 위험한 실험적 변경 | O | 실패해도 메인에 영향 없음 |
| 단순 조회/탐색 | X | 오버헤드 불필요 |
| 순차적 단일 작업 | X | 격리 이점 없음 |

### subagent_type 선택 가이드

| 타입 | 용도 |
|---|---|
| `general-purpose` | 코드 구현, 파일 수정, 빌드 실행 |
| `Explore` | 코드베이스 조사, 패턴 탐색 (읽기 전용) |
| `Plan` | 아키텍처 설계, 구현 계획 수립 |

### 병렬 작업 주의사항

1. **소유권 명시**: 각 Agent 프롬프트에 Owned/Non-owned paths를 반드시 포함
2. **Foundation 우선**: 공유 타입/인터페이스는 병렬 작업 전에 먼저 완료
3. **단방향 의존성**: A→B 의존성이 있으면 A 완료 후 B 시작
4. **충돌 감지**: 같은 파일을 두 Agent가 수정하면 머지 시 충돌 발생 — 소유권으로 사전 방지
5. **통합은 메인에서**: 개별 Agent가 다른 Agent의 결과를 머지하지 않음

### 예시: 3-way 병렬

```text
Phase 0: Foundation (main agent)
├── types.ts, interfaces.ts 정의
└── 머지 완료

Phase 1: 병렬 실행
├── Agent(WS-1, worktree) → src/backend/*
├── Agent(WS-2, worktree) → src/frontend/*
└── Agent(WS-3, worktree) → tests/*

Phase 2: 통합 (main agent)
├── WS-1 머지
├── WS-2 머지
├── WS-3 머지
└── 전체 테스트 실행
```
