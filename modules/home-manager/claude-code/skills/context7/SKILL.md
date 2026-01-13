---
name: context7
description: Look up current library documentation via Context7 MCP. Use when writing code that uses external libraries, frameworks, or packages to ensure correct API usage.
allowed-tools: mcp__context7__resolve-library-id, mcp__context7__query-docs
user-invocable: false
---

# Context7 Documentation Lookup

Query up-to-date documentation for any library before writing code that uses it.

## Workflow

1. **Resolve library ID**: Call `resolve-library-id` with the library name and your query
2. **Query documentation**: Call `query-docs` with the resolved library ID and specific question
3. **Implement**: Write code based on the retrieved documentation

## When to Use

- External libraries (React, FastAPI, Prisma, Next.js, etc.)
- Frequently-updated packages where APIs may have changed
- Uncertain about API syntax or method signatures
- Any non-trivial import or library usage

## Example

```
User: "Add NextAuth"

1. resolve-library-id("nextauth", "how to set up authentication")
2. query-docs(libraryId, "NextAuth setup and configuration")
3. Implement based on current docs
```

## Critical Rules

- **Never trust training data alone** for library APIs
- Query docs BEFORE writing library code
- Use specific queries to get relevant documentation
- Limit to 3 calls per question - use best result if not found
