# Code Review Checklist

## Correctness (정확성)

- [ ] 로직 에러가 없다 (잘못된 조건, 누락된 분기)
- [ ] Off-by-one 에러가 없다
- [ ] Null/undefined 처리가 적절하다
- [ ] 레이스 컨디션이 없다 (동시 접근, 비동기 순서)
- [ ] 리소스 누수가 없다 (파일 핸들, 커넥션, 이벤트 리스너)
- [ ] 에러 처리가 적절하다 (catch, finally, 에러 전파)

## Security (보안)

- [ ] 사용자 입력이 검증/이스케이프되어 있다
- [ ] SQL injection, XSS, command injection 취약점이 없다
- [ ] 시크릿/API 키가 코드에 하드코딩되지 않았다
- [ ] 인증/인가 체크가 적절하다
- [ ] 민감 데이터가 로그에 노출되지 않는다
- [ ] eval(), exec() 등 위험한 동적 실행이 없다

## Performance (성능)

- [ ] 불필요한 O(n²) 이상의 복잡도가 없다
- [ ] N+1 쿼리 문제가 없다
- [ ] 불필요한 메모리 할당이 없다
- [ ] 블로킹 I/O가 비동기 컨텍스트에서 사용되지 않는다
- [ ] 캐싱이 적절히 활용되어 있다 (과도하지도, 부족하지도 않게)

## Testing (테스트)

- [ ] 변경된 코드에 대한 테스트가 있다
- [ ] 엣지 케이스가 테스트에 포함되어 있다
- [ ] 회귀 테스트가 있다 (이전 버그 재발 방지)
- [ ] 모킹이 적절하다 (과도하지 않고, 외부 의존성만)
- [ ] 테스트가 결정적(deterministic)이다 (flaky 아님)

## Style & Convention (스타일)

- [ ] 프로젝트 네이밍 컨벤션을 따른다
- [ ] 불필요한 코드(dead code, commented-out code)가 없다
- [ ] import 순서가 프로젝트 규칙을 따른다
- [ ] 복잡한 로직에 적절한 주석이 있다
- [ ] 기존 패턴과 일관성이 있다

## Severity Definitions

| Level | 기준 | 예시 |
|---|---|---|
| `critical` | 버그, 보안 취약점, 데이터 손실 | SQL injection, null pointer crash, race condition |
| `warning` | 잠재적 문제, 성능 저하 | N+1 query, missing error handling, unvalidated input |
| `suggestion` | 개선 가능 | 더 나은 변수명, 중복 코드 추출, 테스트 추가 |
| `nit` | 스타일/포맷 | 공백, import 순서, 주석 위치 |
