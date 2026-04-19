# Dev Plan Template

```md
# Implementation Plan: [기능명]

> [한 줄 요약]
> Generated: [YYYY-MM-DD]
> Project: [프로젝트명]

---

## 1. Context (배경)

### 1.1 Why (왜 필요한가)
[비즈니스/기술적 동기]

### 1.2 Current State (현재 상태)
[현재 존재하는 것, 부족하거나 문제인 것]

### 1.3 Target State (목표 상태)
[구현 완료 후 시스템의 모습]

### 1.4 Scope Boundary (범위)
- **In scope**: [수행할 것]
- **Out of scope**: [수행하지 않을 것]

---

## 2. Architecture Overview (아키텍처)

### 2.1 Design Diagram
[ASCII 다이어그램 또는 구조화된 설명]

### 2.2 Key Design Decisions
| 결정 사항 | 선택 | 근거 |
|-----------|------|------|
| ... | ... | ... |

### 2.3 New Files (신규 파일)
| 파일 경로 | 용도 |
|-----------|------|
| ... | ... |

### 2.4 Modified Files (수정 파일)
| 파일 경로 | 변경 내용 |
|-----------|-----------|
| ... | ... |

---

## 3. Phase Dependencies (페이즈 의존성)

Phase 0 (기반) → Phase 1 + Phase 2 (병렬 가능) → Phase 3 (통합)

---

## 4. Implementation Phases (구현 페이즈)

### Phase 0: Foundation Setup (기반 설정)
> 모든 다른 페이즈의 전제 조건
> Dependencies: 없음

#### Tasks
- [ ] [태스크 1: 파일 경로 + 함수/컴포넌트 수준 설명]
- [ ] [태스크 2: ...]

#### Success Criteria (성공 기준)
- [구체적이고 측정 가능한 기준]

#### Test Cases (테스트 케이스)
- [ ] TC-0.1: [테스트 대상, 입력, 기대 결과]
- [ ] TC-0.E1: [에러 케이스]

#### Testing Instructions (테스트 실행)
```bash
# 정확한 테스트 실행 명령어
```

**테스트 실패 시**: 에러 분석 → 근본 원인 수정 → 재테스트 → 통과 후에만 다음 Phase

---

### Phase N: [페이즈 이름]
> [한 줄 설명]
> Dependencies: Phase X

#### Tasks
- [ ] [태스크: 파일 경로 + 함수명 수준]

#### Success Criteria
- [객관적 검증 가능 기준]

#### Test Cases
- [ ] TC-N.1: [...]
- [ ] TC-N.E1: [에러 케이스]

#### Testing Instructions
```bash
[정확한 명령어]
```

---

## 5. Integration & Verification (통합 검증)

### 5.1 Integration Test Plan
- [ ] [E2E 시나리오 1]

### 5.2 Manual Verification Steps
1. [Step 1: 구체적 동작]

### 5.3 Rollback Strategy
- [문제 발생 시 되돌리는 방법]

---

## 6. Edge Cases & Risks (엣지 케이스 및 위험)

| 위험 요소 | 영향도 | 완화 방안 |
|-----------|--------|-----------|
| ... | 높음/중간/낮음 | ... |

---

## 7. Execution Rules (실행 규칙)

1. 각 Phase는 독립적으로 구현하고 테스트한다
2. 모든 태스크 체크박스 체크 + 모든 테스트 통과 = 완료
3. 테스트 실패 시: 에러 분석 → 수정 → 재테스트 → 통과 후에만 다음 Phase
4. 체크박스를 체크하여 이 문서에 진행 상황 기록
5. 병렬 가능 Phase는 동시 진행 가능
```
