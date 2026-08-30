#!/usr/bin/env bash
set -euo pipefail

# Builds a Codex-compatible plugin package without modifying the Claude-oriented
# source skills. The generated package is intentionally ignored by Git.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"
OUTPUT_DIR="$PLUGIN_DIR/build/codex"

usage() {
    cat <<EOF
Usage: $0 [--output-dir DIR]

Build a Codex-compatible copy of this plugin.

The output package contains its own .codex-plugin/plugin.json and ./skills/
directory. Claude routing fields (context and agent) are removed only from the
generated SKILL.md files; source files remain unchanged.

Options:
  --output-dir DIR  Destination plugin root (default: $PLUGIN_DIR/build/codex)
  --help, -h        Show this help message
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --output-dir)
            [[ $# -ge 2 ]] || { echo "Error: --output-dir requires a directory" >&2; exit 1; }
            OUTPUT_DIR="$2"
            shift 2
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            echo "Error: unknown option: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
done

if [[ "$OUTPUT_DIR" != /* ]]; then
    OUTPUT_DIR="$PWD/$OUTPUT_DIR"
fi

if [[ "$OUTPUT_DIR" == "/" || "$OUTPUT_DIR" == "$PLUGIN_DIR" ]]; then
    echo "Error: output directory must be a dedicated package directory" >&2
    exit 1
fi

rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR/.codex-plugin" "$OUTPUT_DIR/skills"

cp "$PLUGIN_DIR/.codex-plugin/plugin.json" "$OUTPUT_DIR/.codex-plugin/plugin.json"
cp -R "$PLUGIN_DIR/scripts" "$OUTPUT_DIR/"
cp -R "$PLUGIN_DIR/templates" "$OUTPUT_DIR/"

for source_skill in "$PLUGIN_DIR"/skills/*; do
    [[ -d "$source_skill" ]] || continue
    skill_name="$(basename "$source_skill")"
    output_skill="$OUTPUT_DIR/skills/$skill_name"
    mkdir -p "$output_skill"

    awk '
        NR == 1 && $0 == "---" { in_frontmatter = 1 }
        in_frontmatter && $0 ~ /^(context|agent):[[:space:]]*/ { next }
        { print }
        in_frontmatter && NR > 1 && $0 == "---" { in_frontmatter = 0 }
    ' "$source_skill/SKILL.md" > "$output_skill/SKILL.md"
done

if grep -R -Eq '^(context|agent):[[:space:]]*' "$OUTPUT_DIR/skills"; then
    echo "Error: generated skills still contain Claude routing fields" >&2
    exit 1
fi

cat <<EOF
Codex package built: $OUTPUT_DIR

Validate it with:
  python /path/to/skill-creator/scripts/quick_validate.py $OUTPUT_DIR/skills/<skill-name>
  python /path/to/plugin-creator/scripts/validate_plugin.py $OUTPUT_DIR
EOF
