---
name: release-docs
description: Generate or update release documentation — README.md styling with badges and navigation, CHANGELOG entries, and release notes for version management
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Agent
  - Bash(ls:*)
  - Bash(git:*)
  - Bash(git log:*)
  - Bash(git tag:*)
  - Bash(git diff:*)
arguments:
  - target
argument-hint: "[readme, changelog, release-notes, or all]"
user-invocable: true
when_to_use: |
  Use when the user wants to update release documentation, restyle a README, generate changelog entries, or create release notes.
  Examples: 'README redesign', 'modernize README', 'add badges', 'changelog update', 'release notes',
  'README 스타일링', 'README 꾸며줘', 'CHANGELOG 업데이트', '릴리즈 노트', '문서 정리', 'README 다시 만들어줘'
---

# Release Docs

## Overview

세 가지 문서 생성 기능을 제공한다:
1. **README** — 최신 GitHub 스타일로 README.md 리디자인
2. **CHANGELOG** — git log 기반 CHANGELOG.md 생성/업데이트
3. **Release Notes** — 버전 간 변경 요약

## Inputs

- `$target`: `readme`, `changelog`, `release-notes`, 또는 `all`

---

## README Mode

### Process

1. **프로젝트 분석**: 기존 README, 루트 설정 파일(`package.json`, `pyproject.toml` 등), 라이선스, 디렉토리 구조를 파악한다.
2. **기술 스택 식별**: 사용 언어, 프레임워크, 빌드/테스트 도구를 파악한다.
3. **섹션 설계**: 프로젝트에 해당하는 섹션만 선택한다.
4. **README 작성**: `references/readme-style-guide.md` 스타일 가이드를 따른다.
5. **검증**: 모든 파일 경로, 명령어, 기능 설명이 실제 프로젝트와 일치하는지 확인한다.

### README Rules

- 프로젝트에 실제 존재하는 기술만 배지에 포함
- 존재하지 않는 CI, npm, PyPI 배지를 만들지 않음
- 기존 README의 핵심 정보를 누락하지 않음
- 프로젝트 규모에 비례한 분량 (소규모 ~80줄, 중규모 ~150줄, 대규모 200줄+)
- 기존 README의 언어(한국어/영어/혼합)를 따름

---

## CHANGELOG Mode

### Process

1. 마지막 태그/릴리스 이후의 git log를 수집한다.
2. 커밋을 분류한다: Added, Changed, Fixed, Removed, Security, Deprecated.
3. `references/changelog-template.md`의 Keep a Changelog 형식으로 작성한다.
4. 기존 CHANGELOG.md가 있으면 상단에 새 항목을 추가한다.

### Commit Classification

| 커밋 prefix | CHANGELOG 카테고리 |
|---|---|
| `feat:`, `add:` | Added |
| `change:`, `update:`, `refactor:` | Changed |
| `fix:`, `bugfix:` | Fixed |
| `remove:`, `delete:` | Removed |
| `security:` | Security |
| `deprecate:` | Deprecated |
| prefix 없음 | 내용으로 판단 |

---

## Release Notes Mode

### Process

1. 두 태그/커밋 간의 diff를 수집한다.
2. 변경사항을 요약한다:
   - Breaking changes (최상단)
   - New features
   - Bug fixes
   - Other changes
3. GitHub release body 형식으로 출력한다.

---

## Quality Rules

- 기술 용어(명령어, 파일 경로, 함수명)는 항상 영어
- 프로젝트에 없는 기능을 언급하지 않음
- 기존 문서의 핵심 정보를 보존
- CHANGELOG는 Keep a Changelog 형식을 준수
- Release notes는 사용자 관점으로 작성 (내부 구현 디테일 최소화)
