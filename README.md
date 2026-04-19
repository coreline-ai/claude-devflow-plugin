<div align="center">

# claude-devflow-plugin

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](./LICENSE.md)
[![Shell](https://img.shields.io/badge/Shell-Bash-4EAA25?logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Claude Code](https://img.shields.io/badge/Claude_Code-Skills_Bundle-8A2BE2)](https://github.com/coreline-ai/claude-devflow-plugin)

**Claude Code 개발 라이프사이클을 위한 스킬 번들 + Safety Hook**

5 skills covering Plan → Parallelize → Test → Review → Ship, plus a safety hook.

[스킬](#-스킬--skills) · [설치](#-설치--installation) · [Safety Hook](#-safety-hook) · [검증](#-검증--validation)

</div>

---

## Overview

`claude-devflow-plugin`은 개발 전체 라이프사이클을 커버하는 Claude Code 스킬 번들입니다.

```text
  Plan          Execute         Fix & Verify     Review          Ship
┌─────────┐   ┌───────────┐   ┌─────────────┐  ┌───────────┐  ┌───────────┐
│dev-plan  │─▶│parallel-  │─▶│ test-fix-   │─▶│ code-     │─▶│ release-  │
│          │  │dev        │  │ loop        │  │ review    │  │ docs      │
└─────────┘  └───────────┘  └─────────────┘  └───────────┘  └───────────┘
                  ▲                                              
            worktree         ═══════════════════════════════════
            isolation         safety hook (항상 활성, 모든 단계 보호)
```

각 스킬은 **독립 설치** 가능하며, 함께 사용하면 계획부터 배포까지 체계적으로 관리할 수 있습니다.

---

## 📦 스킬 / Skills

### 1. `dev-plan`

> 페이즈별 체크박스 기반 구현 계획서 생성

| 항목 | 내용 |
|---|---|
| **트리거** | `개발 계획`, `구현 계획`, `dev plan`, `implement_*.md` |
| **출력** | `docs/impl-plan-[feature].md` |
| **핵심** | Context → Architecture → Phase(Tasks+Tests+Criteria) → Integration → Risks |

### 2. `parallel-dev`

> Claude Code Agent + worktree isolation으로 안전한 병렬 분해

| 항목 | 내용 |
|---|---|
| **트리거** | `병렬 구현`, `split work`, `parallel workstreams`, `워크스트림` |
| **출력** | Workstream Card · Ownership Matrix · Agent Invocation Prompt |
| **핵심** | 파일 소유권 분리 · worktree 격리 · Sub-Agent 프롬프트 생성 |

### 3. `test-fix-loop`

> 테스트 실행 → 실패 분석 → 수정 → 재실행 자동 루프

| 항목 | 내용 |
|---|---|
| **트리거** | `테스트 돌리고 고쳐줘`, `make tests pass`, `fix failing tests` |
| **출력** | 반복별 수정 요약 · 최종 테스트 결과 |
| **핵심** | 프레임워크 자동 감지 · 원인 조사(investigate 흡수) · 최대 5회 루프 |

### 4. `code-review`

> 구현 계획 / 코드 변경사항 듀얼 모드 리뷰

| 항목 | 내용 |
|---|---|
| **트리거** | `엔지니어링 리뷰`, `코드 리뷰`, `review plan`, `review diff` |
| **출력** | Plan mode: Verdict + Risks · Code mode: Severity별 findings |
| **핵심** | Plan/Code 자동 모드 전환 · 아키텍처/보안/성능/테스트 체크리스트 |

### 5. `release-docs`

> README / CHANGELOG / 릴리스 노트 생성

| 항목 | 내용 |
|---|---|
| **트리거** | `README 꾸며줘`, `CHANGELOG 업데이트`, `릴리즈 노트` |
| **출력** | 배지/아이콘 README · Keep a Changelog 형식 · GitHub release body |
| **핵심** | shields.io 배지 · 섹션 아이콘 · git log 기반 자동 분류 |

---

## 🔒 Safety Hook

`safety-guard.sh`는 Claude Code의 **PreToolUse hook**으로 동작하며, 위험한 Bash 명령을 실행 전에 차단합니다.

| 차단 패턴 | 예시 |
|---|---|
| 루트/홈 삭제 | `rm -rf /`, `rm -rf ~` |
| main/master force push | `git push --force origin main` |
| hard reset | `git reset --hard` |
| 과도한 권한 | `chmod 777` |
| 시크릿 파일 노출 | `cat .env`, `cat *.pem` |
| 디스크 포맷 | `mkfs`, `dd if=` |

hook은 `install.sh all` 또는 `install.sh hooks`로 설치되며, `~/.claude/settings.json`에 자동 등록됩니다.

---

## 🚀 설치 / Installation

### 전체 설치 (스킬 5개 + hook)

```bash
./install.sh all
```

### 개별 스킬만

```bash
./install.sh dev-plan
./install.sh parallel-dev test-fix-loop
```

### hook만

```bash
./install.sh hooks
```

> **설치 위치:**
> - 스킬: `${CLAUDE_HOME:-$HOME/.claude}/skills/<skill-name>`
> - Hook: `${CLAUDE_HOME:-$HOME/.claude}/hooks/safety-guard.sh`
> - 설정: `~/.claude/settings.json`에 PreToolUse 항목 추가

### 요구사항

| 도구 | 필수 | 용도 |
|---|---|---|
| `bash` | O | 스크립트 실행 |
| `python3` | O | frontmatter 검증 |
| `jq` | △ (hook 설치 시) | settings.json 머지 |

### 기존 스킬 충돌 처리

| 상황 | 동작 |
|---|---|
| 같은 폴더명이 이미 존재 | 자동 백업 → `<skill>.backup.YYYYMMDD_HHMMSS` |
| 다른 폴더에 동일 `name:` 스킬 존재 | 경고 메시지 출력 |

---

## 🗑️ 제거 / Uninstall

```bash
# 전체 제거 (스킬 + hook)
./uninstall.sh all

# 개별 스킬 제거
./uninstall.sh parallel-dev

# hook만 제거
./uninstall.sh hooks
```

---

## ✅ 검증 / Validation

```bash
./validate.sh
```

| 검증 항목 | 설명 |
|---|---|
| Shell syntax | `install.sh`, `uninstall.sh`, `validate.sh` 문법 검사 |
| Frontmatter | `name`, `description`(≥30자), `allowed-tools`, `user-invocable`, `when_to_use` |
| References | 각 스킬의 `references/` 디렉토리에 `.md` 파일 존재 |
| Hook test | safe 명령 → exit 0, 위험 명령 → exit 2, non-Bash → exit 0 |
| Install smoke | 임시 `CLAUDE_HOME`에서 전체 설치/제거 라운드트립 |

---

## 📄 예시 / Examples

- [`examples/workflow-example.md`](./examples/workflow-example.md) — 5개 스킬 통합 시나리오
- [`examples/settings-hooks-example.json`](./examples/settings-hooks-example.json) — hook 설정 예시

---

## 📁 프로젝트 구조

```text
claude-devflow-plugin/
├── skills/
│   ├── dev-plan/                        # 구현 계획 생성
│   │   ├── SKILL.md
│   │   └── references/dev-plan-template.md
│   ├── parallel-dev/                    # 병렬 워크스트림 분해
│   │   ├── SKILL.md
│   │   └── references/
│   │       ├── parallel-templates.md
│   │       └── worktree-agent-guide.md
│   ├── test-fix-loop/                   # 테스트 수정 루프
│   │   ├── SKILL.md
│   │   └── references/tfl-workflow-guide.md
│   ├── code-review/                     # 계획/코드 리뷰
│   │   ├── SKILL.md
│   │   └── references/
│   │       ├── plan-review-checklist.md
│   │       └── code-review-checklist.md
│   └── release-docs/                    # 릴리스 문서 생성
│       ├── SKILL.md
│       └── references/
│           ├── readme-style-guide.md
│           └── changelog-template.md
├── hooks/
│   └── safety-guard.sh                  # PreToolUse 안전 가드
├── examples/
│   ├── workflow-example.md              # 통합 워크플로 예시
│   └── settings-hooks-example.json      # hook 설정 예시
├── install.sh                           # 설치 (스킬 + hook)
├── uninstall.sh                         # 제거 (스킬 + hook)
├── validate.sh                          # 검증
├── FILE_DESIGN.md                       # 파일 설계 문서
├── LICENSE.md                           # MIT License
└── .gitignore
```

---

## 🤝 Contributing

1. Fork this repository
2. Create a feature branch (`git checkout -b feature/my-skill`)
3. Run validation (`./validate.sh`)
4. Commit and open a Pull Request

---

## 📜 License

MIT License — see [`LICENSE.md`](./LICENSE.md) for details.

Copyright (c) 2026 [Coreline AI](https://github.com/coreline-ai)
