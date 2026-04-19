# README Style Guide

## Header Block

```html
<div align="center">

# Project Name

[![Badge](https://img.shields.io/badge/...)](link)

**Bold one-line description**

Secondary description sentence.

[Section1](#anchor) · [Section2](#anchor) · [Section3](#anchor)

</div>
```

- `<div align="center">`로 헤더 전체를 센터 정렬
- 배지는 프로젝트명 바로 아래
- 앵커 네비게이션은 주요 섹션 3~5개로 제한
- 구분자: ` · ` (middle dot)

## Badges

### Required

| Type | Format |
|---|---|
| License | `[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](./LICENSE)` |

### Tech Stack (해당 기술이 있을 때만)

| Tech | Format |
|---|---|
| Python | `[![Python](https://img.shields.io/badge/Python-3.x+-3776AB?logo=python&logoColor=white)](...)` |
| TypeScript | `[![TypeScript](https://img.shields.io/badge/TypeScript-5.x-3178C6?logo=typescript&logoColor=white)](...)` |
| Node.js | `[![Node.js](https://img.shields.io/badge/Node.js-18+-339933?logo=nodedotjs&logoColor=white)](...)` |
| Go | `[![Go](https://img.shields.io/badge/Go-1.21+-00ADD8?logo=go&logoColor=white)](...)` |
| Rust | `[![Rust](https://img.shields.io/badge/Rust-1.70+-DEA584?logo=rust&logoColor=white)](...)` |
| Bash | `[![Shell](https://img.shields.io/badge/Shell-Bash-4EAA25?logo=gnubash&logoColor=white)](...)` |
| React | `[![React](https://img.shields.io/badge/React-18+-61DAFB?logo=react&logoColor=black)](...)` |
| Docker | `[![Docker](https://img.shields.io/badge/Docker-ready-2496ED?logo=docker&logoColor=white)](...)` |

### Status (CI/패키지가 있을 때만)

| Type | Format |
|---|---|
| CI | `[![CI](https://github.com/OWNER/REPO/actions/workflows/ci.yml/badge.svg)](...)` |
| npm | `[![npm](https://img.shields.io/npm/v/PACKAGE.svg)](...)` |
| PyPI | `[![PyPI](https://img.shields.io/pypi/v/PACKAGE.svg)](...)` |

## Section Icons

| Section | Icon |
|---|---|
| Features / Skills | `📦` |
| Installation | `🚀` |
| Usage / Quick Start | `⚡` |
| Configuration | `⚙️` |
| Project Structure | `📁` |
| API / Reference | `📖` |
| Examples | `📄` |
| Testing / Validation | `✅` |
| Uninstall / Remove | `🗑️` |
| Contributing | `🤝` |
| License | `📜` |
| Troubleshooting | `🔧` |
| Changelog | `📝` |
| Requirements | `📋` |
| Architecture | `🏗️` |
| Security | `🔒` |

## Diagrams

ASCII box 다이어그램 사용 (Mermaid보다 GitHub 호환성 우수):

```text
┌──────────┐    ┌──────────┐    ┌──────────┐
│ Step 1   │ ─▶ │ Step 2   │ ─▶ │ Step 3   │
└──────────┘    └──────────┘    └──────────┘
```

## Tables Over Lists

구조화된 정보는 불릿 리스트보다 테이블 우선:

```markdown
| Item | Description |
|---|---|
| Feature A | Does X |
| Feature B | Does Y |
```

## Code Blocks

- ` ```bash ` 로 셸 명령어를 감쌈
- 복사-붙여넣기 가능한 정확한 명령어
- `#` 주석으로 각 명령어 설명

## Project Tree

```text
project/
├── src/
│   ├── module-a/        # Module description
│   └── module-b/        # Module description
├── tests/               # Tests
└── package.json         # Config
```

`├──` / `└──` / `│` 트리 문자 + 인라인 `# 주석` 사용.

## Full Section Order (최대 구성 — 해당하는 것만 사용)

1. Header (centered, badges, nav)
2. Overview
3. Features / Skills
4. Prerequisites
5. Installation
6. Quick Start / Usage
7. Configuration
8. Project Structure
9. Testing / Validation
10. Examples
11. Uninstall
12. Contributing
13. License
