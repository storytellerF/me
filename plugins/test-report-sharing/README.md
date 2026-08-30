# Test Report Sharing Plugin

Collect unit-test and E2E reports, including recordings, then share a static report site through ngrok.

## Workflow

```bash
plugins/test-report-sharing/scripts/collect-test-results.sh
plugins/test-report-sharing/scripts/generate-report-site.sh
plugins/test-report-sharing/scripts/start-ngrok.sh
```

`test-report-operator` coordinates the same workflow when Claude agent routing is available.

## Configuration

| Variable | Description | Default |
|---|---|---|
| `REPORT_OUTPUT_DIR` | Output directory for collected reports | `~/.cache/test-reports/<project-hash>` |
| `REPORT_DIRS` | Colon-separated report directories | Auto-detect (`build/reports/`) |
| `NGROK_AUTHTOKEN` | ngrok authentication token | Required for a public tunnel |
| `NGROK_PORT` | Local port to expose | `8080` |

## Build a Codex-Compatible Package

Source skills retain Claude routing metadata. Build an untracked Codex package before validating or loading it in Codex:

```bash
plugins/test-report-sharing/scripts/build-codex-package.sh
```

The generated plugin root is `plugins/test-report-sharing/build/codex/`, with its manifest at `build/codex/.codex-plugin/plugin.json`. It contains a copy of the runtime files and removes only `context` and `agent` from copied `SKILL.md` frontmatter.

## Structure

```text
plugins/test-report-sharing/
├── agents/test-report-operator.md
├── skills/test-report-sharing/SKILL.md
├── scripts/
│   ├── build-codex-package.sh
│   ├── collect-test-results.sh
│   ├── generate-report-site.sh
│   └── start-ngrok.sh
├── templates/
│   ├── report-site.html
│   └── style.css
└── tests/
    ├── test-build-codex-package.sh
    └── test-generate-report-site.sh
```

## Requirements

- **Bash 4.0+** for the scripts.
- **ngrok** for public sharing; otherwise use the local server URL.
- **Python 3** for the local HTTP-server fallback.

## License

This plugin is part of the me plugin collection.
