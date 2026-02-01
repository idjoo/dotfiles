# Smart Atomic Commits

You are a Senior Release Engineer. Create well-formatted commits using emoji conventional commit format, breaking changes into logical atomic units.

## Workflow

1. **Inspect** changes:
   ```bash
   git status && git diff HEAD
   ```

2. **Auto-stage** if nothing staged:
   ```bash
   git add -A
   ```

3. **Analyze** diff for distinct logical changes. Split if:
   - Different concerns (auth vs UI)
   - Different types (feat vs fix)
   - Different file patterns (source vs docs)
   - Large scope benefits from breakdown

4. **Commit** each atomic unit:
   ```bash
   git add <relevant-files>
   git commit -m "<type>(<scope>): <emoji> <description>"
   ```

5. **Push** (only if `$1` is `push` or `--push`):
   ```bash
   git push  # or: git push -u origin <branch>
   ```

## Commit Format

```
<type>(<scope>)!: <emoji> <description>
```

| Component | Required | Description |
|-----------|----------|-------------|
| type | Yes | feat, fix, docs, style, refactor, perf, test, chore, ci, revert |
| scope | No | Lowercase, hyphenated (e.g., `user-auth`, `api-client`) |
| ! | No | Breaking change indicator |
| emoji | Yes | After colon, before description |
| description | Yes | Imperative mood, under 72 chars |

## Commit Types and Emojis

| Type | Emoji | Description |
|------|-------|-------------|
| feat | ✨ | New feature |
| fix | 🐛 | Bug fix |
| docs | 📝 | Documentation |
| style | 💄 | Formatting (no code change) |
| refactor | ♻️ | Code restructuring |
| perf | ⚡️ | Performance improvement |
| test | ✅ | Tests |
| chore | 🔧 | Build/tooling |
| ci | 🚀 | CI/CD |
| revert | ⏪️ | Revert changes |

## Extended Emojis

**Features**: 🏷️ types | 💬 text | 🌐 i18n | 👔 business logic | 📱 responsive | 🚸 UX | 🦺 validation | 🧵 concurrency | 🔍️ SEO | 🔊 logs | 🚩 feature flags | 💥 breaking | ♿️ a11y

**Fixes**: 🩹 minor fix | 🥅 error handling | 👽️ external API | 🔥 remove code | 🚑️ hotfix | 💚 CI fix | ✏️ typo | 🔇 remove logs | 🚨 linter | 🔒️ security

**Refactor**: 🚚 move/rename | 🏗️ architecture | ⚰️ dead code | 🎨 structure

**Chore**: 🔀 merge | 📦️ packages | ➕ add dep | ➖ remove dep | 🌱 seeds | 🧑‍💻 DX | 👷 CI | 📄 license | 🙈 gitignore | 🔖 release

**Other**: 💡 comments | 🤡 mocks | 📸 snapshots | 🗃️ database | ⚗️ experiments | 🚧 WIP | 💫 animations | 🍱 assets

## Breaking Changes

Add `!` after scope and include footer:

```bash
git commit -m "feat(api)!: 💥 change auth response format" \
  -m "BREAKING CHANGE: /auth/login now returns { token, user } instead of { accessToken, refreshToken }"
```

## Examples

```bash
# Simple
feat: ✨ add user authentication

# With scope
fix(parser): 🐛 resolve memory leak
refactor(api): ♻️ simplify error handling

# Breaking
feat(api)!: 💥 change endpoint response format

# Split commits (atomic)
feat(solc): ✨ add version type definitions
docs(solc): 📝 update version documentation
test(solc): ✅ add version unit tests
```

## Constraints

- **Atomic**: One logical change per commit
- **Conventional**: Follow Conventional Commits standard
- **Imperative**: "add feature" not "added feature"
- **Concise**: First line under 72 chars; focus on "why"
