#!/bin/bash
# PreToolUse hook: rejects edits that add computed view properties (`var foo: some View`) to Swift files.
# Rule: swiftui-conventions.md "Extract views, never view-returning properties".

input=$(cat)

file=$(jq -r '.tool_input.file_path // .tool_input.filePath // empty' <<< "$input")

case "$file" in
    *.swift) ;;
    *) exit 0 ;;
esac

added=$(jq -r '
    [.tool_input.new_string, .tool_input.newString, .tool_input.content,
     (.tool_input.edits // [] | .[].new_string)]
    | map(select(. != null)) | join("\n")
' <<< "$input")

violations=$(grep -nE '^[[:space:]]*((@ViewBuilder|private|fileprivate|public|internal|package|static)[[:space:]]+)*var[[:space:]]+[A-Za-z_][A-Za-z0-9_]*[[:space:]]*:[[:space:]]*some[[:space:]]+View\b' <<< "$added" \
    | grep -vE 'var[[:space:]]+(body|previews)[[:space:]]*:')

[ -z "$violations" ] && exit 0

{
    echo "Edit rejected: computed view properties in the change to $file:"
    echo "$violations"
    echo "Extract each into its own View struct (one per file) instead of a computed property. See .agents/rules/swiftui-conventions.md."
} >&2
exit 2
