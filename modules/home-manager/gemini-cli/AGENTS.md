# Global Agent Context

This file contains persistent memories and instructions for the Gemini CLI agent.

## Core Tool Preference

**Mandate:** Always prefer the gemini-cli core tools (e.g., `run_shell_command`, `read_file`, `write_file`) over external or complex specialized tools whenever possible, unless a specialized tool is explicitly required for the task (like `resolve-library-id` for docs).

## Package Management

To determine which JavaScript package manager a project uses, look for the specific lock file located in the project's root directory:

| Lock File                | Package Manager |
| :----------------------- | :-------------- |
| `package-lock.json`      | `npm`           |
| `pnpm-lock.yaml`         | `pnpm`          |
| `yarn.lock`              | `yarn`          |
| `bun.lockb` / `bun.lock` | `bun`           |

## Tool Usage Guidelines

### Context7 / MCP Tools (MANDATORY)

**Critical Instruction:** You generally lack up-to-date knowledge of specific libraries, frameworks, and APIs. You **MUST** use Context7 MCP tools (`resolve-library-id`, `query-docs`) as your **first step** in the following scenarios:

1.  **Code Generation:** Before writing any code involving 3rd party libraries.
2.  **Error Solving:** To understand error messages or correct API usage.
3.  **Configuration:** When setting up tools or frameworks.
4.  **Documentation:** Whenever you are unsure about the exact signature or behavior of a function.

**Workflow:**

1.  **Identify:** Recognize the library/tool involved (e.g., "Next.js", "Tailwind", "Python `requests`").
2.  **Resolve:** Call `resolve-library-id` to get the correct context ID.
3.  **Query:** Call `query-docs` with specific questions (e.g., "how to fetch data in app router", "v5 config options").

**Do NOT rely on your internal training data for syntax or API details unless you have verified they are standard and unchanged.**

### Task Management (Todo Tool)

**Mandate:** The `todo` tool is the primary mechanism for state and task tracking. You MUST use it for every interaction that involves more than a single immediate action.

**Workflow:**

1.  **Plan:** Immediately break down the user's request into actionable steps and add them using the `todo` tool.
2.  **Execute & Update:** As you complete each step, mark it as done using the `todo` tool before moving to the next.
3.  **Persist:** Ensure the todo list reflects the current state of the task at all times.
