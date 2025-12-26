# Global Agent Context

This file contains persistent memories and instructions for the Gemini CLI agent.

## Package Management

To determine which JavaScript package manager a project uses, look for the specific lock file located in the project's root directory:

| Lock File                | Package Manager |
| :----------------------- | :-------------- |
| `package-lock.json`      | `npm`           |
| `pnpm-lock.yaml`         | `pnpm`          |
| `yarn.lock`              | `yarn`          |
| `bun.lockb` / `bun.lock` | `bun`           |

## Tool Usage Guidelines

### Context7 / MCP Tools

Always use `context7` when performing:

- Code generation
- Error solving
- Troubleshooting
- Setup or configuration steps
- Library/API documentation retrieval

**Action:** Automatically use Context7 MCP tools to resolve library IDs and fetch documentation. Do not wait for explicit instructions.
