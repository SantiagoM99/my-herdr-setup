## Agents run in Herdr

On this machine coding agents run in Herdr panes (`HERDR_ENV=1`). When the user asks, in any language, to spawn, launch, open or "spin up" agents or helpers, they mean visible agents in Herdr panes, not built-in subagents: load the `herdr` skill and follow it, with these preferences.

- **Where.** One agent: a sibling pane in the current tab, as the skill says. Several agents: a new tab in the current workspace, labelled with the task, in the current directory, and split there:
  ```bash
  tab=$(herdr tab create --workspace "$HERDR_WORKSPACE_ID" --cwd "$PWD" --label "<task>" --no-focus)
  root=$(printf '%s\n' "$tab" | jq -r '.result.root_pane.pane_id')
  ```
- **Which agent.** Your own kind (`claude` from Claude Code, `codex` from Codex) unless the user names another.
- **Names.** Name each agent after its role (`reviewer`, `tests`), give it its task with `herdr agent prompt`, and tell the user the tab and the agent names.
- **Ownership.** Work only in panes and tabs you created, tracked by the IDs the commands return. The user's other panes, including other agents, stay untouched.
