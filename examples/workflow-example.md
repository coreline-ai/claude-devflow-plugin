# Workflow Example: 결제 모듈 구현

5개 스킬이 순서대로 동작하는 통합 시나리오 예시.

---

## Step 1: `/dev-plan` — 구현 계획 작성

```text
/dev-plan 결제 모듈 구현 — PG 연동, 결제 상태 관리, 웹훅 수신
```

**출력**: `docs/impl-plan-payment.md`

```md
## Phase Dependencies
Phase 0 (공유 타입) → Phase 1 (PG client) + Phase 2 (webhook) 병렬 → Phase 3 (통합 테스트)

## Phase 0: Foundation
- [ ] src/types/payment.ts — PaymentRequest, PaymentResult 인터페이스 정의
- [ ] src/types/webhook.ts — WebhookEvent 타입 정의

## Phase 1: PG Client
- [ ] src/payment/pg-client.ts — createPayment(), getPaymentStatus()
- [ ] tests/payment/pg-client.test.ts

## Phase 2: Webhook Handler
- [ ] src/webhook/handler.ts — verifySignature(), processEvent()
- [ ] tests/webhook/handler.test.ts

## Phase 3: Integration
- [ ] E2E 결제 흐름 테스트
```

---

## Step 2: `/parallel-dev` — 병렬 워크스트림 분해

```text
/parallel-dev docs/impl-plan-payment.md 기반으로 분해
```

**출력**: Workstream Cards + Agent Invocations

| WS | 목적 | 소유 파일 | 비소유 파일 | 의존성 |
|---|---|---|---|---|
| Phase 0 | 공유 타입 | `src/types/*` | 전체 구현 파일 | 없음 |
| WS-1 | PG client | `src/payment/*` | `src/webhook/*` | Phase 0 |
| WS-2 | Webhook | `src/webhook/*` | `src/payment/*` | Phase 0 |

```text
Agent(
  description: "WS-1: PG client implementation",
  subagent_type: "general-purpose",
  isolation: "worktree",
  prompt: "Implement PG client in src/payment/. Owned: src/payment/*. Do not edit: src/webhook/*..."
)
```

---

## Step 3: `/test-fix-loop` — 테스트 수정 루프

```text
/test-fix-loop npm test
```

**실행 흐름**:

```text
Iteration 1: npm test → 3 failures
  → pg-client.test.ts: TypeError - missing null check
  → Fix: src/payment/pg-client.ts:42 — null guard 추가
  → Re-run: 2 failures remaining

Iteration 2: npm test → 2 failures
  → handler.test.ts: signature verification mismatch
  → Fix: src/webhook/handler.ts:18 — HMAC encoding 수정
  → Re-run: 0 failures

Result: All tests passed (2 iterations)
```

---

## Step 4: `/code-review` — 코드 리뷰

```text
/code-review code
```

**출력**:

```md
## Summary
| File | Changes | Findings |
|---|---|---|
| src/payment/pg-client.ts | +82 lines | 1 warning |
| src/webhook/handler.ts | +64 lines | 1 critical |

## Findings

### [critical] src/webhook/handler.ts:25
웹훅 서명 검증에서 timing attack 취약점.
`===` 대신 `crypto.timingSafeEqual()` 사용 필요.

### [warning] src/payment/pg-client.ts:58
PG API 타임아웃이 설정되지 않음. 기본값이 무한 대기.
`timeout: 30000` 추가 권장.
```

---

## Step 5: `/release-docs` — 릴리스 문서

```text
/release-docs all
```

**출력**:
- `README.md` — 결제 모듈 섹션 추가, 배지 업데이트
- `CHANGELOG.md` — v1.1.0 항목 추가
- Release notes — GitHub release body

```md
## [1.1.0] - 2026-04-19

### Added
- PG 결제 연동 (createPayment, getPaymentStatus)
- 웹훅 수신 및 서명 검증

### Fixed
- Webhook signature timing-safe comparison
```

---

## Safety Hook (전 과정)

전 과정에서 safety hook이 자동으로 보호:

```text
✓ npm test                          → 허용
✓ git add src/payment/pg-client.ts  → 허용
✗ git push --force origin main      → 차단 (exit 2)
✗ rm -rf /                          → 차단 (exit 2)
✓ git push origin feature/payment   → 허용
```
