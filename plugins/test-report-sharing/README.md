# Test Report Sharing Plugin

Collect test reports or share code diffs through a static site exposed with ngrok. The plugin provides two focused skills:

- `test-report-sharing` collects unit-test and E2E reports, including recordings.
- `diff-sharing` generates and shares a code diff, preferring Difftastic whenever `difft` is available.

## Workflows

### Share test reports

The `test-report-operator` collects reports, builds the site, and exposes it through ngrok.

```bash
plugins/test-report-sharing/scripts/collect-test-results.sh
plugins/test-report-sharing/scripts/generate-report-site.sh
plugins/test-report-sharing/scripts/start-ngrok.sh
```

### Share a code diff

The `diff-sharing-operator` compares the working branch with `main` (or `GIT_BASE_REF`), generates the diff site, and exposes it through ngrok.

```bash
plugins/test-report-sharing/scripts/generate-diff-report.sh
plugins/test-report-sharing/scripts/generate-report-site.sh
plugins/test-report-sharing/scripts/start-ngrok.sh
```

When `difft` is on `PATH`, the generated diff page opens with Difftastic selected. Git diff remains available as an alternate renderer. If Difftastic is unavailable, the page defaults to Git diff and marks Difftastic unavailable.

## Configuration

| Variable | Description | Default |
|---|---|---|
| `REPORT_OUTPUT_DIR` | Output directory for reports and diffs | `~/.cache/test-reports/<project-hash>` |
| `REPORT_DIRS` | Colon-separated report directories | Auto-detect (`build/reports/`) |
| `NGROK_AUTHTOKEN` | ngrok authentication token | Required for a public tunnel |
| `NGROK_PORT` | Local port to expose | `8080` |
| `GIT_BASE_REF` | Base Git ref for a diff | `main` |
| `GIT_COMPARE_REF` | Compare Git ref | `HEAD` |
| `GIT_INCLUDE_UNCOMMITTED` | Include uncommitted changes | `true` |
| `DIFFTASTIC_COMMAND` | Difftastic executable name or path | `difft` |
| `DIFFTASTIC_WIDTH` | Captured Difftastic output width | `160` |
| `DIFFTASTIC_SKIP_UNCHANGED` | Omit unchanged files | `true` |
| `DIFFTASTIC_PARSE_ERROR_LIMIT` | Parse errors before text fallback | `100` |

Each script accepts `--help`:

```bash
plugins/test-report-sharing/scripts/collect-test-results.sh --help
plugins/test-report-sharing/scripts/generate-diff-report.sh --help
plugins/test-report-sharing/scripts/generate-report-site.sh --help
plugins/test-report-sharing/scripts/start-ngrok.sh --help
```

## Structure

```text
plugins/test-report-sharing/
├── agents/
│   ├── diff-sharing-operator.md
│   └── test-report-operator.md
├── skills/
│   ├── diff-sharing/
│   │   └── SKILL.md
│   └── test-report-sharing/
│       └── SKILL.md
├── scripts/
│   ├── collect-test-results.sh
│   ├── generate-diff-report.sh
│   ├── generate-report-site.sh
│   └── start-ngrok.sh
├── templates/
│   ├── diff-report.css
│   ├── diff-report.html
│   ├── report-site.html
│   └── style.css
└── tests/
    └── test-generate-diff-report.sh
```

## Requirements

- **Bash 4.0+** for the scripts.
- **Git** for code-diff sharing.
- **Difftastic (`difft`)** for the preferred structural renderer; Git diff is used when it is unavailable.
- **ngrok** for a public tunnel; otherwise the scripts provide a local server URL.
- **Python 3** for the local HTTP-server fallback.

## Troubleshooting

- **No test reports:** run the tests first or set `REPORT_DIRS` to the directories containing their output.
- **Difftastic is unavailable:** install `difft` or set `DIFFTASTIC_COMMAND` to its executable path. The Git renderer remains usable.
- **ngrok is unavailable:** verify `ngrok version`, configure `NGROK_AUTHTOKEN`, or use the returned local server URL.

## License

This plugin is part of the me plugin collection.
