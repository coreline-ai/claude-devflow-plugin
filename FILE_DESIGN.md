# FILE_DESIGN.md

## 목적

`claude-devflow-plugin`의 파일 구조와 책임을 정의한다.

## 구조

```text
claude-devflow-plugin/
├── skills/
│   ├── dev-plan/
│   │   ├── SKILL.md
│   │   └── references/dev-plan-template.md
│   ├── parallel-dev/
│   │   ├── SKILL.md
│   │   └── references/
│   │       ├── parallel-templates.md
│   │       └── worktree-agent-guide.md
│   ├── test-fix-loop/
│   │   ├── SKILL.md
│   │   └── references/tfl-workflow-guide.md
│   ├── code-review/
│   │   ├── SKILL.md
│   │   └── references/
│   │       ├── plan-review-checklist.md
│   │       └── code-review-checklist.md
│   └── release-docs/
│       ├── SKILL.md
│       └── references/
│           ├── readme-style-guide.md
│           └── changelog-template.md
├── hooks/
│   └── safety-guard.sh
├── examples/
│   ├── workflow-example.md
│   └── settings-hooks-example.json
├── install.sh
├── uninstall.sh
├── validate.sh
├── FILE_DESIGN.md
├── README.md
├── LICENSE.md
└── .gitignore
```

## 책임 분리

| 경로 | 책임 |
|---|---|
| `skills/dev-plan` | phased dev-plan 생성 |
| `skills/parallel-dev` | 병렬 workstream 분해 + worktree Agent 가이드 |
| `skills/test-fix-loop` | 테스트 실패 분석 + 수정 루프 |
| `skills/code-review` | 구현 계획 / 코드 듀얼 리뷰 |
| `skills/release-docs` | README / CHANGELOG / 릴리스 노트 생성 |
| `hooks/safety-guard.sh` | PreToolUse Bash 위험 명령 차단 |
| `install.sh` | 전체/개별 스킬 + hook 설치 |
| `uninstall.sh` | 전체/개별 스킬 + hook 제거 |
| `validate.sh` | 구조 검증, hook 테스트, install smoke |
| `examples/` | 통합 워크플로 예시 + hook 설정 예시 |

## 설계 원칙

- 스킬은 독립 설치 가능해야 한다.
- Claude Code 네이티브 도구(Agent worktree, TodoWrite, hooks)를 활용한다.
- SKILL.md에 `allowed-tools`, `user-invocable`, `when_to_use`를 반드시 포함한다.
- safety는 hook 기반으로 항상 활성화되어야 한다.
- 플러그인은 Claude Code 런타임 기능을 구현하지 않고, 작업 운영 규칙만 제공한다.
