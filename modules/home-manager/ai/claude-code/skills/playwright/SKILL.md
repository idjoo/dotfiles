---
name: playwright
description: Automate browser interactions with Playwright MCP. Use for web scraping, form filling, testing, or any browser-based automation tasks.
allowed-tools: mcp__playwright__*
user-invocable: false
---

# Playwright Browser Automation

Efficiently automate browser interactions using the Playwright MCP tools.

## Tool Preference

**Prefer `browser_run_code` for batch operations** - it executes multiple Playwright operations in a single call, reducing round-trips.

```javascript
// Good: Single call for multiple operations
browser_run_code: async (page) => {
  await page.goto('https://example.com');
  await page.fill('#email', 'user@test.com');
  await page.fill('#password', 'secret');
  await page.click('button[type="submit"]');
}

// Avoid: Multiple individual tool calls
// browser_navigate → browser_type → browser_type → browser_click
```

## When to Use Individual Tools

- **Snapshot needed**: Use `browser_snapshot` to read page state for decision-making
- **Dynamic interaction**: When next action depends on page response
- **Debugging**: Step-by-step execution for troubleshooting

## Screenshot Rule

After any screen-modifying action, call `browser_take_screenshot`:

```
filename: "latest.png"  # ALWAYS use this unless user specifies another name
```

## Screen-Changing Tools

These tools modify the visible page and require screenshots:

- `browser_navigate`, `browser_click`, `browser_type`
- `browser_fill_form`, `browser_select_option`, `browser_press_key`
- `browser_handle_dialog`, `browser_file_upload`
- `browser_tabs` (select/new), `browser_run_code`

## Storage State

Browser session persists at `/playwright-data/state.json` (cookies, localStorage, auth).

## Pattern

```
# Batch operation with screenshot
browser_run_code(code) → browser_take_screenshot(filename: "latest.png")

# Individual operation with screenshot
browser_click(element, ref) → browser_take_screenshot(filename: "latest.png")
```
