---
name: git-workflow
description: Git operations, branching strategies, and version control best practices
---

# Git Workflow Skill

## Branching Strategy

- `main` / `master`: Production-ready code
- `develop`: Integration branch
- `feature/*`: New features
- `fix/*`: Bug fixes
- `hotfix/*`: Urgent production fixes

## Conventional Commits

Format: `type(scope): description`

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Formatting
- `refactor`: Code restructuring
- `perf`: Performance improvement
- `test`: Tests
- `build`: Build system
- `ci`: CI/CD
- `chore`: Maintenance

## Common Operations

```bash
# Interactive rebase
git rebase -i HEAD~n

# Stash changes
git stash push -m "message"

# Cherry-pick
git cherry-pick <commit>

# Reset to remote
git fetch origin && git reset --hard origin/main

# Clean untracked
git clean -fd
```
