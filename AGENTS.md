# Agent maintenance rules

This repository is the source of truth for the `me` Codex plugin collection and its portable agent prompts.

- Keep reusable agent prompts at the plugin root in `plugins/*/agents/*.md`, alongside the plugin's `skills/` directory.
- Keep prompts specific to this repository under `agents/`; do not place one-off application behavior in the global collection.
- Keep Claude agent instructions in Markdown with only Claude-compatible frontmatter: `name`, `description`, `model`, and `effort`.
- Preserve `context: fork` and `agent: <agent-name>` in a skill's frontmatter when they route the skill to a Claude agent. Do not delete those routing fields to satisfy a Codex-only validator.
- Build Codex-compatible packages before validating or loading plugins whose source skills contain Claude routing fields. Use `scripts/build-codex-plugin-package.sh --all` to generate all packages under `build/plugins/` and the marketplace at `build/.agents/plugins/marketplace.json`; validate only the generated skill copies with `skill-creator/scripts/quick_validate.py`.
- When a skill or agent changes, proactively update the owning `SKILL.md`, `README.md`, and applicable `CLAUDE.md` references. The custom agent prompts themselves belong at plugin root.
- Do not claim that installing a plugin automatically installs agents.
- Use `MAJOR.MINOR.PATCH-YYYYMMDDHHMMSS` for every plugin version. Keep each plugin's `.codex-plugin/plugin.json` and `.claude-plugin/plugin.json` versions identical, and do not insert environment or tool labels into the version.
- Validate changed skills and the plugin manifest before handoff. For plugins with a Codex build package, validate the generated package and its skills. Tell the user when a new Codex thread is needed to load plugin changes.
- Keep prompts privacy-safe and generalized; never copy raw account conversation content, secrets, or personal identifiers into this repository.

The repository-level maintenance prompt is [`agents/me-agent-config-maintainer.md`](agents/me-agent-config-maintainer.md).
