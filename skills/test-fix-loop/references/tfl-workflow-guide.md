# Test Fix Loop Workflow Guide

## 프레임워크 감지 테이블

| 감지 파일 | 확인 내용 | 프레임워크 | 명령어 |
|---|---|---|---|
| `package.json` | `scripts.test` 값 | npm/yarn/bun | `npm test` |
| `package.json` | `vitest` in devDependencies | Vitest | `npx vitest run` |
| `package.json` | `jest` in devDependencies | Jest | `npx jest` |
| `vitest.config.ts` | 파일 존재 | Vitest | `npx vitest run` |
| `jest.config.*` | 파일 존재 | Jest | `npx jest` |
| `pyproject.toml` | `[tool.pytest]` 섹션 | pytest | `python3 -m pytest` |
| `setup.cfg` | `[tool:pytest]` 섹션 | pytest | `python3 -m pytest` |
| `go.mod` | 파일 존재 | Go test | `go test ./...` |
| `Cargo.toml` | 파일 존재 | Cargo | `cargo test` |
| `Makefile` | `test:` 타겟 | Make | `make test` |

감지 우선순위: 명시적 설정 파일 > package.json devDependencies > Makefile

## 실패 분류 가이드

### Compilation / Build Error
- **증상**: 코드가 실행 전에 실패
- **패턴**: `SyntaxError`, `TypeError: ... is not a function`, `Module not found`, `cannot find module`
- **조사 방향**: import 경로, 타입 정의, 빌드 설정 확인
- **일반적 수정**: import 수정, 타입 추가, export 추가

### Assertion Failure
- **증상**: 테스트 기대값과 실제값 불일치
- **패턴**: `AssertionError`, `expect(received).toBe(expected)`, `assert ... == ...`
- **조사 방향**: 비즈니스 로직 변경, 데이터 변환, 경계값 처리
- **일반적 수정**: 로직 수정, 엣지케이스 처리 추가

### Runtime Exception
- **증상**: 실행 중 예외 발생
- **패턴**: `ReferenceError`, `NullPointerException`, `panic`, `segfault`
- **조사 방향**: null 체크, 초기화 순서, 리소스 해제
- **일반적 수정**: null guard 추가, 초기화 로직 수정

### Timeout
- **증상**: 테스트가 시간 초과로 실패
- **패턴**: `timeout`, `exceeded`, `SIGTERM`, `SIGKILL`
- **조사 방향**: 무한 루프, 데드락, 느린 외부 호출, 미해결 Promise
- **일반적 수정**: 비동기 처리 수정, 타임아웃 증가, mock 추가

## 조사 기법

### Stack Trace Reading
1. 가장 아래(bottom)부터 읽는다 — 최초 호출 지점
2. 프로젝트 코드만 집중한다 (node_modules, site-packages 스킵)
3. 마지막 프로젝트 코드 라인이 핵심 원인일 확률이 높다

### Grep Patterns
```text
# 함수 정의 찾기
Grep: "function functionName" 또는 "def functionName"

# 호출 위치 찾기
Grep: "functionName("

# 타입/인터페이스 찾기
Grep: "interface TypeName" 또는 "type TypeName"

# 환경 변수 사용처
Grep: "process.env.VAR_NAME" 또는 "os.environ"
```

### Bisection Strategy
같은 테스트가 반복 실패할 때:
1. 최근 git diff를 확인
2. 변경된 파일 중 테스트와 관련된 파일 식별
3. 변경 전 동작과 비교하여 원인 축소

## 루프 중단 판단

| 상황 | 판단 | 이유 |
|---|---|---|
| 같은 에러 3회 반복 | 중단 | 현재 접근으로 해결 불가 |
| 한 수정이 다른 테스트를 깨뜨림 | 계속 (주의) | 회귀 수정 필요 |
| 외부 서비스 의존 실패 | 중단 | 코드 수정으로 해결 불가 |
| 설계 수준 문제 발견 | 중단 + 보고 | 사용자 판단 필요 |
| 5회 초과 | 중단 + 요약 | 진행 상황과 잔여 이슈 보고 |
