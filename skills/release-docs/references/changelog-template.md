# CHANGELOG Template

[Keep a Changelog](https://keepachangelog.com/) 형식을 따른다.

## Format

```md
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- New feature description

### Changed
- Changed behavior description

### Fixed
- Bug fix description

## [1.0.0] - 2026-04-19

### Added
- Initial release feature 1
- Initial release feature 2

### Fixed
- Bug fix from beta

[Unreleased]: https://github.com/owner/repo/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/owner/repo/releases/tag/v1.0.0
```

## Categories

| Category | 용도 | Conventional Commits |
|---|---|---|
| Added | 새로운 기능 | `feat:`, `add:` |
| Changed | 기존 기능 변경 | `change:`, `update:`, `refactor:` |
| Deprecated | 곧 제거될 기능 | `deprecate:` |
| Removed | 제거된 기능 | `remove:`, `delete:` |
| Fixed | 버그 수정 | `fix:`, `bugfix:` |
| Security | 보안 취약점 수정 | `security:` |

## Rules

- 최신 버전이 맨 위
- 날짜 형식: `YYYY-MM-DD`
- `[Unreleased]` 섹션은 항상 유지
- 하단에 비교 링크 포함
- 각 항목은 사용자 관점으로 작성 ("Added X" not "Implemented X")
